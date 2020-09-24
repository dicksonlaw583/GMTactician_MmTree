
function MmTree(_state, _maxDepth) constructor {
	#region Evaluation
	static evaluate = function() {
		evaluateStart();
		while (!ready) {
			evaluateTick();
		}
	};
	
	static evaluateStart = function() {
		root = new MmNode(undefined, polarity(state.getCurrentPlayer()), undefined);
		state.readMemo(rootMemo);
		currentNode = root;
		currentNode.children = [];
		availableMoves = is_undefined(root.polarity) ? presample() : expand();
		stackPointer = -1;
		currentDepth = maxDepth;
		currentChildNum = 0;
		alpha = -infinity;
		beta = infinity;
		stackdir = true;
		isFinal = state.isFinal();
		ready = isFinal;
		progressTotal = isFinal ? 1 : 0;
		progressWeight = 1;
	};
	
	static evaluateTick = function() {
		//show_debug_message((stackdir ? "DOWN " : "UP ") + string(state.board) + " (" + string(array_length(root.children)) + ")");
		// Downwards
		if (stackdir) {
			// If final or max depth reached:
			if (currentDepth == 0 || isFinal) {
				// Give the appropriate reward
				currentNode.value = isFinal ? interpret(state.getPlayoutResult()) : heuristic();
				// Go back upwards
				stackdir = false;
				isFinal = false;
			}
			// Not final and has depth to spare, expand
			else {
				// Create a stack frame remembering the current state
				var _currentStackFrame = stack[++stackPointer];
				_currentStackFrame.memo = state.getMemo();
				_currentStackFrame.node = currentNode;
				_currentStackFrame.moves = availableMoves;
				_currentStackFrame.currentChildNum = currentChildNum;
				_currentStackFrame.currentDepth = currentDepth--;
				_currentStackFrame.alpha = alpha;
				_currentStackFrame.beta = beta;
				_currentStackFrame.progressTotal = progressTotal;
				_currentStackFrame.progressWeight = progressWeight;
				// Apply current move
				var _currentMove, _currentWeight;
				if (is_undefined(currentNode.polarity)) {
					_currentMove = availableMoves[currentChildNum][0];
					_currentWeight = availableMoves[currentChildNum][1];
				} else {
					_currentMove = availableMoves[currentChildNum];
					_currentWeight = undefined;
				}
				state.applyMove(_currentMove);
				// Expand first move
				currentNode.children[@currentChildNum] = new MmNode(
					_currentMove,
					polarity(state.getCurrentPlayer()),
					_currentWeight
				);
				// Increment progress
		        progressWeight /= array_length(availableMoves);
		        progressTotal += progressWeight*currentChildNum;
				// Focus to current child
				currentNode = currentNode.children[currentChildNum];
				// Determine if final
				isFinal = state.isFinal();
				if (isFinal) {
					availableMoves = undefined;
					currentNode.children = undefined;
				} else if (is_undefined(currentNode.polarity)) {
					availableMoves = presample();
				} else {
					availableMoves = expand();
				}
				currentChildNum = 0;
				alpha = -infinity;
				beta = infinity;
			}
		}
		// Upwards
		else {
			// Unpack the stack frame
			var _currentStackFrame = stack[stackPointer--];
			currentNode = _currentStackFrame.node;
			availableMoves = _currentStackFrame.moves;
			currentChildNum = _currentStackFrame.currentChildNum;
			currentDepth = _currentStackFrame.currentDepth;
			alpha = _currentStackFrame.alpha;
			beta = _currentStackFrame.beta;
			progressTotal = _currentStackFrame.progressTotal;
			progressWeight = _currentStackFrame.progressWeight;
			// Get children and moves info
			var _currentChild = currentNode.children[currentChildNum];
			var _currentChildValue = _currentChild.value;
			var _availableMovesCount = array_length(availableMoves);
			// If it is a chance node, don't process alpha-beta
			var _currentNodePolarity = currentNode.polarity;
			if (is_undefined(_currentNodePolarity)) {
			}
			// If it is a max node
			else if (_currentNodePolarity) {
				if (is_undefined(currentNode.value) || _currentChildValue > currentNode.value) {
					currentNode.value = _currentChildValue;
				}
				// Update node value and frame alpha
				if (_currentChildValue > alpha) {
					alpha = _currentChildValue;
				}
			}
			// If it is a min node
			else {
				if (is_undefined(currentNode.value) || _currentChildValue < currentNode.value) {
					currentNode.value = _currentChildValue;
				}
				// Update node value and frame beta
				if (_currentChildValue < beta) {
					beta = _currentChildValue;
				}
			}
			// If alpha-beta unmet and more children
			if (alpha < beta && ++currentChildNum < _availableMovesCount) {
				// Read current frame's memo
				state.readMemo(_currentStackFrame.memo);
				// Change direction to downwards
				stackdir = true;
			}
			// No more in the subtree to evaluate
			else {
				// Chance nodes update their value only after all of its children have been expanded
				if (is_undefined(_currentNodePolarity)) {
					var _chanceNodeSum = 0;
					var _chanceNodeChild;
					for (var i = array_length(currentNode.children)-1; i >= 0; --i) {
						_chanceNodeChild = currentNode.children[i];
						_chanceNodeSum += _chanceNodeChild.weight*_chanceNodeChild.value;
					}
					currentNode.value = _chanceNodeSum;
				}
				// Keep going up (node code required)
			}
			// Kill the stack's heavy links
			_currentStackFrame.node = undefined;
			_currentStackFrame.memo = undefined;
		}
		// Done when the stack is moving upwards and it is empty
		ready = stackPointer < 0 && !stackdir;
		if (ready) {
			state.readMemo(rootMemo);
			currentNode = undefined;
			stackPointer = -1;
			currentDepth = maxDepth;
			currentChildNum = 0;
			stackdir = true;
			progressTotal = 1;
			progressWeight = 1;
		}
		return ready;
	};
	
	///@func evaluateInBackground(<callback>)
	///@param <callback> (Optional) A method or script to run when the evaluation completes. It will be passed the best chosen move, and the daemon will self-destruct if this is provided.
	///@desc Evaluate this Minimax tree in the background. Return the instance ID of the daemon.
	static evaluateInBackground = function() {
		var _callback = (argument_count > 0) ? argument[0] : undefined;
		var _id;
		var _tree = self;
		evaluateStart();
		with (instance_create_depth(0, 0, 0, __obj_gmtactician_mm_daemon__)) {
			tree = _tree;
			callback = _callback;
			_id = id;
		}
		return _id;
	};
	
	///@func getProgress()
	///@desc Return the evaluation progress of this tree, in [0, 1] range.
	static getProgress = function() {
		return progressTotal + progressWeight*currentChildNum/max(1, is_array(availableMoves) ? array_length(availableMoves) : 0);
	};
	#endregion
	
	#region Get moves
	static _getBestChild = function(_node) {
		var _bestNode = undefined;
		var _rootPolarity = _node.polarity;
		var _rootChildren = _node.children;
		if (is_array(_rootChildren) && array_length(_rootChildren) > 0) {
			var _bestNode = _rootChildren[0];
			var _bestValue = _bestNode.value;
			for (var i = array_length(_rootChildren)-1; i >= 1; --i) {
				var _currentNode = _rootChildren[i];
				var _currentValue = _currentNode.value;
				if ((_currentValue < _bestValue) ^^ _rootPolarity) {
					_bestNode = _currentNode;
					_bestValue = _currentValue;
				}
			}
		}
		return _bestNode;
	};
	
	///@func getBestMove()
	///@desc Return the move that the Minimax tree thinks is the best (i.e. most visited).
	static getBestMove = function() {
		var _bestNode = _getBestChild(root);
		return is_undefined(_bestNode) ? undefined : _bestNode.move;
	};
	
	///@func getBestMoveSequence(<n>)
	///@param <n> (Optional) Maximum number of moves after the root state to read
	///@desc Return an array of moves that the Minimax tree believes is optimal for all players.
	static getBestMoveSequence = function(_n) {
		if (is_undefined(_n)) {
			_n = infinity;
		}
		var _sequence = [];
		var _currentNode = root;
		var ii = 0;
		while (_n--) {
			var _bestNode = _getBestChild(_currentNode);
			if (is_undefined(_bestNode)) return _sequence;
			_sequence[@ii++] = _bestNode.move;
			_currentNode = _bestNode;
		}
		return _sequence;
	};
	
	///@func getRankedMoves(<n>)
	///@param <n> (Optional) Maximum number of different moves to consider
	///@desc Return an array of moves, ranked top-to-bottom by how good the Minimax tree thinks it is
	static getRankedMoves = function(_n) {
		var _children = root.children;
		var _polarity = root.polarity;
		if (is_undefined(_children)) return [];
		var _childrenN = array_length(_children);
		if (is_undefined(_n)) {
			_n = _childrenN;
		}
		var _rankings = array_create(_n);
		var pq = ds_priority_create();
		for (var i = _childrenN-1; i >= 0; --i) {
			var _child = _children[i];
			ds_priority_add(pq, _child.move, _child.value);
		}
		for (var i = 0; i < _n && !ds_priority_empty(pq); ++i) {
			_rankings[@i] = _polarity ? ds_priority_delete_max(pq) : ds_priority_delete_min(pq);
		}
		ds_priority_destroy(pq);
		return _rankings;
	};
	
	///@func getRankedMovesVerbose(<n>)
	///@param <n> (Optional) Maximum number of different moves to consider
	///@desc Return a 2D array of moves and associated properties; each row is [<move>, <weight>]
	static getRankedMovesVerbose = function(_n) {
		var _children = root.children;
		if (is_undefined(_children)) return [];
		var _childrenN = array_length(_children);
		if (is_undefined(_n)) {
			_n = _childrenN;
		}
		var _rankings = array_create(_n);
		var pq = ds_priority_create();
		for (var i = _childrenN-1; i >= 0; --i) {
			var _child = _children[i];
			ds_priority_add(pq, [_child.move, _child.value], _child.value);
		}
		for (var i = 0; i < _n && !ds_priority_empty(pq); ++i) {
			_rankings[@i] = ds_priority_delete_max(pq);
		}
		ds_priority_destroy(pq);
		return _rankings;
	};
	#endregion
	
	#region User configured
	static expand = function() {
		return state.getMoves();
	};
	
	static polarity = function(_player) {
		return _player;
	};
	
	static heuristic = function() {
		return interpret(state.getPlayoutResult());
	};
	
	static interpret = function (_playoutResult) {
		return _playoutResult;
	};
	
	static presample = function() {
		// Set up accumulators
		var countMap = ds_map_create();
		var _moves = [];
		var _moveStrings = [];
		var _movesN = 0;
		// Sample settings.presampleN times
		repeat (settings.presampleN) {
			// Get a random move
			var _move = state.getRandom();
			var _moveString = string(_move);
			// Log it
			if (ds_map_exists(countMap, _moveString)) {
				countMap[? _moveString] += 1;
			} else {
				countMap[? _moveString] = 1;
				_moveStrings[@_movesN] = _moveString;
				_moves[@_movesN] = _move;
				++_movesN;
			}
		}
		// Generate the result
		var _results = array_create(_movesN);
		for (var i = _movesN-1; i >= 0; --i) {
			_results[@i] = [_moves[i], countMap[? _moveStrings[i]]/settings.presampleN];
		}
		ds_map_destroy(countMap);
		return _results;
	};
	
	settings = {
		presampleN: MINIMAX_DEFAULT_PRESAMPLE_N
	};
	#endregion
	
	#region Basic properties
	state = _state.clone();
	root = undefined;
	rootMemo = state.getMemo();
	maxDepth = _maxDepth;
	#endregion
	
	#region Evaluation state
	stack = array_create(maxDepth);
	for (var i = maxDepth-1; i >= 0; --i) {
		stack[@i] = new MmStackFrame();
	}
	stackPointer = -1;
	currentNode = undefined;
	availableMoves = undefined;
	currentDepth = maxDepth;
	currentChildNum = 0;
	alpha = -infinity;
	beta = infinity;
	stackdir = true;
	isFinal = false;
	ready = false;
	progressTotal = 0;
	progressWeight = 1;
	#endregion
}

function MmNode(_move, _polarity, _weight) constructor {
	move = _move;
	polarity = _polarity;
	value = undefined;
	children = [];
	weight = _weight;
}

function MmStackFrame() constructor {
	memo = undefined;
	node = undefined;
	moves = undefined;
	currentChildNum = 0;
	currentDepth = 0;
	alpha = -infinity;
	beta = infinity;
	progressTotal = 0;
	progressWeight = 1;
}
