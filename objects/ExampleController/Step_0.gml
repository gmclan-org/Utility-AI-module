_mood += delta_time_seconds();
if (_mood > 1) {
	_mood = 0;
}
_agent.Reason();
