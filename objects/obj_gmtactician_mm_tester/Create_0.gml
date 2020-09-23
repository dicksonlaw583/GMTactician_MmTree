///@desc Asynchronous testing
var state = new TicTacToeState([
	1, -1, -1,
	-1, -1, -1,
	-1, -1, -1,
	0
]);
mm = new TicTacToeMmTree(state, 6);
mmDaemon = mm.evaluateInBackground(function(_move) {
	var _correctMove = 4;
	assert_equal(_move, _correctMove, "Minimax asynchronous evaluate failed to find best move!");
	if (_move == _correctMove) {
		layer_background_blend(layer_background_get_id(layer_get_id("Background")), c_green);
		show_debug_message("Minimax asynchronous evaluate responded correctly!");
	}
	instance_destroy();
});
