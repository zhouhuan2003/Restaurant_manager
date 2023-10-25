import 'package:chanzhanggui_syd/utils/http.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:chanzhanggui_syd/common/pubs/flutter_screenutil/flutter_screenutil.dart';

import 'package:chanzhanggui_syd/widgets/Navigat.dart';
import 'package:chanzhanggui_syd/utils/function.dart';

import 'package:chanzhanggui_syd/pages/guqing/guqing.dart';
import 'package:chanzhanggui_syd/pages/order/order.dart';
import 'package:chanzhanggui_syd/pages/receipt/receipt.dart';
import 'package:chanzhanggui_syd/pages/table/TableList.dart';
import 'package:chanzhanggui_syd/pages/table/meals.dart';
import 'package:chanzhanggui_syd/pages/table/accounts.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:redux/redux.dart';
import 'package:chanzhanggui_syd/widgets/loading_dialog.dart' show Loading;

class Layout extends StatefulWidget{
	const Layout({Key key, store}):super(key: key);

	@override
	_Layout createState() => new _Layout();
}

class _Layout extends State<Layout> {


	@override
	void initState() {
		super.initState();
	}


	Map<dynamic, dynamic> pageRouter = {
		'ind': TableList(),  // 首页
		'gu':  Guqing(),  // 沽清页面
		'ord': OrderIndex(), //订单
		'rec': Receipt(), // 收据
		'meal': Meals(), // 点餐
		'acc': Accounts()// 结账
	}; //  [TableList(), Meals(), Accounts()];

	String pageIndex = 'ind';

	pageHandle(pageSt){
		setState(() {
			pageIndex = pageSt;
		});
	}

	@override
	Widget build(BuildContext context) {
		Loading.ctx = context; // loading 全局 context
		HttpUtil.ctx = context;
		ScreenUtil.instance = ScreenUtil(width: 1366, height: 1024)..init(context);
		return Scaffold(
			body: DecoratedBox(
				decoration:BoxDecoration(
					color: Color(0xff2E3B60),
				),
				child: Flex(
					direction: Axis.horizontal,
					children: <Widget>[
						Expanded(
							child: Row(
								textDirection: TextDirection.rtl,
								children: <Widget>[
									Container(
										width:  hmSetWidth(1224),
										height: 850,
										margin: EdgeInsets.fromLTRB(0, 30, 0, 0),
										decoration:BoxDecoration(
											color: Color(0xffF0E2D9),
											borderRadius: BorderRadius.only(topLeft: Radius.elliptical(10,10)) //.vertical(top: Radius.elliptical(50, 50)),
										),
										child:  StoreConnector(
											converter: (store) => store.state,
											builder: (context, count) {
												return pageRouter[count];
											},
										),
										// pageRouter[pageIndex] //Meals() //Accounts(), //TableList(),
									),

									Container(
										width:hmSetWidth(140),
										child: Navigat(pageHandle: pageHandle),
									),
								],
							)// Navigat(),
						),
					],
				),
			),
			resizeToAvoidBottomPadding: false, //输入框抵住键盘
//			drawer: new Navigat(pageHandle: pageHandle),
		);
	}
}
