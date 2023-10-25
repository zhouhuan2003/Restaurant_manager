import 'package:chanzhanggui_syd/utils/function.dart';
import 'package:flutter/material.dart';
import 'package:chanzhanggui_syd/widgets/Menulist.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
//import 'package:chanzhanggui_syd/reducer.dart';

class Demo extends StatelessWidget {
  Demo({Key key, this.store,}):super(key:key);

	final Store<int> store;

	@override
	Widget build(BuildContext context) {

		return Scaffold(
			body: Center(
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						StoreConnector(
							converter: (store) => store.state.toString(),
							builder: (context, count) {
								return Text(
									count,
									style: Theme.of(context).textTheme.display1,
								);
							},
						),
						StoreConnector(
							converter: (store) {
								return (event){store.dispatch('Increment');};
							},
							builder: (context, callback) {
								return Listener(
									child: Text('点我+'),
									onPointerDown: callback,
								);
							}
						),
					],
				),
			),
		);
	}
}
