function UtilityEvaluator(considerations = [])
: UtilityConsideration() constructor {
	_considerations = considerations;
	
	static Score = function(localMemory = {}, sharedMemory = {}) {
		return 1;
	}
	
	static Dispose = function() {
		if (is_undefined(_considerations)) {
			return;
		}
		for (var i = 0; i < array_length(_considerations); ++i) {
			var consideration = _considerations[i];
			if (!is_undefined(consideration)) {
				delete consideration;
			}
		}
		_considerations = undefined;
	}
}

function UtilityEvaluatorMax(considerations = [], mapping = no_score_mapping)
: UtilityEvaluator(considerations) constructor {
	_mapping = mapping;
	
	static Score = function(localMemory = {}, sharedMemory = {}) {
		var weight = -infinity;
		for (var i = 0; i < array_length(_considerations); ++i) {
			var consideration = _considerations[i];
			if (!is_undefined(consideration)) {
				weight = max(weight, consideration.Score(localMemory, sharedMemory));
			}
		}
		return _mapping(weight);
	}
}

function UtilityEvaluatorMin(considerations = [], mapping = no_score_mapping)
: UtilityEvaluator(considerations) constructor {
	_mapping = mapping;
	
	static Score = function(localMemory = {}, sharedMemory = {}) {
		var weight = infinity;
		for (var i = 0; i < array_length(_considerations); ++i) {
			var consideration = _considerations[i];
			if (!is_undefined(consideration)) {
				weight = min(weight, consideration.Score(localMemory, sharedMemory));
			}
		}
		return _mapping(weight);
	}
}

function UtilityEvaluatorMultiply(considerations = [], mapping = no_score_mapping)
: UtilityEvaluator(considerations) constructor {
	_mapping = mapping;
	
	static Score = function(localMemory = {}, sharedMemory = {}) {
		var weight = 1;
		for (var i = 0; i < array_length(_considerations); ++i) {
			var consideration = _considerations[i];
			if (!is_undefined(consideration)) {
				weight *= consideration.Score(localMemory, sharedMemory);
			}
		}
		return _mapping(weight);
	}
}

function UtilityEvaluatorSum(considerations = [], mapping = no_score_mapping)
: UtilityEvaluator(considerations) constructor {
	_mapping = mapping;
	
	static Score = function(localMemory = {}, sharedMemory = {}) {
		var weight = 0;
		for (var i = 0; i < array_length(_considerations); ++i) {
			var consideration = _considerations[i];
			if (!is_undefined(consideration)) {
				weight += consideration.Score(localMemory, sharedMemory);
			}
		}
		return _mapping(weight);
	}
}
