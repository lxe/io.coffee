# Copyright 2008 the V8 project authors. All rights reserved.
# Copyright 1996 John Maloney and Mario Wolczko.

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

# This implementation of the DeltaBlue benchmark is derived
# from the Smalltalk implementation by John Maloney and Mario
# Wolczko. Some parts have been translated directly, whereas
# others have been modified more aggresively to make it feel
# more like a JavaScript program.

###*
A JavaScript implementation of the DeltaBlue constraint-solving
algorithm, as described in:

"The DeltaBlue Algorithm: An Incremental Constraint Hierarchy Solver"
Bjorn N. Freeman-Benson and John Maloney
January 1990 Communications of the ACM,
also available as University of Washington TR 89-08-06.

Beware: this benchmark is written in a grotesque style where
the constraint model is built by side-effects from constructors.
I've kept it this way to avoid deviating too much from the original
implementation.
###

# --- O b j e c t   M o d e l --- 
OrderedCollection = ->
  @elms = new Array()
  return

# --- *
# * S t r e n g t h
# * --- 

###*
Strengths are used to measure the relative importance of constraints.
New strengths may be inserted in the strength hierarchy without
disrupting current constraints.  Strengths cannot be created outside
this class, so pointer comparison can be used for value comparison.
###
Strength = (strengthValue, name) ->
  @strengthValue = strengthValue
  @name = name
  return

# Strength constants.

# --- *
# * C o n s t r a i n t
# * --- 

###*
An abstract class representing a system-maintainable relationship
(or "constraint") between a set of variables. A constraint supplies
a strength instance variable; concrete subclasses provide a means
of storing the constrained variables and other information required
to represent a constraint.
###
Constraint = (strength) ->
  @strength = strength
  return

###*
Activate this constraint and attempt to satisfy it.
###

###*
Attempt to find a way to enforce this constraint. If successful,
record the solution, perhaps modifying the current dataflow
graph. Answer the constraint that this constraint overrides, if
there is one, or nil, if there isn't.
Assume: I am not already satisfied.
###

###*
Normal constraints are not input constraints.  An input constraint
is one that depends on external state, such as the mouse, the
keybord, a clock, or some arbitraty piece of imperative code.
###

# --- *
# * U n a r y   C o n s t r a i n t
# * --- 

###*
Abstract superclass for constraints having a single possible output
variable.
###
UnaryConstraint = (v, strength) ->
  UnaryConstraint.superConstructor.call this, strength
  @myOutput = v
  @satisfied = false
  @addConstraint()
  return

###*
Adds this constraint to the constraint graph
###

###*
Decides if this constraint can be satisfied and records that
decision.
###

###*
Returns true if this constraint is satisfied in the current solution.
###

# has no inputs

###*
Returns the current output variable.
###

###*
Calculate the walkabout strength, the stay flag, and, if it is
'stay', the value for the current output of this constraint. Assume
this constraint is satisfied.
###
# Stay optimization

###*
Records that this constraint is unsatisfied
###

# --- *
# * S t a y   C o n s t r a i n t
# * --- 

###*
Variables that should, with some level of preference, stay the same.
Planners may exploit the fact that instances, if satisfied, will not
change their output during plan execution.  This is called "stay
optimization".
###
StayConstraint = (v, str) ->
  StayConstraint.superConstructor.call this, v, str
  return

# Stay constraints do nothing

# --- *
# * E d i t   C o n s t r a i n t
# * --- 

###*
A unary input constraint used to mark a variable that the client
wishes to change.
###
EditConstraint = (v, str) ->
  EditConstraint.superConstructor.call this, v, str
  return

###*
Edits indicate that a variable is to be changed by imperative code.
###

# Edit constraints do nothing

# --- *
# * B i n a r y   C o n s t r a i n t
# * --- 

###*
Abstract superclass for constraints having two possible output
variables.
###
BinaryConstraint = (var1, var2, strength) ->
  BinaryConstraint.superConstructor.call this, strength
  @v1 = var1
  @v2 = var2
  @direction = Direction.NONE
  @addConstraint()
  return

###*
Decides if this constraint can be satisfied and which way it
should flow based on the relative strength of the variables related,
and record that decision.
###

###*
Add this constraint to the constraint graph
###

###*
Answer true if this constraint is satisfied in the current solution.
###

###*
Mark the input variable with the given mark.
###

###*
Returns the current input variable
###

###*
Returns the current output variable
###

###*
Calculate the walkabout strength, the stay flag, and, if it is
'stay', the value for the current output of this
constraint. Assume this constraint is satisfied.
###

