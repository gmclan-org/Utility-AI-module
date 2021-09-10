# Utility AI module for Game Maker Studio 2.3+
### Modern solution for dealing with emergent behaviour.
---

## Table of contents

1. [Idea](#idea)
1. [How it works](#how-it-works)
1. [Pros and Cons](#pros-and-cons)
1. [Classes](#classes)
1. [Functions](#functions)

## Idea

Utility AI goal is to make agent pick the state that has the highest utility at
given moment (we call it score / weight / probability of occuring).

Comparing to regular finite state machines, Utility AI doesn't use fixed set of
possible changes between states, rather agent is able to change into any possible
state, but each state gets scored and one with highest probability wins and gets
selected.

For that to work each state uses things called considerations or evaluators
(which are basically considerations with different ways of combining multiple
considerations scores into one, for example: min, max, multiply and sum).
Also to achieve full modularity and reusability, most considerations would allow
to provide a custom score mapping function that remaps calcualted score, and by
that allowing user how desired output of given consideration should looks like
for given situation.

## How it works

The mechanism behind utility AI is really simple: each state contains a tree of
considerations that gets evaluated into one single score that represents the
probability of given state to occur and one with highest score value gets selected.
Altho this system assumes that scores are in range from 0 to 1, consideration can
produce any value (in the end highest one is what matters).

Imagine you have two possible states: Happy and Sad, and mood value that in
time goes from 0 to 1, and we setup considerations for these states in a way
that will cause change to state Happy whenever mood value gets above 0.5:

Create:
```gml
// For this simple test we will only care about these two states names so we
// don't override state life cycle methods.

function TestStateSad(consideration)
: UtilityState(consideration) constructor {
  name = "sad";
};

function TestStateHappy(consideration)
: UtilityState(consideration) constructor {
  name = "happy";
};

// This consideration tests how close current mood is to desired value.
// Score 1 means we have reached desired value, score 0 means we are far from
// desired value.
function TestConsiderationMood(value)
: UtilityConsideration() constructor {
  _value = value;

  static Score = function(localMemory = {}, sharedMemory = {}) {
    // First we calculate actual distance to desired value, then reverse (1 - x)
    // so when score hits 1 it means we have reached desired value.
    return 1 - abs(_value - localMemory._mood);
  }
};

// This will hold current mood value (ranging from 0 to 1).
_mood = 0;
// We setup list of all possible states for given agent with considerations that
// asks the probability of mood reaching desired values.
var states = [
  new TestStateHappy(new TestConsiderationMood(1)),
  new TestStateSad(new TestConsiderationMood(0)),
];
// Create agent from list of states and we pass self reference as agent local
// memory to let considerations read this game object state (_mood).
_agent = new UtilityAgent(states, self);
```

Step:
```gml
// Change mood value in time.
_mood += delta_time_seconds();
if (_mood > 1) {
  _mood = 0;
}
// and then tell agent to reason about its next state to change into.
_agent.Reason();
```

Draw:
```gml
// Read current state and if one is selected, then print its name and mood value
// on the screen.
var state = _agent.CurrentState();
if (!is_undefined(state)) {
  draw_set_color(c_black);
  draw_text(2, 2, state.name + ": " + string(_mood));
  draw_set_color(c_white);
}
```

## Pros and Cons

#### Pros
- Easy to start.
- Highly modular - you build your AI from smaller reusable building blocks.
- You can add, remove, replace states and considerations easily making changes
  and improvements to AI nearly instant.

#### Cons
- Hard to master - rare edge cases might produce unexpected behaviours.
- Long and hard debugging times - need to read state scores during reasoning.
- Requires some math knowledge to be able build more complex behaviours.

## Classes

### `UtilityAgent`

You can create it in the object and pass `self` as agent's memory to directly
influence game object in agent's states.

<details open>
  <summary>Properties</summary>

  `localMemory: any` - Assigned any object that holds data read by
  considerations / evaluators when processing.
</details>

<details>
  <summary>Methods</summary>

  ---

  #### `new UtilityAgent(states: [UtilityState], localMemory: any)`

  - `states: [UtilityState]` - List of all possible states that agent can choose from.
  - `localMemory: any` - Reference to object to be read by considerations /
  evaluators when processing. You can pass game object reference here to use
  it as source of agent memory.

  Creates new class instance.

  ---

  #### `CurrentState(): UtilityState|undefined`

  Returns currently active state or `undefined` otherwise.

  ---

  #### `Update(): undefined`

  Perform update on currently active state.

  ---

  #### `Reason(sharedMemory: any, reporter: UtilityReasoningReporter|undefined): UtilityState|undefined`

  - `sharedMemory: any` - Reference to shared object reference to be read by
  considerations / evaluators when processing. You can pass here for example
  this agent owning team information that has to be shared between team agents.
  - `reporter: UtilityReasoningReporter|undefined` - optional reference to
  reasoning reporter (useful for debugging to see debug messages showing
  scores of each state when state has changed).

  Performs reasoning (choosing the best suitable state to change into) by
  scoring each state by their probability to occur) and returns reference to
  choosen state.

  ---

  #### `Dispose(): undefined`

  Cleanups all created internal resources. Call it before deleting the object.
</details>

<details>
  <summary>Example</summary>

  Create:
  ```gml
  var states = [
    new ExampleStateIdle(
      // because we consider 0 as no probability for state to occur, we use
      // constant value slighty above 0 to make sure we always fallback to idle.
      new UtilityConsiderationConstant(0.01),
    ),
    new ExampleStateFollow(
      // object type to follow.
      ExampleGold,
      // target doesn't move (do not recalculate path every step).
      false,
      // this state can be choosen if we get low health or strength and there
      // is gold ore on the map. probabilities of each smaller consideration
      // are combined using simple math operations: multiplication and sum.
      new UtilityEvaluatorMultiply([
        // we get 100% probability if there is any gold on the map.
        new ExampleConsiderationObjectMinCount(ExampleGold, 1),
        // sum strength and health considerations to make them both build
        // greater probability of this state to occur.
        new UtilityEvaluatorSum([
          new ExampleConsiderationRelativeStrength(
            // as close we get to >= 20 strength difference,
            // the more probable this state is.
            20,
            // we need to remap calculated probability to its reverse
            // (1 - score) so in the end the closer to 0 strength difference is
            // the more agent wants to find gold ore to make it stronger.
            reverse_score_mapping,
          ),
          // the closest to 0 health we get, the more probable is we need to
          // find gold ore to gain more strength.
          new ExampleConsiderationHealth(100, reverse_score_mapping),
        ]),
      ]),
    ),
  ];
  _agent = new UtilityAgent(states, self);
  ```

  Clean Up:
  ```gml
  // because GML doesn't support destructors you have to call Dispose before
  // deleting the object.
  _agent.Dispose();
  delete _agent;
  ```

  Step:
  ```gml
  // call Reason to choose new state.
  _agent.Reason();
  // call Update to update currently active state.
  _agent.Update();
  ```
</details>

### `UtilityReasoningReporter`

This class instance can be passed to `UtilityAgent:Reason` method to be used
to report results of the reasoning process.

<details>
  <summary>Methods</summary>

  ---

  #### `new UtilityReasoningReporter(id: any, printer: function|undefined)`

  - `id: any` - Object that will be shown in report (preferably `string`).
  - `printer: function|undefined` - Optional reference to `function(string):any`
  that will print report lines.

  Creates new class instance.

  ---

  #### `Begin(): undefined`

  Resets internal state for further scores collection.

  ---

  #### `Push(score: real): undefined`

  - `score: real` - Score value got from state score evaluation.

  Adds score to internal collection.

  ---

  #### `Report(): undefined`

  Prints collected scores in human readable format.

  ---

  #### `Dispose(): undefined`

  Cleanups all created internal resources. Call it before deleting the object.
</details>

### `UtilityState`

User should create custom state classes that inherits from this class and
overrides methods: `OnEnter`, `OnExit`, `OnUpdate` to perform actions for
this state.

<details>
  <summary>Methods</summary>

  ---

  #### `new UtilityState(consideration: UtilityConsideration)`

  - `consideration: UtilityConsideration` - Reference to main object that inherits
  UtilityConsideration class (can be custom consideration or evaluator) that is
  used to get score how likely given state is to occur.

  Creates new class instance.

  ---

  #### `OnEnter(agent: UtilityAgent): undefined`

  - `agent: UtilityAgent` - Reference to agent that owns this state.

  Override this method to perform action when state is getting enabled.

  ---

  #### `OnExit(agent: UtilityAgent): undefined`

  - `agent: UtilityAgent` - Reference to agent that owns this state.

  Override this method to perform action when state is getting disabled.

  ---

  #### `OnUpdate(agent: UtilityAgent): undefined`

  - `agent: UtilityAgent` - Reference to agent that owns this state.

  Override this method to perform action when state is active and
  `UtilityAgent:Update` is running.

  ---

  #### `Score(localMemory: any, sharedMemory: any): real`

  - `localMemory: any` - Reference to local memory of UtilityAgent.
  - `sharedMemory: any` - Reference to shared memory passed to UtilityAgent.

  Runs main consideration / evaluator to score this state probability to occur.

  ---

  #### `Dispose(): undefined`

  Cleanups all created internal resources. Call it before deleting the object.
</details>

<details>
  <summary>Example</summary>

  ```gml
  function ExampleStateFollow(objectType, everyStep, evaluator)
  : UtilityState(evaluator) constructor {
    _objectType = objectType;
    _everyStep = everyStep;
    _target = noone;

    static OnEnter = function(agent) {
      agent.localMemory.sprite_index = ExampleUnitWalk;
      agent.localMemory._path = path_add();
    }

    static OnExit = function(agent) {
      with(agent.localMemory) {
        path_end();
      }
      if (path_exists(agent.localMemory._path)) {
        path_delete(agent.localMemory._path);
      }
      _target = noone;
    }

    static OnUpdate = function(agent) {
      if (_everyStep || !instance_exists(_target)) {
        _target = instance_nearest_adv(
          agent.localMemory.x,
          agent.localMemory.y,
          _objectType,
          agent.localMemory,
        );
        if (instance_exists(_target)) {
          path_clear_points(agent.localMemory._path);
          mp_grid_path(
            global.mpGrid,
            agent.localMemory._path,
            agent.localMemory.x,
            agent.localMemory.y,
            _target.x,
            _target.y,
            false,
          );
          with(agent.localMemory) {
            path_start(_path, 2, path_action_stop, true);
          }
        }
      }
    }
  }
  ```
</details>

### `UtilityConsideration`

User should create custom state classes that inherits from this class and
overrides `Score` method to return probability score for this consideration.

<details>
  <summary>Methods</summary>

  ---

  #### `new UtilityConsideration()`

  Creates new class instance.

  ---

  #### `Score(localMemory: any, sharedMemory: any): real`

  - `localMemory: any` - Reference to local memory of UtilityAgent.
  - `sharedMemory: any` - Reference to shared memory passed to UtilityAgent.

  Calculates probability score of this consideration.
  User should override this method in custom consideration / evaluation class.

  ---

  #### `Dispose(): undefined`

  Cleanups all created internal resources. Call it before deleting the object.
</details>

<details>
  <summary>Example</summary>

  ```gml
  function ExampleConsiderationHealth(limit = 100, mapping = no_score_mapping)
  : UtilityConsideration() constructor {
    _limit = limit;
    _mapping = mapping;

    static Score = function(localMemory = {}, sharedMemory = {}) {
      return _mapping(clamp(localMemory._health, 0, _limit) / _limit);
    }
  }
  ```
</details>

### `UtilityConsiderationConstant`

This consideration always return score from the value provided.

<details>
  <summary>Methods</summary>

  ---

  #### `new UtilityConsiderationConstant(value: real)`

  - `value: real` - Value to be used as score of this consideration.

  Creates new class instance.

  ---

  #### `Score(localMemory: any, sharedMemory: any): real`

  - `localMemory: any` - Reference to local memory of UtilityAgent.
  - `sharedMemory: any` - Reference to shared memory passed to UtilityAgent.

  Returns value passed to this consideration constructor.

  ---

  #### `Dispose(): undefined`

  Cleanups all created internal resources. Call it before deleting the object.
</details>

### `UtilityEvaluator`

This class inherits from UtilityConsideration and adds possibility for combining
multiple children considerations scores into one - inherit from this class if you
need a custom way to handle multiple sub-considerations scores.

<details>
  <summary>Methods</summary>

  ---

  #### `new UtilityEvaluator(considerations: [UtilityConsideration])`

  - `considerations: [UtilityConsideration]` - List of children considerations
  to combine.

  Creates new class instance.

  ---

  #### `Score(localMemory: any, sharedMemory: any): real`

  - `localMemory: any` - Reference to local memory of UtilityAgent.
  - `sharedMemory: any` - Reference to shared memory passed to UtilityAgent.

  When not overriden, this method returns always 1. User should override it to
  handle combining children considerations into one score value.

  ---

  #### `Dispose(): undefined`

  Cleanups all created internal resources. Call it before deleting the object.
</details>

### `UtilityEvaluatorMax`

Calculates maximum score of children considerations.

<details>
  <summary>Methods</summary>

  ---

  #### `new UtilityEvaluatorMax(considerations: [UtilityConsideration], mapping: function)`

  - `considerations: [UtilityConsideration]` - List of children considerations
  to combine.
  - `mapping: function|undefined` - Optional function to remap calculated score.

  Creates new class instance.

  ---

  #### `Score(localMemory: any, sharedMemory: any): real`

  - `localMemory: any` - Reference to local memory of UtilityAgent.
  - `sharedMemory: any` - Reference to shared memory passed to UtilityAgent.

  Returns maximum value of children considerations scores.

  ---

  #### `Dispose(): undefined`

  Cleanups all created internal resources. Call it before deleting the object.
</details>

### `UtilityEvaluatorMin`

Calculates minimum score of children considerations.

<details>
  <summary>Methods</summary>

  ---

  #### `new UtilityEvaluatorMin(considerations: [UtilityConsideration], mapping: function)`

  - `considerations: [UtilityConsideration]` - List of children considerations
  to combine.
  - `mapping: function|undefined` - Optional function to remap calculated score.

  Creates new class instance.

  ---

  #### `Score(localMemory: any, sharedMemory: any): real`

  - `localMemory: any` - Reference to local memory of UtilityAgent.
  - `sharedMemory: any` - Reference to shared memory passed to UtilityAgent.

  Returns minimum value of children considerations scores.

  ---

  #### `Dispose(): undefined`

  Cleanups all created internal resources. Call it before deleting the object.
</details>

### `UtilityEvaluatorMultiply`

Calculates product of children considerations score.

<details>
  <summary>Methods</summary>

  ---

  #### `new UtilityEvaluatorMultiply(considerations: [UtilityConsideration], mapping: function)`

  - `considerations: [UtilityConsideration]` - List of children considerations
  to combine.
  - `mapping: function|undefined` - Optional function to remap calculated score.

  Creates new class instance.

  ---

  #### `Score(localMemory: any, sharedMemory: any): real`

  - `localMemory: any` - Reference to local memory of UtilityAgent.
  - `sharedMemory: any` - Reference to shared memory passed to UtilityAgent.

  Returns product value of children considerations scores.

  ---

  #### `Dispose(): undefined`

  Cleanups all created internal resources. Call it before deleting the object.
</details>

### `UtilityEvaluatorSum`

Calculates sum of children considerations score.

<details>
  <summary>Methods</summary>

  ---

  #### `new UtilityEvaluatorSum(considerations: [UtilityConsideration], mapping: function)`

  - `considerations: [UtilityConsideration]` - List of children considerations
  to combine.
  - `mapping: function|undefined` - Optional function to remap calculated score.

  Creates new class instance.

  ---

  #### `Score(localMemory: any, sharedMemory: any): real`

  - `localMemory: any` - Reference to local memory of UtilityAgent.
  - `sharedMemory: any` - Reference to shared memory passed to UtilityAgent.

  Returns sum value of children considerations scores.

  ---

  #### `Dispose(): undefined`

  Cleanups all created internal resources. Call it before deleting the object.
</details>

## Functions

---

#### `no_score_mapping(score: real): real`

- `score: real` - Probability value.

Returns exactly the same score value as pased in input.
You can use it as default mapping argument in considerations/evaluators when
user doesn't specify any.

---

#### `reverse_score_mapping(score: real): real`

- `score: real` - Probability value.

Returns `1 - score`.

---

#### `inverse_score_mapping(score: real): real`

- `score: real` - Probability value.

Returns `1 / score`.

---

#### `inverse_reverse_score_mapping(score: real): real`

- `score: real` - Probability value.

Returns `1 - (1 / score)`.

---

#### `fast_sigmoid_score_mapping(score: real): real`

- `score: real` - Probability value.

Returns `score / (1 + abs(score))`.

Read more: [WolframAlpha](https://www.wolframalpha.com/input/?i2d=true&i=f%5C%2840%29x%5C%2841%29%3D+Divide%5Bx%2C1+%2B+Abs%5Bx%5D%5D)

---

#### `approx_sigmoid_score_mapping(score: real): real`

- `score: real` - Probability value.

Returns `score / sqrt(1 + (score * score))`.

Read more: [WolframAlpha](https://www.wolframalpha.com/input/?i2d=true&i=f%5C%2840%29x%5C%2841%29%3D+Divide%5Bx%2CSqrt%5B1+%2B+Power%5Bx%2C2%5D%5D%5D)
