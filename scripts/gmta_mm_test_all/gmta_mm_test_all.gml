///@func gmta_mm_test_all()
function gmta_mm_test_all() {
	global.__test_fails__ = 0;
	var timeA = current_time;
	var state, mm;
	
	/** vv Place tests here vv **/
	// Synchronous evaluate Tic-Tac-Toe (1 to play)
	state = new TicTacToeState([
		-1, -1, 0,
		-1, -1, -1,
		-1, -1, -1,
		1
	]);
	mm = new TicTacToeMmTree(state, 6);
	mm.evaluate();
	assert_equal(mm.getBestMove(), 4, "Minimax synchronous evaluate failed to find best move for Tic-Tac-Toe 1!");
	assert_equal(mm.getBestMoveSequence()[0], 4, "Minimax synchronous evaluate failed to find best move sequence for Tic-Tac-Toe 1!");
	assert_equal(mm.getRankedMoves()[0], 4, "Minimax synchronous evaluate failed to find ranked moves for Tic-Tac-Toe 1!");
	assert_equal(mm.getRankedMovesVerbose()[0][0], 4, "Minimax synchronous evaluate failed to find verbose ranked moves for Tic-Tac-Toe 1!");
	delete mm;
	
	// Synchronous evaluate Tic-Tac-Toe (0 to play)
	state = new TicTacToeState([
		-1, -1, 1,
		-1, -1, -1,
		-1, -1, -1,
		0
	]);
	mm = new TicTacToeMmTree(state, 6);
	mm.evaluate();
	assert_equal(mm.getBestMove(), 4, "Minimax synchronous evaluate failed to find best move for Tic-Tac-Toe 2!");
	assert_equal(mm.getBestMoveSequence()[0], 4, "Minimax synchronous evaluate failed to find best move sequence for Tic-Tac-Toe 2!");
	assert_equal(mm.getRankedMoves()[0], 4, "Minimax synchronous evaluate failed to find ranked moves for Tic-Tac-Toe 2!");
	assert_equal(mm.getRankedMovesVerbose()[0][0], 4, "Minimax synchronous evaluate failed to find verbose ranked moves for Tic-Tac-Toe 2!");
	delete mm;
	
	// Synchronous evaluate Intransitive Dice 0
	state = new IntransitiveDiceState(0);
	state.applyMove(0);
	mm = new IntransitiveDiceMmTree(state, 5);
	mm.evaluate();
	assert_equal(mm.getBestMove(), 2, "Minimax synchronous evaluate failed to find best move against Intransitive Dice 0!");
	assert_equal(mm.getBestMoveSequence()[0], 2, "Minimax synchronous evaluate failed to find best move sequence against Intransitive Dice 0!");
	assert_equal(mm.getRankedMoves(), [2, 1], "Minimax synchronous evaluate failed to find ranked moves against Intransitive Dice 0!");
	assert_equal([mm.getRankedMovesVerbose()[0][0], mm.getRankedMovesVerbose()[1][0]], [2, 1], "Minimax synchronous evaluate failed to find verbose ranked moves against Intransitive Dice 0!");
	delete mm;
	
	// Synchronous evaluate Intransitive Dice 1
	state = new IntransitiveDiceState(1);
	state.applyMove(1);
	mm = new IntransitiveDiceMmTree(state, 5);
	mm.evaluate();
	assert_equal(mm.getBestMove(), 0, "Minimax synchronous evaluate failed to find best move against Intransitive Dice 1!");
	assert_equal(mm.getBestMoveSequence()[0], 0, "Minimax synchronous evaluate failed to find best move sequence against Intransitive Dice 1!");
	assert_equal(mm.getRankedMoves(), [0, 2], "Minimax synchronous evaluate failed to find ranked moves against Intransitive Dice 1!");
	assert_equal([mm.getRankedMovesVerbose()[0][0], mm.getRankedMovesVerbose()[1][0]], [0, 2], "Minimax synchronous evaluate failed to find verbose ranked moves against Intransitive Dice 1!");
	delete mm;
	
	// Synchronous evaluate Intransitive Dice 2
	state = new IntransitiveDiceState(0);
	state.applyMove(2);
	mm = new IntransitiveDiceMmTree(state, 5);
	mm.evaluate();
	assert_equal(mm.getBestMove(), 1, "Minimax synchronous evaluate failed to find best move against Intransitive Dice 2!");
	assert_equal(mm.getBestMoveSequence()[0], 1, "Minimax synchronous evaluate failed to find best move sequence against Intransitive Dice 2!");
	assert_equal(mm.getRankedMoves(), [1, 0], "Minimax synchronous evaluate failed to find ranked moves against Intransitive Dice 2!");
	assert_equal([mm.getRankedMovesVerbose()[0][0], mm.getRankedMovesVerbose()[1][0]], [1, 0], "Minimax synchronous evaluate failed to find verbose ranked moves against Intransitive Dice 2!");
	delete mm;
	/** ^^ Place tests here ^^ **/
	
	var timeB = current_time;
	show_debug_message("Minimax tests completed in " + string(timeB-timeA) + "ms.");
	return global.__test_fails__ == 0;
}
