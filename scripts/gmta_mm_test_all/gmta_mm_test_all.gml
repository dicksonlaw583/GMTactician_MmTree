///@func gmta_mm_test_all()
function gmta_mm_test_all() {
	global.__test_fails__ = 0;
	var timeA = current_time;
	
	/** vv Place tests here vv **/
	// Synchronous evaluate
	gc_enable(false);
	var state = new TicTacToeState([
		-1, -1, 0,
		-1, -1, -1,
		-1, -1, -1,
		1
	]);
	var mm = new TicTacToeMmTree(state, 6);
	mm.evaluate();
	delete mm;
	gc_collect();
	/** ^^ Place tests here ^^ **/
	
	var timeB = current_time;
	show_debug_message("Minimax tests completed in " + string(timeB-timeA) + "ms.");
	return global.__test_fails__;
}
