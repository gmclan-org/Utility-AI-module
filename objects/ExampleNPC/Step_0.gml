_reasonAccum += delta_time_seconds();
if (_reasonAccum >= _reasonDelay) {
	_reasonAccum = 0;
	_agent.Reason();
}
_agent.Update();

if (_health <= 0) {
	instance_destroy();
}
