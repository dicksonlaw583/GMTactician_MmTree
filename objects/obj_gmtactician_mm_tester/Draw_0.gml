///@desc Draw tree progress
if (instance_exists(mmDaemon)) {
	draw_healthbar(x, y, x+100, y+16, 100*mmDaemon.progress, c_black, c_red, c_lime, 0, true, true);
}
