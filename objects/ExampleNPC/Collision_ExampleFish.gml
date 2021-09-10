if (_health < 100) {
	_health += 10;
	instance_destroy(other);
}
