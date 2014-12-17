# Copyright 2012 the V8 project authors. All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:
#
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.
#     * Neither the name of Google Inc. nor the names of its
#       contributors may be used to endorse or promote products derived
#       from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
# A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
# OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
# SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
# LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Simple framework for running the benchmark suites and
# computing a score based on the timing measurements.

# A benchmark has a name (string) and a function that will be run to
# do the performance measurement. The optional setup and tearDown
# arguments are functions that will be invoked before and after
# running the benchmark, but the running time of these functions will
# not be accounted for in the benchmark score.
Benchmark = (name, run, setup, tearDown) ->
  @name = name
  @run = run
  @Setup = (if setup then setup else ->
  )
  @TearDown = (if tearDown then tearDown else ->
  )
  return

# Benchmark results hold the benchmark and the measured time used to
# run the benchmark. The benchmark score is computed later once a
# full benchmark suite has run to completion.
BenchmarkResult = (benchmark, time) ->
  @benchmark = benchmark
  @time = time
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
BenchmarkResult::valueOf = ->
  @time


# Keep track of all declared benchmark suites.
BenchmarkSuite.suites = []

# Scores are not comparable across versions. Bump the version if
# you're making changes that will affect that scores, e.g. if you add
# a new benchmark or change an existing one.
BenchmarkSuite.version = "7"

# To make the benchmark results predictable, we replace Math.random
# with a 100% deterministic alternative.
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

# Runs all registered benchmark suites and optionally yields between
# each individual benchmark to avoid running for too long in the
# context of browsers. Once done, the final score is reported to the
# runner.
BenchmarkSuite.RunSuites = (runner) ->
  RunStep = ->
    while continuation or index < length
      if continuation
        continuation = continuation()
      else
        suite = suites[index++]
        runner.NotifyStart suite.name  if runner.NotifyStart
        continuation = suite.RunStep(runner)
      if continuation and typeof window isnt "undefined" and window.setTimeout
        window.setTimeout RunStep, 25
        return
    if runner.NotifyScore
      score = BenchmarkSuite.GeometricMean(BenchmarkSuite.scores)
      formatted = BenchmarkSuite.FormatScore(100 * score)
      runner.NotifyScore formatted
    return
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
  mean = BenchmarkSuite.GeometricMean(@results)
  score = @reference / mean
  BenchmarkSuite.scores.push score
  if @runner.NotifyResult
    formatted = BenchmarkSuite.FormatScore(100 * score)
    @runner.NotifyResult @name, formatted
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
    n = 0

    while elapsed < 1000
      benchmark.run()
      elapsed = new Date() - start
      n++
    if data?
      data.runs += n
      data.elapsed += elapsed
    return
  unless data?
    
    # Measure the benchmark once for warm up and throw the result
    # away. Return a fresh data object.
    Measure null
    runs: 0
    elapsed: 0
  else
    Measure data
    
    # If we've run too few iterations, we continue for another second.
    return data  if data.runs < 32
    usec = (data.elapsed * 1000) / data.runs
    @NotifyStep new BenchmarkResult(benchmark, usec)
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
  @results = []
  @runner = runner
  length = @benchmarks.length
  index = 0
  suite = this
  data = undefined
  
  # Start out running the setup.
  RunNextSetup()
