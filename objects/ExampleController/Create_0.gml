randomize();
global.mpGrid = mp_grid_create(0, 0, room_width/ 32, room_height / 32, 32, 32);
mp_grid_add_instances(global.mpGrid, ExampleNonTraversal, false);
mp_grid_add_instances(global.mpGrid, ExampleBuilding, false);

// mood test
function TestStateSad(consideration)
: UtilityState(consideration) constructor {
	name = "sad";
};

function TestStateHappy(consideration)
: UtilityState(consideration) constructor {
	name = "happy";
};

function TestConsiderationMood(value)
: UtilityConsideration() constructor {
	_value = value;
	
	static Score = function(localMemory = {}, sharedMemory = {}) {
		return 1 - abs(_value - localMemory._mood);
	}
};

_mood = 0;
var states = [
	new TestStateHappy(new TestConsiderationMood(1)),
	new TestStateSad(new TestConsiderationMood(0)),
];
_agent = new UtilityAgent(states, self);
