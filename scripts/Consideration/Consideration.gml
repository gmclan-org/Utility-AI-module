function UtilityConsideration() constructor {
	static Score = function(localMemory = {}, sharedMemory = {}) {
		return 0;
	}
	
	static Dispose = function() {}
}

function UtilityConsiderationConstant(value)
: UtilityConsideration() constructor {
	_value = value;
	
	static Score = function(localMemory = {}, sharedMemory = {}) {
		return _value;
	}
}
