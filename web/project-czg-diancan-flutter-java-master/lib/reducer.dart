enum Actions { Increment }

dynamic counterReducer(dynamic state, dynamic action) {
	print(action);
	state = action;

	return state;
}