###*
Record the fact that this constraint is unsatisfied.
###

# --- *
# * S c a l e   C o n s t r a i n t
# * --- 

###*
Relates two variables by the linear scaling relationship: "v2 =
(v1 * scale) + offset". Either v1 or v2 may be changed to maintain
this relationship but the scale factor and offset are considered
read-only.
###
ScaleConstraint = (src, scale, offset, dest, strength) ->
  @direction = Direction.NONE
  @scale = scale
  @offset = offset
  ScaleConstraint.superConstructor.call this, src, dest, strength
  return

###*
Adds this constraint to the constraint graph.
###

###*
Enforce this constraint. Assume that it is satisfied.
###

###*
Calculate the walkabout strength, the stay flag, and, if it is
'stay', the value for the current output of this constraint. Assume
this constraint is satisfied.
###

# --- *
# * E q u a l i t  y   C o n s t r a i n t
# * --- 

###*
Constrains two variables to have the same value.
###
EqualityConstraint = (var1, var2, strength) ->
  EqualityConstraint.superConstructor.call this, var1, var2, strength
  return

###*
Enforce this constraint. Assume that it is satisfied.
###

# --- *
# * V a r i a b l e
# * --- 

###*
A constrained variable. In addition to its value, it maintain the
structure of the constraint graph, the current dataflow graph, and
various parameters of interest to the DeltaBlue incremental
constraint solver.
###
Variable = (name, initialValue) ->
  @value = initialValue or 0
  @constraints = new OrderedCollection()
  @determinedBy = null
  @mark = 0
  @walkStrength = Strength.WEAKEST
  @stay = true
  @name = name
  return

###*
Add the given constraint to the set of all constraints that refer
this variable.
###

###*
Removes all traces of c from this variable.
###

# --- *
# * P l a n n e r
# * --- 

###*
The DeltaBlue planner
###
Planner = ->
  @currentMark = 0
  return

###*
Attempt to satisfy the given constraint and, if successful,
incrementally update the dataflow graph.  Details: If satifying
the constraint is successful, it may override a weaker constraint
on its output. The algorithm attempts to resatisfy that
constraint using some other method. This process is repeated
until either a) it reaches a variable that was not previously
determined by any constraint or b) it reaches a constraint that
is too weak to be satisfied using any of its methods. The
variables of constraints that have been processed are marked with
a unique mark value so that we know where we've been. This allows
the algorithm to avoid getting into an infinite loop even if the
constraint graph has an inadvertent cycle.
###

###*
Entry point for retracting a constraint. Remove the given
constraint and incrementally update the dataflow graph.
Details: Retracting the given constraint may allow some currently
unsatisfiable downstream constraint to be satisfied. We therefore collect
a list of unsatisfied downstream constraints and attempt to
satisfy each one in turn. This list is traversed by constraint
strength, strongest first, as a heuristic for avoiding
unnecessarily adding and then overriding weak constraints.
Assume: c is satisfied.
###

###*
Select a previously unused mark value.
###

###*
Extract a plan for resatisfaction starting from the given source
constraints, usually a set of input constraints. This method
assumes that stay optimization is desired; the plan will contain
only constraints whose output variables are not stay. Constraints
that do no computation, such as stay and edit constraints, are
not included in the plan.
Details: The outputs of a constraint are marked when it is added
to the plan under construction. A constraint may be appended to
the plan when all its input variables are known. A variable is
known if either a) the variable is marked (indicating that has
been computed by a constraint appearing earlier in the plan), b)
the variable is 'stay' (i.e. it is a constant at plan execution
time), or c) the variable is not determined by any
constraint. The last provision is for past states of history
variables, which are not stay but which are also not computed by
any constraint.
Assume: sources are all satisfied.
###

###*
Extract a plan for resatisfying starting from the output of the
given constraints, usually a set of input constraints.
###

# not in plan already and eligible for inclusion

###*
Recompute the walkabout strengths and stay flags of all variables
downstream of the given constraint and recompute the actual
values of all variables whose stay flag is true. If a cycle is
detected, remove the given constraint and answer
false. Otherwise, answer true.
Details: Cycles are detected when a marked variable is
encountered downstream of the given constraint. The sender is
assumed to have marked the inputs of the given constraint with
the given mark. Thus, encountering a marked node downstream of
the output constraint means that there is a path from the
constraint's output to one of its inputs.
###

###*
Update the walkabout strengths and stay flags of all variables
downstream of the given constraint. Answer a collection of
unsatisfied constraints sorted in order of decreasing strength.
###

# --- *
# * P l a n
# * --- 

