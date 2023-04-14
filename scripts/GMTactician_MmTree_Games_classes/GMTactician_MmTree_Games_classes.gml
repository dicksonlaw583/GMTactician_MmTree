///@class TicTacToeMmTree(state, maxDepth)
///@param {Struct.IntransitiveDiceState} state The game state to start from
///@param {Real} maxDepth The maximum depth to expand to
///@desc Minimax tree for the Tic-Tac-Toe game.
function TicTacToeMmTree(state, maxDepth) : MmTree(state, maxDepth) constructor {
	static interpret = function(_pr) {
		return is_undefined(_pr[0]) ? 0.5 : _pr[0];
	};
}

///@class IntransitiveDiceMmTree(state, maxDepth)
///@param {Struct.IntransitiveDiceState} state The game state to start from
///@param {Real} maxDepth The maximum depth to expand to
///@desc Minimax tree for the intransitive dice game.
function IntransitiveDiceMmTree(state, maxDepth) : MmTree(state, maxDepth) constructor {
	static presample = function() {
		switch (state.picks[state.currentPlayer]) {
			case 0: return [[2, 1/3], [4, 1/3], [9, 1/3]];
			case 1: return [[1, 1/3], [6, 1/3], [8, 1/3]];
			case 2: return [[3, 1/3], [5, 1/3], [7, 1/3]];
		}
		show_error("Picked invalid die: " + string(state.picks[state.currentPlayer]), true);
	};
}
