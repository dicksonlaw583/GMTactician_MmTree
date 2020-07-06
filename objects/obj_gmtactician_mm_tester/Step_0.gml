// Check for response
if (mm2.ready) {
	var _correctMove = 4;
	var _move = mm2.getBestMove();
	assert_equal(_move, _correctMove, "Minimax asynchronous evaluate failed to find best move!");
	if (_move == _correctMove) {
		layer_background_blend(layer_background_get_id(layer_get_id("Background")), c_green);
		show_debug_message("Minimax asynchronous evaluate responded correctly!");
	}
	instance_destroy();
}
