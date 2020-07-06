///@desc Asynchronous testing
var state = new TicTacToeState([
	1, -1, -1,
	-1, -1, -1,
	-1, -1, -1,
	0
]);
mm2 = new TicTacToeMmTree(state, 6);
mm2.evaluateInBackground();
