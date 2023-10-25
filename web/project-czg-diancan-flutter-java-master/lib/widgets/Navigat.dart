import 'package:flutter/material.dart';
//import 'package:chanzhanggui/utils/function.dart';
import 'package:chanzhanggui_syd/routers.dart';

import 'package:flutter_redux/flutter_redux.dart';
import 'package:chanzhanggui_syd/utils/authentication.dart';
class Navigat extends StatefulWidget {
	Navigat({Key key, this.pageHandle}) : super(key: key);

	final pageHandle;

	@override
	_NavigatState createState() => new _NavigatState();
}

class _NavigatState extends State<Navigat>{

	String _active = 'ind';

	@override
	Widget build(BuildContext context) {
		return Container(
			width: 140,
			child: Flex(
				direction: Axis.vertical,
				children: <Widget>[
					Expanded(
						flex: 1,
						child: Column(
							children: <Widget>[
								Container(
									width: 140,
									padding: EdgeInsets.fromLTRB(16.0, 50.0, 16.0, 16.0),
									decoration: BoxDecoration(
										border: Border(
											bottom: BorderSide(
												color: Color(0xff1F2D54),
												width: 1.0,
											),
										),
									),
									child: Image.asset(
										'assets/images/icon/img_logo.png',
										width: 82,
										height: 107,
									),
								),
								StoreConnector(
										converter: (store) {
											return () => store.dispatch('ind');
										},
										builder: (context, callback,) {
											return GestureDetector(
												child:StoreConnector(
														converter: (store) => store.state,
														builder: (context, count) {
															bool active =  false;
															if(count == 'ind' || count == 'meal' || count == 'acc'){
																active = true;
															}
															return new NavBut(url:['icon_tangdian_sel@2x.png','icon_tangdian_nor@2x.png'], navTit:'堂点', active: active);
														}
												),
												//new NavBut(url:['icon_tangdian_sel@2x.png','icon_tangdian_nor@2x.png'], navTit:'堂点', active: _active == 'ind' ? true : false,),
												onTap: (){
													callback();
												},
											);
										}
								),
								StoreConnector(
										converter: (store) {
											return () => store.dispatch('gu');
										},
										builder: (context, callback) {
											return GestureDetector(
												child: StoreConnector(
														converter: (store) => store.state,
														builder: (context, count) {
															bool active = count == 'gu' ? true : false;
															return new NavBut(url:['icon_guqing_sel@2x.png','icon_guqing_nor@2x.png'], navTit:'估清', active: active);
														}
												),
												//new NavBut(url:['icon_guqing_sel@2x.png','icon_guqing_nor@2x.png'], navTit:'估清', active: _active == 'gu' ? true : false,),
												onTap: (){
													callback();
												},
											);
										}
								),
//					StoreConnector(
//						converter: (store) {
//							return () => store.dispatch('ord');
//						},
//						builder: (context, callback) {
//							return Listener(
//								child: new NavBut(url:['icon_dingdan_sel@2x.png','icon_dingdan_nor@2x.png'], navTit:'订单', active: _active == 'ord' ? true : false,),
//								onPointerDown: (event){
//									setState(() {
//										_active = 'ord';
//									});
//									callback();
//								},
//							);
//						}
//					),
								StoreConnector(
										converter: (store) {
											return () => store.dispatch('rec');
										},
										builder: (context, callback) {
											return GestureDetector(
												child: StoreConnector(
														converter: (store) => store.state,
														builder: (context, count) {
															bool active = count == 'rec' ? true : false;
															return new NavBut(url:['icon_shouju_sel@2x.png','icon_shouju_nor@2x.png'], navTit:'收据', active: active);
														}
												),
												// new NavBut(url:['icon_shouju_sel@2x.png','icon_shouju_nor@2x.png'], navTit:'收据', active: _active == 'rec' ? true : false,),
												onTap: (){
													callback();
												},
											);
										}
								),
							],
						),
					),
					Container(
						margin: EdgeInsets.only(bottom: 30),
						child: GestureDetector(
//							child: Icon(Icons.settings,color: Color(0xff98A5CB),),
							child:Icon(Icons.settings,color: Color(0xff98A5CB),),
							onTap: (){
								gotoLogin(context);
							},
						),
					)
				],
			)
		);
	}
}

class NavBut extends StatelessWidget {
	NavBut({Key key, this.active, this.url, this.navTit}) : super(key: key);

	final bool active;
	final List url;
	final String navTit;

  @override
	Widget build(BuildContext context) {
		return active ? Container(
			  width: 140,
				decoration: BoxDecoration(
					color: Color(0xff1F2D54)
				),
				child: Container(
					child: Align(
						alignment: Alignment(4,0),
						child: Container(
							width: 120,
							padding: EdgeInsets.only(top: 20,bottom: 20),
							decoration: BoxDecoration(
								borderRadius: BorderRadius.only(topRight: Radius.circular(10),bottomRight: Radius.circular(10)),
								color: Color(0xff1F2D54),
							),
							child: Container(
								padding: EdgeInsets.only(right: 44),
								child: Column(
									children: <Widget>[
										Image.asset(
											'assets/images/icon/' + url[0],
											width: 60,
											height: 60,
											alignment: Alignment.centerLeft,
										),
										Text(navTit,
											style: TextStyle(
												color: Color(0xffE9503E),
												fontSize: 16,
											),
										),
									],
								),
							),
						),
					)
				),
		) :
		Container(
			padding: EdgeInsets.only(top: 20,bottom: 20),
			decoration: BoxDecoration(
				border: Border(
					bottom: BorderSide(
						color: Color(0xff1F2D54),
						width: 1.0,
					),
				),
			),
			width: 140,
			child: Column(
				children: <Widget>[
					Image.asset(
						'assets/images/icon/' + this.url[1],
						width: 60,
						height: 60,
					),
					Text(this.navTit,
						style: TextStyle(
							color: Color(0xff98A5CB),
							fontSize: 16,
						),
					),
				],
			),
		);
	}

}
