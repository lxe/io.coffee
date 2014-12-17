# Copyright 2014 the V8 project authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Performance.now is used in latency benchmarks, the fallback is Date.now.

# Simple framework for running the benchmark suites and
# computing a score based on the timing measurements.

# A benchmark has a name (string) and a function that will be run to
# do the performance measurement. The optional setup and tearDown
# arguments are functions that will be invoked before and after
# running the benchmark, but the running time of these functions will
# not be accounted for in the benchmark score.
Benchmark = (name, doWarmup, doDeterministic, deterministicIterations, run, setup, tearDown, rmsResult, minIterations) ->
  @name = name
  @doWarmup = doWarmup
  @doDeterministic = doDeterministic
  @deterministicIterations = deterministicIterations
  @run = run
  @Setup = (if setup then setup else ->
  )
  @TearDown = (if tearDown then tearDown else ->
  )
  @rmsResult = (if rmsResult then rmsResult else null)
  @minIterations = (if minIterations then minIterations else 32)
  return

# Benchmark results hold the benchmark and the measured time used to
# run the benchmark. The benchmark score is computed later once a
# full benchmark suite has run to completion. If latency is set to 0
# then there is no latency score for this benchmark.
BenchmarkResult = (benchmark, time, latency) ->
  @benchmark = benchmark
  @time = time
  @latency = latency
  return

# Automatically convert results to numbers. Used by the geometric
# mean computation.

# Suites of benchmarks consist of a name and the set of benchmarks in
# addition to the reference timing that the final score will be based
# on. This way, all scores are relative to a reference run and higher
# scores implies better performance.
BenchmarkSuite = (name, reference, benchmarks) ->
  @name = name
  @reference = reference
  @benchmarks = benchmarks
  BenchmarkSuite.suites.push this
  return
performance = performance or {}
performance.now = (->
  performance.now or performance.mozNow or performance.msNow or performance.oNow or performance.webkitNow or Date.now
)()
BenchmarkResult::valueOf = ->
  @time


# Keep track of all declared benchmark suites.
BenchmarkSuite.suites = []

# Scores are not comparable across versions. Bump the version if
# you're making changes that will affect that scores, e.g. if you add
# a new benchmark or change an existing one.
BenchmarkSuite.version = "1"

# Defines global benchsuite running mode that overrides benchmark suite
# behavior. Intended to be set by the benchmark driver. Undefined
# values here allow a benchmark to define behaviour itself.
BenchmarkSuite.config =
  doWarmup: `undefined`
  doDeterministic: `undefined`


# Override the alert function to throw an exception instead.
alert = (s) ->
  throw "Alert called with argument: " + sreturn


# To make the benchmark results predictable, we replace Math.random
# with a 100% deterministic alternative.
BenchmarkSuite.ResetRNG = ->
  Math.random = (->
    seed = 49734321
    ->
      
      # Robert Jenkins' 32 bit integer hash function.
      seed = ((seed + 0x7ed55d16) + (seed << 12)) & 0xffffffff
      seed = ((seed ^ 0xc761c23c) ^ (seed >>> 19)) & 0xffffffff
      seed = ((seed + 0x165667b1) + (seed << 5)) & 0xffffffff
      seed = ((seed + 0xd3a2646c) ^ (seed << 9)) & 0xffffffff
      seed = ((seed + 0xfd7046c5) + (seed << 3)) & 0xffffffff
      seed = ((seed ^ 0xb55a4f09) ^ (seed >>> 16)) & 0xffffffff
      (seed & 0xfffffff) / 0x10000000
  )()
  return


# Runs all registered benchmark suites and optionally yields between
# each individual benchmark to avoid running for too long in the
# context of browsers. Once done, the final score is reported to the
# runner.
BenchmarkSuite.RunSuites = (runner, skipBenchmarks) ->
  RunStep = ->
    while continuation or index < length
      if continuation
        continuation = continuation()
      else
        suite = suites[index++]
        runner.NotifyStart suite.name  if runner.NotifyStart
        if skipBenchmarks.indexOf(suite.name) > -1
          suite.NotifySkipped runner
        else
          continuation = suite.RunStep(runner)
      if continuation and typeof window isnt "undefined" and window.setTimeout
        window.setTimeout RunStep, 25
        return
    
    # show final result
    if runner.NotifyScore
      score = BenchmarkSuite.GeometricMean(BenchmarkSuite.scores)
      formatted = BenchmarkSuite.FormatScore(100 * score)
      runner.NotifyScore formatted
    return
  skipBenchmarks = (if typeof skipBenchmarks is "undefined" then [] else skipBenchmarks)
  continuation = null
  suites = BenchmarkSuite.suites
  length = suites.length
  BenchmarkSuite.scores = []
  index = 0
  RunStep()
  return


# Counts the total number of registered benchmarks. Useful for
# showing progress as a percentage.
BenchmarkSuite.CountBenchmarks = ->
  result = 0
  suites = BenchmarkSuite.suites
  i = 0

  while i < suites.length
    result += suites[i].benchmarks.length
    i++
  result


# Computes the geometric mean of a set of numbers.
BenchmarkSuite.GeometricMean = (numbers) ->
  log = 0
  i = 0

  while i < numbers.length
    log += Math.log(numbers[i])
    i++
  Math.pow Math.E, log / numbers.length


