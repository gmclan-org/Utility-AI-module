function UtilityState(consideration) constructor {
	if (is_undefined(consideration)) {
		throw ("consideration cannot be unrefined!");
	}
	
	_consideration = consideration;
	
	static OnEnter = function(agent) {}
	static OnExit = function(agent) {}
	static OnUpdate = function(agent) {}
	
	static Score = function(localMemory = {}, sharedMemory = {}) {
		if (!is_undefined(_consideration)) {
			return _consideration.Score(localMemory, sharedMemory);
		} else {
			return 1;
		}
	}
	
	static Dispose = function() {
		if (!is_undefined(_consideration)) {
			_consideration.Dispose();
			delete _consideration;
			_consideration = undefined;
		}
	}
}
