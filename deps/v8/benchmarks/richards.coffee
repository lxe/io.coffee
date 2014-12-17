# Copyright 2006-2008 the V8 project authors. All rights reserved.
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

# This is a JavaScript implementation of the Richards
# benchmark from:
#
#    http://www.cl.cam.ac.uk/~mr10/Bench.html
#
# The benchmark was originally implemented in BCPL by
# Martin Richards.

###*
The Richards benchmark simulates the task dispatcher of an
operating system.
###
runRichards = ->
  scheduler = new Scheduler()
  scheduler.addIdleTask ID_IDLE, 0, null, COUNT
  queue = new Packet(null, ID_WORKER, KIND_WORK)
  queue = new Packet(queue, ID_WORKER, KIND_WORK)
  scheduler.addWorkerTask ID_WORKER, 1000, queue
  queue = new Packet(null, ID_DEVICE_A, KIND_DEVICE)
  queue = new Packet(queue, ID_DEVICE_A, KIND_DEVICE)
  queue = new Packet(queue, ID_DEVICE_A, KIND_DEVICE)
  scheduler.addHandlerTask ID_HANDLER_A, 2000, queue
  queue = new Packet(null, ID_DEVICE_B, KIND_DEVICE)
  queue = new Packet(queue, ID_DEVICE_B, KIND_DEVICE)
  queue = new Packet(queue, ID_DEVICE_B, KIND_DEVICE)
  scheduler.addHandlerTask ID_HANDLER_B, 3000, queue
  scheduler.addDeviceTask ID_DEVICE_A, 4000, null
  scheduler.addDeviceTask ID_DEVICE_B, 5000, null
  scheduler.schedule()
  if scheduler.queueCount isnt EXPECTED_QUEUE_COUNT or scheduler.holdCount isnt EXPECTED_HOLD_COUNT
    msg = "Error during execution: queueCount = " + scheduler.queueCount + ", holdCount = " + scheduler.holdCount + "."
    throw new Error(msg)
  return

###*
These two constants specify how many times a packet is queued and
how many times a task is put on hold in a correct run of richards.
They don't have any meaning a such but are characteristic of a
correct run so if the actual queue or hold count is different from
the expected there must be a bug in the implementation.
###

###*
A scheduler can be used to schedule a set of tasks based on their relative
priorities.  Scheduling is done by maintaining a list of task control blocks
which holds tasks and the data queue they are processing.
@constructor
###
Scheduler = ->
  @queueCount = 0
  @holdCount = 0
  @blocks = new Array(NUMBER_OF_IDS)
  @list = null
  @currentTcb = null
  @currentId = null
  return

###*
Add an idle task to this scheduler.
@param {int} id the identity of the task
@param {int} priority the task's priority
@param {Packet} queue the queue of work to be processed by the task
@param {int} count the number of times to schedule the task
###

###*
Add a work task to this scheduler.
@param {int} id the identity of the task
@param {int} priority the task's priority
@param {Packet} queue the queue of work to be processed by the task
###

###*
Add a handler task to this scheduler.
@param {int} id the identity of the task
@param {int} priority the task's priority
@param {Packet} queue the queue of work to be processed by the task
###

###*
Add a handler task to this scheduler.
@param {int} id the identity of the task
@param {int} priority the task's priority
@param {Packet} queue the queue of work to be processed by the task
###

###*
Add the specified task and mark it as running.
@param {int} id the identity of the task
@param {int} priority the task's priority
@param {Packet} queue the queue of work to be processed by the task
@param {Task} task the task to add
###

###*
Add the specified task to this scheduler.
@param {int} id the identity of the task
@param {int} priority the task's priority
@param {Packet} queue the queue of work to be processed by the task
@param {Task} task the task to add
###

###*
Execute the tasks managed by this scheduler.
###

###*
Release a task that is currently blocked and return the next block to run.
@param {int} id the id of the task to suspend
###

###*
Block the currently executing task and return the next task control block
to run.  The blocked task will not be made runnable until it is explicitly
released, even if new work is added to it.
###

###*
Suspend the currently executing task and return the next task control block
to run.  If new work is added to the suspended task it will be made runnable.
###

###*
Add the specified packet to the end of the worklist used by the task
associated with the packet and make the task runnable if it is currently
suspended.
@param {Packet} packet the packet to add
###

