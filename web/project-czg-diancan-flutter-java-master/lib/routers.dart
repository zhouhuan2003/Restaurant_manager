/*
  注册路由表
*/
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';

import 'pages/layout/index.dart';
import 'pages/users/login.dart';

var routes = {

	"/login": (context) => Login(), // 登陆
	"/index": (context) => Layout(), // 首页
};


/// 动态路由
class Routes {
	static Router router;
	static String tabIndex = '/table/index';

	static void configureRoutes(Router router) {

		router.notFoundHandler = new Handler(
			handlerFunc: (BuildContext context,Map<String,List<String>> params){
				print("route is not find !");
			});
		//

		router.define(
			tabIndex,
			handler: Handler(
				handlerFunc: (context, params) => Layout(),
			),
		);

		Routes.router = router;
	}
}
