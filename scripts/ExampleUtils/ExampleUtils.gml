function instance_nearest_adv(px, py, obj, exclude = noone) {
	if (instance_exists(exclude)) {
		instance_deactivate_object(exclude);
		var found = instance_nearest(px, py, obj);
		instance_activate_object(exclude);
		return found;
	} else {
		return instance_nearest(px, py, obj);
	}
}

function delta_time_seconds() {
	return delta_time * 0.000001;
}

function instance_number_that_works(objectType) {
	var c = 0;
	with(objectType) {
		++c;
	}
	return c;
}