###*
A task control block manages a task and the queue of work packages associated
with it.
@param {TaskControlBlock} link the preceding block in the linked block list
@param {int} id the id of this block
@param {int} priority the priority of this block
@param {Packet} queue the queue of packages to be processed by the task
@param {Task} task the task
@constructor
###
TaskControlBlock = (link, id, priority, queue, task) ->
  @link = link
  @id = id
  @priority = priority
  @queue = queue
  @task = task
  unless queue?
    @state = STATE_SUSPENDED
  else
    @state = STATE_SUSPENDED_RUNNABLE
  return

###*
The task is running and is currently scheduled.
###

###*
The task has packets left to process.
###

###*
The task is not currently running.  The task is not blocked as such and may
be started by the scheduler.
###

###*
The task is blocked and cannot be run until it is explicitly released.
###

###*
Runs this task, if it is ready to be run, and returns the next task to run.
###

###*
Adds a packet to the worklist of this block's task, marks this as runnable if
necessary, and returns the next runnable object to run (the one
with the highest priority).
###

###*
An idle task doesn't do any work itself but cycles control between the two
device tasks.
@param {Scheduler} scheduler the scheduler that manages this task
@param {int} v1 a seed value that controls how the device tasks are scheduled
@param {int} count the number of times this task should be scheduled
@constructor
###
IdleTask = (scheduler, v1, count) ->
  @scheduler = scheduler
  @v1 = v1
  @count = count
  return

###*
A task that suspends itself after each time it has been run to simulate
waiting for data from an external device.
@param {Scheduler} scheduler the scheduler that manages this task
@constructor
###
DeviceTask = (scheduler) ->
  @scheduler = scheduler
  @v1 = null
  return

###*
A task that manipulates work packets.
@param {Scheduler} scheduler the scheduler that manages this task
@param {int} v1 a seed used to specify how work packets are manipulated
@param {int} v2 another seed used to specify how work packets are manipulated
@constructor
###
WorkerTask = (scheduler, v1, v2) ->
  @scheduler = scheduler
  @v1 = v1
  @v2 = v2
  return

###*
A task that manipulates work packets and then suspends itself.
@param {Scheduler} scheduler the scheduler that manages this task
@constructor
###
HandlerTask = (scheduler) ->
  @scheduler = scheduler
  @v1 = null
  @v2 = null
  return

# --- *
# * P a c k e t
# * --- 

###*
A simple package of data that is manipulated by the tasks.  The exact layout
of the payload data carried by a packet is not importaint, and neither is the
nature of the work performed on packets by the tasks.

Besides carrying data, packets form linked lists and are hence used both as
data and worklists.
@param {Packet} link the tail of the linked list of packets
@param {int} id an ID for this packet
@param {int} kind the type of this packet
@constructor
###
Packet = (link, id, kind) ->
  @link = link
  @id = id
  @kind = kind
  @a1 = 0
  @a2 = new Array(DATA_SIZE)
  return
Richards = new BenchmarkSuite("Richards", 35302, [new Benchmark("Richards", runRichards)])
COUNT = 1000
EXPECTED_QUEUE_COUNT = 2322
EXPECTED_HOLD_COUNT = 928
ID_IDLE = 0
ID_WORKER = 1
ID_HANDLER_A = 2
ID_HANDLER_B = 3
ID_DEVICE_A = 4
ID_DEVICE_B = 5
NUMBER_OF_IDS = 6
KIND_DEVICE = 0
KIND_WORK = 1
Scheduler::addIdleTask = (id, priority, queue, count) ->
  @addRunningTask id, priority, queue, new IdleTask(this, 1, count)
  return

Scheduler::addWorkerTask = (id, priority, queue) ->
  @addTask id, priority, queue, new WorkerTask(this, ID_HANDLER_A, 0)
  return

Scheduler::addHandlerTask = (id, priority, queue) ->
  @addTask id, priority, queue, new HandlerTask(this)
  return

Scheduler::addDeviceTask = (id, priority, queue) ->
  @addTask id, priority, queue, new DeviceTask(this)
  return

Scheduler::addRunningTask = (id, priority, queue, task) ->
  @addTask id, priority, queue, task
  @currentTcb.setRunning()
  return

Scheduler::addTask = (id, priority, queue, task) ->
  @currentTcb = new TaskControlBlock(@list, id, priority, queue, task)
  @list = @currentTcb
  @blocks[id] = @currentTcb
  return

Scheduler::schedule = ->
  @currentTcb = @list
  while @currentTcb?
    if @currentTcb.isHeldOrSuspended()
      @currentTcb = @currentTcb.link
    else
      @currentId = @currentTcb.id
      @currentTcb = @currentTcb.run()
  return

