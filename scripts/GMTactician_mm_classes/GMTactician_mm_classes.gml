
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
		rootMemo = state.getMemo();
		currentNode = root;
		currentNodeChildren = currentNode.children;
		availableMoves = is_undefined(root.polarity) ? presample() : state.getMoves();
	};
	
	static evaluateTick = function() {
		// Downwards
		if (stackdir) {
			// If final or max depth reached:
			if (currentDepth == 0 || isFinal) {
				// Give the appropriate reward
				currentNode.value = isFinal ? interpret(state.getPlayoutResult(), state) : heuristic(state);
				// Go back upwards
				stackdir = false;
				isFinal = false;
			}
			// Not final and has depth to spare, expand
			else {
				// Create a stack frame remembering the current state
				stack[@++stackPointer] = new MmStackFrame(
					state.getMemo(),
					currentNode,
					availableMoves,
					currentChildNum,
					currentDepth--,
					alpha,
					beta
				);
				// Apply current move
				var _currentMove, _currentWeight;
				if (is_undefined(currentNode)) {
					_currentMove = availableMoves[0][currentChildNum];
					_currentWeight = availableMoves[1][currentChildNum];
				} else {
					_currentMove = availableMoves[currentChildNum];
					_currentWeight = undefined;
				}
				state.applyMove(_currentMove);
				// Expand first move
				currentNodeChildren = currentNode.children;
				if (is_undefined(currentNodeChildren)) {
					currentNodeChildren = [];
					currentNode.children = currentNodeChildren;
				}
				currentNodeChildren[@currentChildNum] = new MmNode(
					_currentMove,
					polarity(state.getCurrentPlayer()),
					_currentWeight
				);
				// Focus to current child
				currentNode = currentNodeChildren[currentChildNum];
				// Determine if final
				isFinal = state.isFinal();
				if (isFinal) {
					availableMoves = undefined;
				} else if (is_undefined(currentNode.polarity)) {
					availableMoves = presample();
				} else {
					availableMoves = state.getMoves();
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
			//(_memo, _node, _moves, _currentChildNum, _currentDepth, _alpha, _beta)
			currentNode = _currentStackFrame.node;
			availableMoves = _currentStackFrame.moves;
			currentDepth = _currentStackFrame.currentDepth;
			currentNodeChildren = currentNode.children;
			currentChildNum = _currentStackFrame.currentChildNum;
			alpha = _currentStackFrame.alpha;
			beta = _currentStackFrame.beta;
			var _currentChild = currentNodeChildren[currentChildNum];
			var _currentChildValue = _currentChild.value;
			var _availableMovesCount = 0;
			// If it is a chance node
			var _currentNodePolarity = currentNode.polarity;
			if (is_undefined(_currentNodePolarity)) {
				// Correct moves count to use subarray
				_availableMovesCount = array_length(availableMoves[0]);
			}
			// If it is a max node
			else if (_currentNodePolarity) {
				var _currentNodeValue = currentNode.value;
				if (is_undefined(_currentNodeValue) || _currentChildValue > _currentNodeValue) {
					currentNode.value = _currentChildValue;
				}
				// Update node value and frame alpha
				if (_currentChildValue > alpha) {
					alpha = _currentChildValue;
				}
				_availableMovesCount = array_length(availableMoves);
			}
			// If it is a min node
			else {
				var _currentNodeValue = currentNode.value
				if (is_undefined(_currentNodeValue) || _currentChildValue < _currentNodeValue) {
					currentNode.value = _currentChildValue;
				}
				// Update node value and frame beta
				if (_currentChildValue > alpha) {
					beta = _currentChildValue;
				}
				_availableMovesCount = array_length(availableMoves);
			}
			// If alpha-beta cutoff met or no more children
			if ((alpha > beta) || currentChildNum+1 == _availableMovesCount) {
				// Chance nodes update their value only after all of its children have been expanded
				if (is_undefined(_currentNodePolarity)) {
					var _chanceNodeSum = 0;
					var _chanceNodeChild;
					for (var i = array_length(currentNodeChildren)-1; i >= 0; --i) {
						_chanceNodeChild = currentNodeChildren[i];
						_chanceNodeSum += _chanceNodeChild.weight*_chanceNodeChild.value;
					}
					currentNode.value = _chanceNodeSum;
				}
				// Keep going up (node code required)
			}
			// Still more to evaluate
			else {
				// Read current frame's memo
				state.readMemo(_currentStackFrame.memo);
				// Schedule to apply the next available move
				++currentChildNum;
				// Change direction to downwards
				stackdir = true;
			}
			// Take out the stack frame
			delete _currentStackFrame;
		}
		// Done when the stack is moving upwards and it is empty
		ready = stackPointer < 0 && !stackdir;
		if (ready) {
			state.readMemo(rootMemo);
		}
		return ready;
	};
	
	///@func evaluateInBackground(<callback>)
	///@param <callback> (Optional) A method or script to run when the evaluation completes. It will be passed the best chosen move, and the daemon will self-destruct if this is provided.
	///@desc Evaluate this Minimax tree in the background. Return the instance ID of the daemon.
	static evaluateInBackground = function(_callback) {
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
	};
	
	settings = {
		presampleN: 60
	};
	#endregion
	
	#region Basic properties
	root = undefined;
	rootMemo = undefined;
	maxDepth = _maxDepth;
	#endregion
	
	#region Evaluation state //?
	state = _state;
	
	stack = [];
	stackPointer = -1;
	currentNode = undefined;
	availableMoves = undefined;
	currentDepth = maxDepth;
	currentNodeChildren = undefined;
	currentChildNum = 0;
	alpha = undefined;
	beta = undefined;
	stackdir = true;
	
	isFinal = state.isFinal();
	ready = isFinal;
	progress = isFinal ? 1: 0;
	#endregion
}

function MmNode(_move, _polarity, _weight) constructor {
	move = _move;
	polarity = _polarity;
	value = undefined;
	children = undefined;
	weight = _weight;
}

function MmStackFrame(_memo, _node, _moves, _currentChildNum, _currentDepth, _alpha, _beta) constructor {
	memo = _memo;
	node = _node;
	moves = _moves;
	currentChildNum = _currentChildNum;
	currentDepth = _currentDepth;
	alpha = _alpha;
	beta = _beta;
	progressTotal = 0;
	progressWeight = 0;
}
