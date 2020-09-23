///@func gmta_mm_test_all()
function gmta_mm_test_all() {
	global.__test_fails__ = 0;
	var timeA = current_time;
	
	/** vv Place tests here vv **/
	// Synchronous evaluate Tic-Tac-Toe
	var state = new TicTacToeState([
		-1, -1, 0,
		-1, -1, -1,
		-1, -1, -1,
		1
	]);
	var mm = new TicTacToeMmTree(state, 6);
	mm.evaluate();
	assert_equal(mm.getBestMove(), 4, "Minimax synchronous evaluate failed to find best move for Tic-Tac-Toe!");
	delete mm;
	
	// Synchronous evaluate Intransitive Dice 0
	var state = new IntransitiveDiceState(0);
	state.applyMove(0);
	var mm = new IntransitiveDiceMmTree(state, 5);
	mm.evaluate();
	assert_equal(mm.getBestMove(), 2, "MCTS synchronous evaluate failed to find best move against Intransitive Dice 0!");
	delete mm;
	
	// Synchronous evaluate Intransitive Dice 1
	var state = new IntransitiveDiceState(1);
	state.applyMove(1);
	var mm = new IntransitiveDiceMmTree(state, 5);
	mm.evaluate();
	assert_equal(mm.getBestMove(), 0, "MCTS synchronous evaluate failed to find best move against Intransitive Dice 1!");
	delete mm;
	
	// Synchronous evaluate Intransitive Dice 2
	var state = new IntransitiveDiceState(0);
	state.applyMove(2);
	var mm = new IntransitiveDiceMmTree(state, 5);
	mm.evaluate();
	assert_equal(mm.getBestMove(), 1, "MCTS synchronous evaluate failed to find best move against Intransitive Dice 2!");
	delete mm;
	/** ^^ Place tests here ^^ **/
	
	var timeB = current_time;
	show_debug_message("Minimax tests completed in " + string(timeB-timeA) + "ms.");
	return global.__test_fails__ == 0;
}