###*
A Plan is an ordered list of constraints to be executed in sequence
to resatisfy all currently satisfiable constraints in the face of
one or more changing inputs.
###
Plan = ->
  @v = new OrderedCollection()
  return

# --- *
# * M a i n
# * --- 

###*
This is the standard DeltaBlue benchmark. A long chain of equality
constraints is constructed with a stay constraint on one end. An
edit constraint is then added to the opposite end and the time is
measured for adding and removing this constraint, and extracting
and executing a constraint satisfaction plan. There are two cases.
In case 1, the added constraint is stronger than the stay
constraint and values must propagate down the entire length of the
chain. In case 2, the added constraint is weaker than the stay
constraint so it cannot be accomodated. The cost in this case is,
of course, very low. Typical situations lie somewhere between these
two extremes.
###
chainTest = (n) ->
  planner = new Planner()
  prev = null
  first = null
  last = null
  
  # Build chain of n equality constraints
  i = 0

  while i <= n
    name = "v" + i
    v = new Variable(name)
    new EqualityConstraint(prev, v, Strength.REQUIRED)  if prev?
    first = v  if i is 0
    last = v  if i is n
    prev = v
    i++
  new StayConstraint(last, Strength.STRONG_DEFAULT)
  edit = new EditConstraint(first, Strength.PREFERRED)
  edits = new OrderedCollection()
  edits.add edit
  plan = planner.extractPlanFromConstraints(edits)
  i = 0

  while i < 100
    first.value = i
    plan.execute()
    alert "Chain test failed."  unless last.value is i
    i++
  return

###*
This test constructs a two sets of variables related to each
other by a simple linear transformation (scale and offset). The
time is measured to change a variable on either side of the
mapping and to change the scale and offset factors.
###
projectionTest = (n) ->
  planner = new Planner()
  scale = new Variable("scale", 10)
  offset = new Variable("offset", 1000)
  src = null
  dst = null
  dests = new OrderedCollection()
  i = 0

  while i < n
    src = new Variable("src" + i, i)
    dst = new Variable("dst" + i, i)
    dests.add dst
    new StayConstraint(src, Strength.NORMAL)
    new ScaleConstraint(src, scale, offset, dst, Strength.REQUIRED)
    i++
  change src, 17
  alert "Projection 1 failed"  unless dst.value is 1170
  change dst, 1050
  alert "Projection 2 failed"  unless src.value is 5
  change scale, 5
  i = 0

  while i < n - 1
    alert "Projection 3 failed"  unless dests.at(i).value is i * 5 + 1000
    i++
  change offset, 2000
  i = 0

  while i < n - 1
    alert "Projection 4 failed"  unless dests.at(i).value is i * 5 + 2000
    i++
  return
change = (v, newValue) ->
  edit = new EditConstraint(v, Strength.PREFERRED)
  edits = new OrderedCollection()
  edits.add edit
  plan = planner.extractPlanFromConstraints(edits)
  i = 0

  while i < 10
    v.value = newValue
    plan.execute()
    i++
  edit.destroyConstraint()
  return

# Global variable holding the current planner.
deltaBlue = ->
  chainTest 100
  projectionTest 100
  return
DeltaBlue = new BenchmarkSuite("DeltaBlue", 66118, [new Benchmark("DeltaBlue", deltaBlue)])
Object::inheritsFrom = (shuper) ->
  Inheriter = ->
  Inheriter:: = shuper::
  @:: = new Inheriter()
  @superConstructor = shuper
  return

OrderedCollection::add = (elm) ->
  @elms.push elm
  return

OrderedCollection::at = (index) ->
  @elms[index]

OrderedCollection::size = ->
  @elms.length

OrderedCollection::removeFirst = ->
  @elms.pop()

OrderedCollection::remove = (elm) ->
  index = 0
  skipped = 0
  i = 0

  while i < @elms.length
    value = @elms[i]
    unless value is elm
      @elms[index] = value
      index++
    else
      skipped++
    i++
  i = 0

  while i < skipped
    @elms.pop()
    i++
  return

Strength.stronger = (s1, s2) ->
  s1.strengthValue < s2.strengthValue

Strength.weaker = (s1, s2) ->
  s1.strengthValue > s2.strengthValue

Strength.weakestOf = (s1, s2) ->
  (if @weaker(s1, s2) then s1 else s2)

Strength.strongest = (s1, s2) ->
  (if @stronger(s1, s2) then s1 else s2)

