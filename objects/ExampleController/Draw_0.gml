var state = _agent.CurrentState();
if (!is_undefined(state)) {
	draw_set_color(c_black);
	draw_text(2, 2, state.name + ": " + string(_mood));
	draw_set_color(c_white);
}
