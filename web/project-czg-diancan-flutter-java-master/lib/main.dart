import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'common/config/Global.dart';
import 'pages/users/login.dart';
import 'pages/layout/index.dart';
import 'routers.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluro/fluro.dart';
import 'package:sentry/sentry.dart';

import 'reducer.dart';


void main() => Global.init().then((e) => {

	runZoned<Future<void>>(() async {
	/// 初始化 Store
	Store store = new Store(counterReducer, initialState: 'ind');
	/// 初始化动态路由
	final router = new Router();
	Routes.configureRoutes(router);
	// run app
	runApp(MyApp(router: router, store: store));
	}, onError: (error, stackTrace) {
//		print('出错了' );
		 // reportError(error, stackTrace);
	})
//	runApp(MyApp())
});

class MyApp extends StatelessWidget {

	final router;
	final store;

	MyApp({Key key, this.router, this.store}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StoreProvider(
			store: store,
			child: MaterialApp(
				title: '餐掌柜',
				theme: ThemeData(
					primarySwatch: Colors.indigo,
				),
				home: Layout(store: store), //Login(),// Layout(store: store),// Layout(),
				routes: routes, // 配置静态路由
				onGenerateRoute: router.generator, // 配置动态路由
				debugShowCheckedModeBanner: false,
			),
		);
  }
}