Strength::nextWeaker = ->
  switch @strengthValue
    when 0
      Strength.STRONG_PREFERRED
    when 1
      Strength.PREFERRED
    when 2
      Strength.STRONG_DEFAULT
    when 3
      Strength.NORMAL
    when 4
      Strength.WEAK_DEFAULT
    when 5
      Strength.WEAKEST

Strength.REQUIRED = new Strength(0, "required")
Strength.STRONG_PREFERRED = new Strength(1, "strongPreferred")
Strength.PREFERRED = new Strength(2, "preferred")
Strength.STRONG_DEFAULT = new Strength(3, "strongDefault")
Strength.NORMAL = new Strength(4, "normal")
Strength.WEAK_DEFAULT = new Strength(5, "weakDefault")
Strength.WEAKEST = new Strength(6, "weakest")
Constraint::addConstraint = ->
  @addToGraph()
  planner.incrementalAdd this
  return

Constraint::satisfy = (mark) ->
  @chooseMethod mark
  unless @isSatisfied()
    alert "Could not satisfy a required constraint!"  if @strength is Strength.REQUIRED
    return null
  @markInputs mark
  out = @output()
  overridden = out.determinedBy
  overridden.markUnsatisfied()  if overridden?
  out.determinedBy = this
  alert "Cycle encountered"  unless planner.addPropagate(this, mark)
  out.mark = mark
  overridden

Constraint::destroyConstraint = ->
  if @isSatisfied()
    planner.incrementalRemove this
  else
    @removeFromGraph()
  return

Constraint::isInput = ->
  false

UnaryConstraint.inheritsFrom Constraint
UnaryConstraint::addToGraph = ->
  @myOutput.addConstraint this
  @satisfied = false
  return

UnaryConstraint::chooseMethod = (mark) ->
  @satisfied = (@myOutput.mark isnt mark) and Strength.stronger(@strength, @myOutput.walkStrength)
  return

UnaryConstraint::isSatisfied = ->
  @satisfied

UnaryConstraint::markInputs = (mark) ->

UnaryConstraint::output = ->
  @myOutput

UnaryConstraint::recalculate = ->
  @myOutput.walkStrength = @strength
  @myOutput.stay = not @isInput()
  @execute()  if @myOutput.stay
  return

UnaryConstraint::markUnsatisfied = ->
  @satisfied = false
  return

UnaryConstraint::inputsKnown = ->
  true

UnaryConstraint::removeFromGraph = ->
  @myOutput.removeConstraint this  if @myOutput?
  @satisfied = false
  return

StayConstraint.inheritsFrom UnaryConstraint
StayConstraint::execute = ->

EditConstraint.inheritsFrom UnaryConstraint
EditConstraint::isInput = ->
  true

EditConstraint::execute = ->

Direction = new Object()
Direction.NONE = 0
Direction.FORWARD = 1
Direction.BACKWARD = -1
BinaryConstraint.inheritsFrom Constraint
BinaryConstraint::chooseMethod = (mark) ->
  @direction = (if (@v2.mark isnt mark and Strength.stronger(@strength, @v2.walkStrength)) then Direction.FORWARD else Direction.NONE)  if @v1.mark is mark
  @direction = (if (@v1.mark isnt mark and Strength.stronger(@strength, @v1.walkStrength)) then Direction.BACKWARD else Direction.NONE)  if @v2.mark is mark
  if Strength.weaker(@v1.walkStrength, @v2.walkStrength)
    @direction = (if Strength.stronger(@strength, @v1.walkStrength) then Direction.BACKWARD else Direction.NONE)
  else
    @direction = (if Strength.stronger(@strength, @v2.walkStrength) then Direction.FORWARD else Direction.BACKWARD)
  return

BinaryConstraint::addToGraph = ->
  @v1.addConstraint this
  @v2.addConstraint this
  @direction = Direction.NONE
  return

BinaryConstraint::isSatisfied = ->
  @direction isnt Direction.NONE

BinaryConstraint::markInputs = (mark) ->
  @input().mark = mark
  return

BinaryConstraint::input = ->
  (if (@direction is Direction.FORWARD) then @v1 else @v2)

BinaryConstraint::output = ->
  (if (@direction is Direction.FORWARD) then @v2 else @v1)

BinaryConstraint::recalculate = ->
  ihn = @input()
  out = @output()
  out.walkStrength = Strength.weakestOf(@strength, ihn.walkStrength)
  out.stay = ihn.stay
  @execute()  if out.stay
  return

BinaryConstraint::markUnsatisfied = ->
  @direction = Direction.NONE
  return

BinaryConstraint::inputsKnown = (mark) ->
  i = @input()
  i.mark is mark or i.stay or not i.determinedBy?

