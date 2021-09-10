draw_self();

var hp = clamp(_health / 100, 0, 1);
var mp = clamp(_strength / 100, 0, 1);

draw_set_alpha(0.7);
draw_set_color(c_red);
draw_rectangle(x - 16, y - 28, x + lerp(-16, 16, hp), y - 24, false);
draw_set_color(c_white);
draw_rectangle(x - 16, y - 28, x + 16, y - 24, true);
draw_set_color(c_blue);
draw_rectangle(x - 16, y - 24, x + lerp(-16, 16, mp), y - 20, false);
draw_set_color(c_white);
draw_rectangle(x - 16, y - 24, x + 16, y - 20, true);
draw_set_alpha(1);
