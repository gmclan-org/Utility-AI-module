function ExampleConsiderationHealth(limit = 100, mapping = no_score_mapping)
: UtilityConsideration() constructor {
	_limit = limit;
	_mapping = mapping;
	
	static Score = function(localMemory = {}, sharedMemory = {}) {
		return _mapping(clamp(localMemory._health, 0, _limit) / _limit);
	}
}

function ExampleConsiderationRelativeStrength(limit = 100, mapping = no_score_mapping)
: UtilityConsideration() constructor {
	_limit = limit;
	_mapping = mapping;
	
	static Score = function(localMemory = {}, sharedMemory = {}) {
		var diff = 0;
		var found = instance_nearest_adv(localMemory.x, localMemory.y, ExampleNPC, localMemory);
		if (instance_exists(found)) {
			diff = localMemory._strength - found._strength;
		}
		return _mapping(clamp(diff, 0, _limit) / _limit);
	}
}

function ExampleConsiderationObjectInRange(objectType, rangeNear = 32, rangeFar = 64, mapping = no_score_mapping)
: UtilityConsideration() constructor {
	_objectType = objectType;
	_rangeNear = rangeNear;
	_rangeFar = rangeFar;
	_mapping = mapping;

	static Score = function(localMemory = {}, sharedMemory = {}) {
		var dist = infinity;
		var found = instance_nearest_adv(localMemory.x, localMemory.y, _objectType, localMemory);
		if (instance_exists(found)) {
			dist = point_distance(localMemory.x, localMemory.y, found.x, found.y);
		}
		return _mapping(dist >= _rangeNear && dist <= _rangeFar ? 1 : 0);
	}
}

function ExampleConsiderationObjectMinCount(objectType, count, mapping = no_score_mapping)
: UtilityConsideration() constructor {
	_objectType = objectType;
	_count = count;
	_mapping = mapping;

	static Score = function(localMemory = {}, sharedMemory = {}) {
		return _mapping(instance_number_that_works(_objectType) < _count ? 0 : 1);
	}
}