BinaryConstraint::removeFromGraph = ->
  @v1.removeConstraint this  if @v1?
  @v2.removeConstraint this  if @v2?
  @direction = Direction.NONE
  return

ScaleConstraint.inheritsFrom BinaryConstraint
ScaleConstraint::addToGraph = ->
  ScaleConstraint.superConstructor::addToGraph.call this
  @scale.addConstraint this
  @offset.addConstraint this
  return

ScaleConstraint::removeFromGraph = ->
  ScaleConstraint.superConstructor::removeFromGraph.call this
  @scale.removeConstraint this  if @scale?
  @offset.removeConstraint this  if @offset?
  return

ScaleConstraint::markInputs = (mark) ->
  ScaleConstraint.superConstructor::markInputs.call this, mark
  @scale.mark = @offset.mark = mark
  return

ScaleConstraint::execute = ->
  if @direction is Direction.FORWARD
    @v2.value = @v1.value * @scale.value + @offset.value
  else
    @v1.value = (@v2.value - @offset.value) / @scale.value
  return

ScaleConstraint::recalculate = ->
  ihn = @input()
  out = @output()
  out.walkStrength = Strength.weakestOf(@strength, ihn.walkStrength)
  out.stay = ihn.stay and @scale.stay and @offset.stay
  @execute()  if out.stay
  return

EqualityConstraint.inheritsFrom BinaryConstraint
EqualityConstraint::execute = ->
  @output().value = @input().value
  return

Variable::addConstraint = (c) ->
  @constraints.add c
  return

Variable::removeConstraint = (c) ->
  @constraints.remove c
  @determinedBy = null  if @determinedBy is c
  return

Planner::incrementalAdd = (c) ->
  mark = @newMark()
  overridden = c.satisfy(mark)
  overridden = overridden.satisfy(mark)  while overridden?
  return

Planner::incrementalRemove = (c) ->
  out = c.output()
  c.markUnsatisfied()
  c.removeFromGraph()
  unsatisfied = @removePropagateFrom(out)
  strength = Strength.REQUIRED
  loop
    i = 0

    while i < unsatisfied.size()
      u = unsatisfied.at(i)
      @incrementalAdd u  if u.strength is strength
      i++
    strength = strength.nextWeaker()
    break unless strength isnt Strength.WEAKEST
  return

Planner::newMark = ->
  ++@currentMark

Planner::makePlan = (sources) ->
  mark = @newMark()
  plan = new Plan()
  todo = sources
  while todo.size() > 0
    c = todo.removeFirst()
    if c.output().mark isnt mark and c.inputsKnown(mark)
      plan.addConstraint c
      c.output().mark = mark
      @addConstraintsConsumingTo c.output(), todo
  plan

Planner::extractPlanFromConstraints = (constraints) ->
  sources = new OrderedCollection()
  i = 0

  while i < constraints.size()
    c = constraints.at(i)
    sources.add c  if c.isInput() and c.isSatisfied()
    i++
  @makePlan sources

Planner::addPropagate = (c, mark) ->
  todo = new OrderedCollection()
  todo.add c
  while todo.size() > 0
    d = todo.removeFirst()
    if d.output().mark is mark
      @incrementalRemove c
      return false
    d.recalculate()
    @addConstraintsConsumingTo d.output(), todo
  true

Planner::removePropagateFrom = (out) ->
  out.determinedBy = null
  out.walkStrength = Strength.WEAKEST
  out.stay = true
  unsatisfied = new OrderedCollection()
  todo = new OrderedCollection()
  todo.add out
  while todo.size() > 0
    v = todo.removeFirst()
    i = 0

    while i < v.constraints.size()
      c = v.constraints.at(i)
      unsatisfied.add c  unless c.isSatisfied()
      i++
    determining = v.determinedBy
    i = 0

    while i < v.constraints.size()
      next = v.constraints.at(i)
      if next isnt determining and next.isSatisfied()
        next.recalculate()
        todo.add next.output()
      i++
  unsatisfied

Planner::addConstraintsConsumingTo = (v, coll) ->
  determining = v.determinedBy
  cc = v.constraints
  i = 0

  while i < cc.size()
    c = cc.at(i)
    coll.add c  if c isnt determining and c.isSatisfied()
    i++
  return

Plan::addConstraint = (c) ->
  @v.add c
  return

Plan::size = ->
  @v.size()

Plan::constraintAt = (index) ->
  @v.at index

Plan::execute = ->
  i = 0

  while i < @size()
    c = @constraintAt(i)
    c.execute()
    i++
  return

planner = null
