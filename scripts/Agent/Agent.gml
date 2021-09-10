function UtilityAgent(states = [], _localMemory = {}) constructor {
	localMemory = _localMemory;
	_states = states;
	_currentState = undefined;
	
	static CurrentState = function() {
		return _currentState;
	}
	
	static Update = function() {
		if (!is_undefined(_currentState)) {
			_currentState.OnUpdate(self);
		}
	}
	
	static Reason = function(sharedMemory = {}, reporter = undefined) {
		if (is_undefined(_states)) {
			return;
		}
		if (!is_undefined(reporter)) {
			reporter.Begin();
		}
		var winState = undefined;
		var winScore = -infinity;
		for (var i = 0; i < array_length(_states); ++i) {
			var state = _states[i];
			var weight = state.Score(localMemory, sharedMemory);
			if (!is_undefined(reporter)) {
				reporter.Push(weight);
			}
			if (weight > winScore) {
				winState = state;
				winScore = weight;
			}
		}
		if (_currentState != winState) {
			if (!is_undefined(_currentState)) {
				_currentState.OnExit(self);
			}
			_currentState = winState;
			if (!is_undefined(_currentState)) {
				_currentState.OnEnter(self);
			}
			if (!is_undefined(reporter)) {
				reporter.Report();
			}
		}
		return _currentState;
	}
	
	static Dispose = function() {
		if (is_undefined(_states)) {
			return;
		}
		for (var i = 0; i < array_length(_states); ++i) {
			var state = _states[i];
			state.Dispose();
			delete state;
		}
		_states = undefined;
		_currentState = undefined;
	}
}

function UtilityReasoningReporter(id, printer = show_debug_message) constructor {
	_id = string(id);
	_printer = printer;
	_stats = ds_list_create();
	
	static Begin = function() {
		if (!is_undefined(_stats)) {
			ds_list_clear(_stats);
		}
	}
	
	static Push = function(score) {
		if (!is_undefined(_stats)) {
			ds_list_add(_stats, score);
		}
	}
	
	static Report = function() {
		if (is_undefined(_stats)) {
			return;
		}
		var count = ds_list_size(_stats);
		if (count > 0) {
			_printer("=== REASONING START: " + _id);
			var winScore = -infinity;
			var winIndex = -1;
			for (var i = 0; i < count; ++i) {
				var weight = ds_list_find_value(_stats, i);
				_printer("=== STATE #" + string(i) + " SCORE: " + string_format(weight, 0, 10));
				if (weight > winScore) {
					winScore = weight;
					winIndex = i;
				}
			}
			_printer("=== REASONING WIN: " + string(winIndex));
		}
	}
	
	static Dispose = function() {
		if (!is_undefined(_stats)) {
			ds_list_destroy(_stats);
			_stats = undefined;
		}
	}
}