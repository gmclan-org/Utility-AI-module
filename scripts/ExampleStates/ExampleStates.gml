function ExampleStateIdle(consideration)
: UtilityState(consideration) constructor {
	static OnEnter = function(agent) {
		agent.localMemory.sprite_index = ExampleUnitIdle;
	}
}

function ExampleStateAttack(objectType, delay, consideration)
: UtilityState(consideration) constructor {
	_objectType = objectType;
	_target = noone;
	_delay = delay;
	_accum = 0;
	
	static OnEnter = function(agent) {
		agent.localMemory.sprite_index = ExampleUnitAttack;
	}
	
	static OnExit = function(agent) {
		_target = noone;
	}
	
	static OnUpdate = function(agent) {
		_accum += delta_time_seconds();
		if (_accum >= _delay) {
			_accum = 0;
			if (instance_exists(_target)) {
				_target._health -= agent.localMemory._strength;
			} else {
				_target = instance_nearest_adv(
					agent.localMemory.x,
					agent.localMemory.y,
					_objectType,
					agent.localMemory,
				);
			}
		}
	}
}

function ExampleStateFollow(objectType, everyStep, consideration)
: UtilityState(consideration) constructor {
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