Scheduler::release = (id) ->
  tcb = @blocks[id]
  return tcb  unless tcb?
  tcb.markAsNotHeld()
  if tcb.priority > @currentTcb.priority
    tcb
  else
    @currentTcb

Scheduler::holdCurrent = ->
  @holdCount++
  @currentTcb.markAsHeld()
  @currentTcb.link

Scheduler::suspendCurrent = ->
  @currentTcb.markAsSuspended()
  @currentTcb

Scheduler::queue = (packet) ->
  t = @blocks[packet.id]
  return t  unless t?
  @queueCount++
  packet.link = null
  packet.id = @currentId
  t.checkPriorityAdd @currentTcb, packet

STATE_RUNNING = 0
STATE_RUNNABLE = 1
STATE_SUSPENDED = 2
STATE_HELD = 4
STATE_SUSPENDED_RUNNABLE = STATE_SUSPENDED | STATE_RUNNABLE
STATE_NOT_HELD = ~STATE_HELD
TaskControlBlock::setRunning = ->
  @state = STATE_RUNNING
  return

TaskControlBlock::markAsNotHeld = ->
  @state = @state & STATE_NOT_HELD
  return

TaskControlBlock::markAsHeld = ->
  @state = @state | STATE_HELD
  return

TaskControlBlock::isHeldOrSuspended = ->
  (@state & STATE_HELD) isnt 0 or (@state is STATE_SUSPENDED)

TaskControlBlock::markAsSuspended = ->
  @state = @state | STATE_SUSPENDED
  return

TaskControlBlock::markAsRunnable = ->
  @state = @state | STATE_RUNNABLE
  return

TaskControlBlock::run = ->
  packet = undefined
  if @state is STATE_SUSPENDED_RUNNABLE
    packet = @queue
    @queue = packet.link
    unless @queue?
      @state = STATE_RUNNING
    else
      @state = STATE_RUNNABLE
  else
    packet = null
  @task.run packet

TaskControlBlock::checkPriorityAdd = (task, packet) ->
  unless @queue?
    @queue = packet
    @markAsRunnable()
    return this  if @priority > task.priority
  else
    @queue = packet.addTo(@queue)
  task

TaskControlBlock::toString = ->
  "tcb { " + @task + "@" + @state + " }"

IdleTask::run = (packet) ->
  @count--
  return @scheduler.holdCurrent()  if @count is 0
  if (@v1 & 1) is 0
    @v1 = @v1 >> 1
    @scheduler.release ID_DEVICE_A
  else
    @v1 = (@v1 >> 1) ^ 0xd008
    @scheduler.release ID_DEVICE_B

IdleTask::toString = ->
  "IdleTask"

DeviceTask::run = (packet) ->
  unless packet?
    return @scheduler.suspendCurrent()  unless @v1?
    v = @v1
    @v1 = null
    @scheduler.queue v
  else
    @v1 = packet
    @scheduler.holdCurrent()

DeviceTask::toString = ->
  "DeviceTask"

WorkerTask::run = (packet) ->
  unless packet?
    @scheduler.suspendCurrent()
  else
    if @v1 is ID_HANDLER_A
      @v1 = ID_HANDLER_B
    else
      @v1 = ID_HANDLER_A
    packet.id = @v1
    packet.a1 = 0
    i = 0

    while i < DATA_SIZE
      @v2++
      @v2 = 1  if @v2 > 26
      packet.a2[i] = @v2
      i++
    @scheduler.queue packet

WorkerTask::toString = ->
  "WorkerTask"

HandlerTask::run = (packet) ->
  if packet?
    if packet.kind is KIND_WORK
      @v1 = packet.addTo(@v1)
    else
      @v2 = packet.addTo(@v2)
  if @v1?
    count = @v1.a1
    v = undefined
    if count < DATA_SIZE
      if @v2?
        v = @v2
        @v2 = @v2.link
        v.a1 = @v1.a2[count]
        @v1.a1 = count + 1
        return @scheduler.queue(v)
    else
      v = @v1
      @v1 = @v1.link
      return @scheduler.queue(v)
  @scheduler.suspendCurrent()

HandlerTask::toString = ->
  "HandlerTask"

DATA_SIZE = 4

###*
Add this packet to the end of a worklist, and return the worklist.
@param {Packet} queue the worklist to add this packet to
###
Packet::addTo = (queue) ->
  @link = null
  return this  unless queue?
  peek = undefined
  next = queue
  next = peek  while (peek = next.link)?
  next.link = this
  queue

Packet::toString = ->
  "Packet"
