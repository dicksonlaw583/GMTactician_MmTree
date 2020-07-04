///@func gmta_mm_test_all()
function gmta_mm_test_all() {
	global.__test_fails__ = 0;
	var timeA = current_time;
	
	/** vv Place tests here vv **/
	// Synchronous evaluate
	var state = new TicTacToeState([
		0, -1, -1,
		-1, -1, -1,
		-1, -1, -1,
		1
	]);
	var mm = new TicTacToeMmTree(state, 6);
	mm.evaluate();
	assert_equal(mm.getBestMove(), 4, "Minimax synchronous evaluate failed to find best move!");
	delete mm;
	
	// Asynchronous evaluate
	var state = new TicTacToeState([
		-1, -1, -1,
		-1, -1, -1,
		1, -1, -1,
		0
	]);
	var mm = new TicTacToeMmTree(state, 6);
	mm.evaluateInBackground(function(_move) {
		var _correctMove = 4;
		assert_equal(_move, _correctMove, "Minimax asynchronous evaluate failed to find best move!");
		if (_move == _correctMove) {
			show_debug_message("Minimax asynchronous evaluate responded correctly!");
		}
	});
	/** ^^ Place tests here ^^ **/
	
	var timeB = current_time;
	show_debug_message("Minimax tests completed in " + string(timeB-timeA) + "ms.");
	return global.__test_fails__;
}