# Computes the geometric mean of a set of throughput time measurements.
BenchmarkSuite.GeometricMeanTime = (measurements) ->
  log = 0
  i = 0

  while i < measurements.length
    log += Math.log(measurements[i].time)
    i++
  Math.pow Math.E, log / measurements.length


# Computes the geometric mean of a set of rms measurements.
BenchmarkSuite.GeometricMeanLatency = (measurements) ->
  log = 0
  hasLatencyResult = false
  i = 0

  while i < measurements.length
    unless measurements[i].latency is 0
      log += Math.log(measurements[i].latency)
      hasLatencyResult = true
    i++
  if hasLatencyResult
    Math.pow Math.E, log / measurements.length
  else
    0


# Converts a score value to a string with at least three significant
# digits.
BenchmarkSuite.FormatScore = (value) ->
  if value > 100
    value.toFixed 0
  else
    value.toPrecision 3


# Notifies the runner that we're done running a single benchmark in
# the benchmark suite. This can be useful to report progress.
BenchmarkSuite::NotifyStep = (result) ->
  @results.push result
  @runner.NotifyStep result.benchmark.name  if @runner.NotifyStep
  return


# Notifies the runner that we're done with running a suite and that
# we have a result which can be reported to the user if needed.
BenchmarkSuite::NotifyResult = ->
  mean = BenchmarkSuite.GeometricMeanTime(@results)
  score = @reference[0] / mean
  BenchmarkSuite.scores.push score
  if @runner.NotifyResult
    formatted = BenchmarkSuite.FormatScore(100 * score)
    @runner.NotifyResult @name, formatted
  if @reference.length is 2
    meanLatency = BenchmarkSuite.GeometricMeanLatency(@results)
    unless meanLatency is 0
      scoreLatency = @reference[1] / meanLatency
      BenchmarkSuite.scores.push scoreLatency
      if @runner.NotifyResult
        formattedLatency = BenchmarkSuite.FormatScore(100 * scoreLatency)
        @runner.NotifyResult @name + "Latency", formattedLatency
  return

BenchmarkSuite::NotifySkipped = (runner) ->
  BenchmarkSuite.scores.push 1 # push default reference score.
  runner.NotifyResult @name, "Skipped"  if runner.NotifyResult
  return


# Notifies the runner that running a benchmark resulted in an error.
BenchmarkSuite::NotifyError = (error) ->
  @runner.NotifyError @name, error  if @runner.NotifyError
  @runner.NotifyStep @name  if @runner.NotifyStep
  return


# Runs a single benchmark for at least a second and computes the
# average time it takes to run a single iteration.
BenchmarkSuite::RunSingleBenchmark = (benchmark, data) ->
  Measure = (data) ->
    elapsed = 0
    start = new Date()
    
    # Run either for 1 second or for the number of iterations specified
    # by minIterations, depending on the config flag doDeterministic.
    i = 0

    while ((if doDeterministic then i < benchmark.deterministicIterations else elapsed < 1000))
      benchmark.run()
      elapsed = new Date() - start
      i++
    if data?
      data.runs += i
      data.elapsed += elapsed
    return
  config = BenchmarkSuite.config
  doWarmup = (if config.doWarmup isnt `undefined` then config.doWarmup else benchmark.doWarmup)
  doDeterministic = (if config.doDeterministic isnt `undefined` then config.doDeterministic else benchmark.doDeterministic)
  
  # Sets up data in order to skip or not the warmup phase.
  if not doWarmup and not data?
    data =
      runs: 0
      elapsed: 0
  unless data?
    Measure null
    runs: 0
    elapsed: 0
  else
    Measure data
    
    # If we've run too few iterations, we continue for another second.
    return data  if data.runs < benchmark.minIterations
    usec = (data.elapsed * 1000) / data.runs
    rms = (if (benchmark.rmsResult?) then benchmark.rmsResult() else 0)
    @NotifyStep new BenchmarkResult(benchmark, usec, rms)
    null


# This function starts running a suite, but stops between each
# individual benchmark in the suite and returns a continuation
# function which can be invoked to run the next benchmark. Once the
# last benchmark has been executed, null is returned.
BenchmarkSuite::RunStep = (runner) ->
  
  # Run the setup, the actual benchmark, and the tear down in three
  # separate steps to allow the framework to yield between any of the
  # steps.
  RunNextSetup = ->
    if index < length
      try
        suite.benchmarks[index].Setup()
      catch e
        suite.NotifyError e
        return null
      return RunNextBenchmark
    suite.NotifyResult()
    null
  RunNextBenchmark = ->
    try
      data = suite.RunSingleBenchmark(suite.benchmarks[index], data)
    catch e
      suite.NotifyError e
      return null
    
    # If data is null, we're done with this benchmark.
    (if (not (data?)) then RunNextTearDown else RunNextBenchmark())
  RunNextTearDown = ->
    try
      suite.benchmarks[index++].TearDown()
    catch e
      suite.NotifyError e
      return null
    RunNextSetup
  BenchmarkSuite.ResetRNG()
  @results = []
  @runner = runner
  length = @benchmarks.length
  index = 0
  suite = this
  data = undefined
  
  # Start out running the setup.
  RunNextSetup()
