import 'dart:convert';
import 'dart:typed_data';

import 'dart:convert' as convert;
import 'package:chanzhanggui_syd/utils/function.dart';
import 'package:flutter/material.dart';
import 'package:chanzhanggui_syd/widgets/Menulist.dart';
import 'package:flutter/widgets.dart';
import 'package:chanzhanggui_syd/widgets/border.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:chanzhanggui_syd/common/api/api.dart';
import 'package:chanzhanggui_syd/widgets/IndexTopButList.dart';

class Meals extends StatefulWidget {
	Meals({Key key}) : super(key: key);

	@override
	_Meals createState() => new _Meals();
}
class _Meals extends State<Meals> {

	static Map tableData;
	static Map orderList;
	static List checkList = [];
	static int totalPrice = 0;  // 总价
	static List dishFlavor = []; // 菜品口味备注
	static List reasonsList = []; // 备注的列表
	static List reasons = [];  // 整单备注选择数据
	static List reasonsData = [];  // 整单备注确定保存
	static bool butStatus = true; // 按钮状态 已下单 无法点击部分按钮
	static int personNumbers = 0; // 就餐人数
	static int activeMember = 0; //就餐人数 修改
	static List TableList;
	static List AreaList;
	static String topActState = '全部';
	static String activeTableId;
	static String active;
	static String areaId = 'all';
	static bool isOrder = false; // 是否下单
	static Map changeTableData; //
	static String addDishState = '0'; // 0 点餐  1 加餐
	static List addDishList = []; //加菜列表

	@override
	void initState() {
		super.initState();
		// 清空数据
		clearTable();
		setState(() {
			butStatus = true;
			addDishState = '0';
		});
		// 加载公告列表
		getTabledata();
		loadAreaList();
		loadListData();
	}

  // 获取所选桌台信息
	getTabledata() async{
		String data = await FlutterSecureStorage().read(key: 'checkTableData');
		Map itemData = convert.jsonDecode(data);
		setState(() {
		  tableData = itemData;
			personNumbers = itemData['activeMember'];
		});
		if (tableData['status'].toString() == '1'){
			getData();
			Map data = await ApiService.getOrderDetile(tableData['tableId']);
			if(data['code'] == 200 && data['data']['orderId'] != null){
				print('设置为flase');
				setState(() {
					butStatus = false;
				});
			}
		}
	}

// 获取备注列表
	getRemarkList(type) async{
		final data = await ApiService.remark(type);
		setState(() {
			reasonsList = data['data'];
		});
	}

	// 获取购物车列表
	getData() async{
    Map data = await ApiService.getOrderDetile(tableData['tableId']);
		Map orderData = data['data'];
		// 换没点餐呢
		if (orderData['dishs'] != null) {
			List orderList = orderData['dishs'];
			orderList.forEach((item){
				item['orderRemark'] = item['orderRemark'] == null ? [] : item['orderRemark'];
				item['flavorList'] = item['flavorList'] == null ? [] : item['flavorList'];
				item['orderState'] = true;
			});

			setState(() {
				checkList = orderList;
				reasonsData = orderData['orderRemark'] == null ? [] : orderData['orderRemark'];
			});
		}

		setState(() {
			personNumbers = orderData['personNumbers'];
		});

		totalPriceHandle(checkList);
	}

	// 添加菜品到下单列表
	addHandle(item) async{
		if (butStatus) {
			final data = checkList;
			final params = item;
			params['active'] = true;
			params['dishNumber'] = 1;
			params['flavorList'] = [];
			if (checkList.indexOf(params) == -1) {
				data.add(params);
			};
			totalPriceHandle(data);
			setState(() {
				checkList = data;
			});
			if(addDishState == '1'){
				final dataes = addDishList;
				if (addDishList.indexOf(params) == -1) {
					dataes.add(params);
				};
				setState(() {
					addDishList = dataes;
				});
			}
		}
	}
  // 总价计算
	totalPriceHandle(data){
		int price = 0;
		data.forEach((it){
			price += it['price'] * it['dishNumber'];
		});
		setState(() {
			totalPrice = price;
		});

	}
	// 加减菜量
	addAndRecDish(item,st){
		if (butStatus){
			print(item);
			print(st);
			int num = checkList.indexOf(item);
			List cgChecklist = checkList;
			if (st == 'add') {
				cgChecklist[num]['dishNumber'] ++;
			} else if(st == 'rec') {
				if (cgChecklist[num]['dishNumber'] == 1){
					item['active'] = false;
					cgChecklist.remove(item);
				} else {
					cgChecklist[num]['dishNumber'] --;
				}
			}
			totalPriceHandle(cgChecklist);
			setState(() {
				checkList = cgChecklist;
			});
		}
	}

  // 菜品口味备注
	dishMarkhandle(item) async{
		final data = await ApiService.getFlavor(item['dishId']);
		List dishItem = [];
		data['data'].forEach((n){
			dishItem.addAll(n['flavorData']);
		});
		setState(() {
			reasonsList = dishItem;
		});
		bool delete = await setDishFlavor();
		if (delete == null) {
			print("取消");
			setState(() {
				dishFlavor = item['flavorList'];
			});
		} else {
			print('确定');
			print(dishFlavor);
			setState(() {
				item['flavorList'] = dishFlavor;
			});
		}
	}
	// 清台
  clearTable(){
		checkList.forEach((n){
			n['active'] = false;
		});
		setState(() {
			checkList = [];
			reasonsData = [];
			addDishList = [];
		});
	}

	// 底部按钮
	tableChaneg(st) async {
		if (butStatus && st == 'clear'){  // 一键清台
			clearTable();
		}

		if (butStatus && st == 'mark') { // 整单备注
			await getRemarkList('8');
			bool delete = await setMark();
			if (delete == null) {
				print("取消");
				setState(() {
					reasons = reasonsData;
				});
			} else {
				setState(() {
					reasonsData = reasons;
				});
			}
		}

		if(st == 'addDish'){ // 加菜
			setState(() {
				addDishState = '1';
				butStatus = true;
			});
		}

		if(butStatus && st == 'order'){ // 下单
			Map data = await ApiService.getOrderDetile(tableData['tableId']);
			print(data['code'] == 200 && data['data']['orderId'] != null && addDishState == '0');
			print(data);
			print(addDishState);
			if(data['code'] == 200 && data['data']['orderId'] == null && addDishState == '0'){
				Map params = {'dishs': checkList};
				params['orderRemark'] = reasonsData;
				params['personNumbers'] = personNumbers;
				params['tableId'] = tableData['tableId'];
				params['totalAmount'] = totalPrice;
				final dataes = await ApiService.cashOrder(params);
				if (dataes['code'] == 200){
					hmShowTosta('下单成功！');
					setState(() {
						butStatus = false;
					});
				}
			}else if (data['code'] == 200 && data['data']['orderId'] != null && addDishState == '1'){
				Map params = {'dishs': addDishList};
				params['orderRemark'] = reasonsData;
				params['personNumbers'] = personNumbers;
				params['orderId'] = data['data']['orderId'];
				params['totalAmount'] = totalPrice;
				final dataes = await ApiService.addCash(params);
				if (dataes['code'] == 200){
					hmShowTosta('加菜成功！');
					setState(() {
						butStatus = false;
					});
				}
			} else {
				hmShowTosta('下单失败！');
			}
		}
	}

	// 改人数
	changMumber() async{
		bool delete = await SetMumber();
		if (delete == null) {
			print("取消");
			setState(() {
				activeMember = 0;
			});
		} else {
			if (tableData['status'].toString() == '1'){
				Map params = {'tableId':tableData['tableId'],'number':activeMember};
				print(params);
				final data = await ApiService.changeMember(params);
				if (data['code'] == 200){
					setState(() {
						personNumbers = activeMember;
						activeMember = 0;
					});
					print(personNumbers);
				}
			} else {
				setState(() {
					personNumbers = activeMember;
					activeMember = 0;
				});
			}
		}
	}



	// 换桌
	changeTable() async{
		bool delete = await setTargetTable();
		if (delete == null) {
			print("取消");
		} else {
			if (tableData['status'].toString() == '1'){
				Map params = {'sourceTableId':tableData['tableId'],'targetTableId':activeTableId};
				final data = await ApiService.changeTable(params);
				if (data['code'] == 200){
					final par = changeTableData;
					par['status'] = 1;
					await FlutterSecureStorage().write(key: 'checkTableData', value:	convert.jsonEncode(par));
					getTabledata();
				}
			}
		}
	}

	// 获取餐桌列表
	loadListData() async{
		final TableListData = await ApiService.openTablePanel({'areaId':areaId,'page': '1', 'pageSize': '100' });
		final data = TableListData['data']['tablePage']['items'];
		final list = [];
		data.forEach((n){
			if(n['status'] == 0){
				list.add(n);
			}
		});
		setState(() {
			TableList = list;
		});
	}

	// 获取区域列表
	loadAreaList() async{
		final areaList = await ApiService.areaList();
		areaList['data'].insert(0, {'area_id': 'all', 'area_name': '全部'});
		setState(() {
			AreaList = areaList['data'];
		});
	}

	@override
	Widget build(BuildContext context) {
		return tableData != null ? Flex(
			direction: Axis.vertical,
			children: <Widget>[
				Expanded(
					flex: 1,
					child: Padding(
						padding: hmSetEdgeInsetsAll(30.0),
						child: Flex(
							direction: Axis.horizontal,
							children: <Widget>[
								Container(
									width: hmSetWidth(423),
									height: hmSetHeight(1000),
									child: Flex(
										direction: Axis.vertical,
										children: <Widget>[
											Padding(
												padding: hmSetEdgeInsetsLTRB(0, 23, 0, 23),
												child: Flex(
													direction: Axis.horizontal,
													children: <Widget>[
														Container(
															width: hmSetWidth(105),
															margin: EdgeInsets.only(right: 20),
															decoration: BoxDecoration(
																gradient: LinearGradient(colors: [Color(0xFF4FBFFF), Color(0xFF208DFF)],begin:FractionalOffset(1, 0)),// 渐变色
																borderRadius: BorderRadius.circular(4)
															),
															child: StoreConnector(
																	converter: (store) {
																		return () => store.dispatch('ind');
																	},
																	builder: (context, callback) {
																		return OutlineButton(
																			padding: EdgeInsets.only(left: 30,top: 15, bottom: 15, right: 30),
																			color: Colors.transparent,
																			shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
																			child: Text('返回桌台',
																				style: TextStyle(
																						color: Colors.white,
																						fontSize: 18
																				),
																			),
																			onPressed: () {
																				callback();
																			},
																		);
																	}
															),
														),
													  Expanded(
															flex: 1,
															child: Column(
																children: <Widget>[
																	Row(
																		children: <Widget>[
																			Container(
																				width: hmSetWidth(160),
																				margin: hmSetEdgeInsetsLTRB(0, 5, 15, 5),
																				padding: hmSetEdgeInsetsLTRB(10, 9, 10, 9),
																				decoration: BoxDecoration(
																					color: Colors.white,
																					borderRadius: BorderRadius.all(Radius.elliptical(6,6)),
																				),
																				child: Text('桌号: ${tableData['tableName']}',
																					textAlign: TextAlign.left,
																					style: TextStyle(fontSize: 16,color: Color(0xff20232A))),
																			),
																			Container(
																				width: hmSetWidth(120),
																				margin: hmSetEdgeInsetsLTRB(0, 5, 0, 5),
																				padding: hmSetEdgeInsetsLTRB(25, 9, 10, 9),
																				decoration: BoxDecoration(
																					color: Colors.white,
																					borderRadius: BorderRadius.all(Radius.elliptical(6,6)),
																				),
																				child: Row(
																					children: <Widget>[
																						Image.asset('assets/images/icon/icon_huanzhuo@2x.png', width: 20,),
																						GestureDetector(
																							child: Text(' 换桌',style: TextStyle(fontSize: 16,color: Color(0xffE9503E)),),
																							onTap: (){
																								changeTable();
																							},
																						),
																					],
																				)
																			)
																		],
																	),
																	Row(
																		children: <Widget>[
																			Container(
																				width: hmSetWidth(160),
																				margin: hmSetEdgeInsetsLTRB(0, 5, 15, 5),
																				padding: hmSetEdgeInsetsLTRB(10, 9, 10, 9),
																				decoration: BoxDecoration(
																					color: Colors.white,
																					borderRadius: BorderRadius.all(Radius.elliptical(6,6)),
																				),
																				child: Text('人数: ${personNumbers}',
																					textAlign: TextAlign.left,
																					style: TextStyle(fontSize: 16,color: Color(0xff20232A))
																				),
																			),
																			Container(
																				width: hmSetWidth(120),
																				margin: hmSetEdgeInsetsLTRB(0, 5, 0, 5),
																				padding: hmSetEdgeInsetsLTRB(20, 9, 10, 9),
																				decoration: BoxDecoration(
																					color: Colors.white,
																					borderRadius: BorderRadius.all(Radius.elliptical(6,6)),
																				),
																				child: Row(
																					children: <Widget>[
																						Image.asset('assets/images/icon/icon_gairenshu@2x.png',width: 20,),
																						GestureDetector(
																							child: Text(' 改人数',style: TextStyle(fontSize: 16,color: Color(0xffE9503E)),),
																							onTap: (){
																								changMumber();
																							},
																						),

																					],
																				)
																			)
																		],
																	)
																],
															),
														)
													],
												),
											),
											Expanded(
												flex: 1,
												child: OrderList(checkList:checkList, onHandle: addAndRecDish, dishMarkhandle:dishMarkhandle),
											),
											Container( // 备注
//												height: hmSetHeight(56),
												padding: hmSetEdgeInsetsAll(15.0),
												decoration: BoxDecoration(
													color: Color(0xffFBE9E7)
												),
												child: Flex(
													direction: Axis.horizontal,
													children: <Widget>[
														Image.asset('assets/images/icon/icon_beizhu@2x.png',width: 22),
														Container(
															child: Text('备注',style: TextStyle(color:Color(0xffFFB302),fontSize: 14)),
														),
														Expanded(
																flex: 1,
																child: Row(
																		children: reasonsData.length > 0 ? reasonsData.map<Widget>((n){
																			return Container(
																				padding: hmSetEdgeInsetsLTRB(6, 1, 6, 1),
																				margin: hmSetEdgeInsetsLTRB(10, 0, 5, 0),
																				decoration: BoxDecoration(
																					color: Color(0xffFFF4F3),
																					border: Border.all(color: Color(0xffFFC5C5)),
																					borderRadius:BorderRadius.all(Radius.elliptical(20,20)),
																				),
																				child: Text(n,style: TextStyle(fontSize: 10.0,color: Color(0xffF56C6C)),),
																			);
																		}).toList() : <Widget>[Text('')]
																)
														)

													],
												),
											),
											Container( // 总价
												padding: hmSetEdgeInsetsAll(19.0),
												decoration: BoxDecoration(
													color: Color(0xffF56C6C)
												),
												child: Row(
													textDirection: TextDirection.rtl,
													children: <Widget>[
														Text('￥ ${totalPrice/100}',style: TextStyle(color: Colors.white,fontSize: 18)),
														Text('总价：',style: TextStyle(color: Colors.white)),
													],
												),
											)
										],
									),
								),
								Container(
									margin: hmSetEdgeInsetsLTRB(20.0,0,0,0),
									width: hmSetWidth(721),
									height: hmSetHeight(1000),
//						padding: hmSetEdgeInsetsLTRB(0, 23, 20, 23),
									decoration: BoxDecoration(
										color: Colors.white,
										borderRadius: BorderRadius.all(Radius.elliptical(6,6)),
									),
									child: new Menulist(checkList: checkList, checkHandle:addHandle),
								),
							],
						),
					),
				),
				Container(
					height: hmSetHeight(104),
					width: hmSetWidth(1224),
					decoration: BoxDecoration(
						color: Colors.white,
					),
					child: BottomButList(onHandle:tableChaneg,tableId:tableData['tableId']),
				)
			],
		) : Text('');
	}

	// 设置备注弹框
	Future<bool> setMark(){
		return showDialog<bool>(
			context: context,
			builder: (context) {
				return StatefulBuilder(
					builder: (context, mSetState){
						return AlertDialog(
							contentPadding: hmSetEdgeInsetsAll(0.0),
							shape: new BeveledRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
							content: Container(
								width: hmSetWidth(490),
								height: hmSetHeight(523),
								decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(10.0),
										color: Colors.white
								),
								child: Flex(
									direction: Axis.vertical,
									children: <Widget>[
										ConstrainedBox(
											constraints: BoxConstraints(
												minWidth: double.infinity, //宽度尽可能大
											),
											child: Container(
												height: hmSetHeight(86),
												padding: hmSetEdgeInsetsLTRB(20, 0, 0, 0),
												alignment: Alignment.centerLeft,
												decoration: BoxDecoration(
													border: Border(
															bottom: BorderSide(
																width: 1,
																color: Color(0xffD8DDE3),
															)
													),
												),
												child: Flex(
													direction: Axis.horizontal,
													children: <Widget>[
														Expanded(
															flex: 1,
															child:  Text('备注', style: TextStyle(
																color: Color(0xff818693),
																fontSize: 24,
															)),
														),
														Padding(
															padding: hmSetEdgeInsetsLTRB(0, 0, 20, 0),
															child: GestureDetector(
																child: Image.asset('assets/images/icon/btn_tanchuang_guanbi@2x.png',width: 32,),
																onTap: (){
																	Navigator.of(context).pop(); // 关闭对话框
																},
															),
														),
													],
												)
											),
										),
										Expanded(
												flex: 1,
												child:Flex(
													direction: Axis.vertical,
													children: <Widget>[
														Expanded(
															flex: 1,
															child: Column(
																children: <Widget>[
																	Container(
																		padding: hmSetEdgeInsetsLTRB(20, 20, 20, 0),
																		child: Wrap(
																			spacing: 20.0,
																			runSpacing: 10.0,
																			children: reasonsList.map((n) {
																				bool act = false;
																				if(reasons.indexOf(n) != -1){
																					act = true;
																				};
																				print(act);
																				return  GestureDetector(
																					child: Container(
																						padding: hmSetEdgeInsetsLTRB(20, 10, 20, 10),
																						decoration: BoxDecoration(
																							color: act == true ? Color(0xffFFF4F3) : Colors.white,
																							border: Border.all(width: 1,color: act == true ? Color(0xffFFC5C5) : Color(0xffD8DDE3)),
																							borderRadius: BorderRadius.all(Radius.circular(60)),
																						),
																						child: Text(n,style: TextStyle(
																							color: act == true ?  Color(0xffF56C6C):Color(0xff818693),
																						),),
																					),
																					onTap: () {
																						List checkList = reasons;
																						act == true ? checkList.remove(n) : checkList.add(n);
																						mSetState(() {
																							reasons = checkList;
																						});
																						print(reasons);
																					},
																				);
																			}
																			).toList(),
																		),
																	)
																],
															),
														),
													],
												)
										),
										Padding(
											padding: hmSetEdgeInsetsAll(20.0),
											child: Row(
												children: <Widget>[
													Text('其他原因', style: TextStyle(
															color: Color(0xff818693),
															fontSize: 18
													),),
													Container(
														width: hmSetWidth(300),
														height: hmSetHeight(50),
														margin: hmSetEdgeInsetsLTRB(28, 0, 0, 0),
														alignment: Alignment.centerLeft,
														decoration: BoxDecoration(
															border: Border.all(width: 1,color: Color(0xffD8DDE3)),
															borderRadius: BorderRadius.all(Radius.circular(6)),
														),
														child: TextField(
															decoration: InputDecoration(
																hintText: "选择其他原因后输入其他原因",
																contentPadding: hmSetEdgeInsetsLTRB(10, 0, 10, 10),
																border: InputBorder.none,
															),
															onSubmitted:(val){
																mSetState(() {
																	reasons = [val];
																});
															},
														),
													),
												],
											),
										),
										Container(
											height: hmSetHeight(136),
											child: Row(
												mainAxisSize:MainAxisSize.max,
												mainAxisAlignment:MainAxisAlignment.end,
												children: <Widget>[
													Listener(
														child: Container(
															width: 120,
															height: 60,
															alignment: Alignment.center,
															decoration: BoxDecoration(
																	borderRadius: BorderRadius.circular(10),
																	border:Border.all(
																			width: 1,
																			color:Color(0xffC0C4CD)
																	)
															),
															child: Text('取消', style: TextStyle(
																	color: Color(0xff818693),
																	fontSize: 18
															)),
														),
														onPointerDown: (event) => {
															Navigator.of(context).pop(), // 关闭对话框
														},
													),
													Listener(
														child: Container(
															margin: hmSetEdgeInsetsLTRB(43, 0, 20, 0),
															width: 120,
															height: 60,
															alignment: Alignment.center,
															decoration: BoxDecoration(
																gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
																borderRadius: BorderRadius.circular(10),
															),
															child: Text('确定', style: TextStyle(
																	color: Colors.white,
																	fontSize: 18
															)),
														),
														onPointerDown: (event) => {
															Navigator.of(context).pop(true)
														},
													),
												],
											),
										)
									],
								),
							),
						);
					},
				);
			},
		);

	}

	// 设置口味弹框
	Future<bool> setDishFlavor(){
		return showDialog<bool>(
			context: context,
			builder: (context) {
				return StatefulBuilder(
					builder: (context, mSetState){
						return AlertDialog(
							contentPadding: hmSetEdgeInsetsAll(0.0),
							shape: new BeveledRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
							content: Container(
								width: hmSetWidth(490),
								height: hmSetHeight(523),
								decoration: BoxDecoration(
										borderRadius: BorderRadius.circular(10.0),
										color: Colors.white
								),
								child: Flex(
									direction: Axis.vertical,
									children: <Widget>[
										ConstrainedBox(
											constraints: BoxConstraints(
												minWidth: double.infinity, //宽度尽可能大
											),
											child: Container(
												height: hmSetHeight(86),
												padding: hmSetEdgeInsetsLTRB(20, 0, 0, 0),
												alignment: Alignment.centerLeft,
												decoration: BoxDecoration(
													border: Border(
															bottom: BorderSide(
																width: 1,
																color: Color(0xffD8DDE3),
															)
													),
												),
												child: Flex(
													direction: Axis.horizontal,
													children: <Widget>[
														Expanded(
															flex: 1,
															child:  Text('口味备注', style: TextStyle(
																color: Color(0xff818693),
																fontSize: 24,
															)),
														),
														Padding(
															padding: hmSetEdgeInsetsLTRB(0, 0, 20, 0),
															child: GestureDetector(
																child: Image.asset('assets/images/icon/btn_tanchuang_guanbi@2x.png',width: 32,),
																onTap: (){
																	Navigator.of(context).pop(); // 关闭对话框
																},
															),
														),
													],
												)
											),
										),
										Expanded(
												flex: 1,
												child:Flex(
													direction: Axis.vertical,
													children: <Widget>[
														Expanded(
															flex: 1,
															child: Column(
																children: <Widget>[
																	Container(
																		padding: hmSetEdgeInsetsLTRB(20, 20, 20, 0),
																		child: Wrap(
																			spacing: 20.0,
																			runSpacing: 10.0,
																			children: reasonsList.map((n) {
																				bool act = false;
																				if(dishFlavor.indexOf(n) != -1){
																					act = true;
																				};
																				return  GestureDetector(
																					child: Container(
																						padding: hmSetEdgeInsetsLTRB(20, 10, 20, 10),
																						decoration: BoxDecoration(
																							color: act == true ? Color(0xffFFF4F3) : Colors.white,
																							border: Border.all(width: 1,color: act == true ? Color(0xffFFC5C5) : Color(0xffD8DDE3)),
																							borderRadius: BorderRadius.all(Radius.circular(60)),
																						),
																						child: Text(n,style: TextStyle(
																							color: act == true ?  Color(0xffF56C6C):Color(0xff818693),
																						),),
																					),
																					onTap: () {
																						List checkList = dishFlavor;
																						act == true ? checkList.remove(n) : checkList.add(n);
																						mSetState(() {
																							dishFlavor = checkList;
																						});
																					},
																				);
																			}
																			).toList(),
																		),
																	)
																],
															),
														),
													],
												)
										),
										Padding(
											padding: hmSetEdgeInsetsAll(20.0),
											child: Row(
												children: <Widget>[
													Text('其他原因', style: TextStyle(
															color: Color(0xff818693),
															fontSize: 18
													),),
													Container(
														width: hmSetWidth(300),
														height: hmSetHeight(50),
														margin: hmSetEdgeInsetsLTRB(28, 0, 0, 0),
														alignment: Alignment.centerLeft,
														decoration: BoxDecoration(
															border: Border.all(width: 1,color: Color(0xffD8DDE3)),
															borderRadius: BorderRadius.all(Radius.circular(6)),
														),
														child: TextField(
															decoration: InputDecoration(
																hintText: "选择其他原因后输入其他原因",
																contentPadding: hmSetEdgeInsetsLTRB(10, 0, 10, 10),
																border: InputBorder.none,
															),
															onSubmitted:(val){
																mSetState(() {
																	dishFlavor = [val];
																});
															},
														),
													),
												],
											),
										),
										Container(
											height: hmSetHeight(136),
											child: Row(
												mainAxisSize:MainAxisSize.max,
												mainAxisAlignment:MainAxisAlignment.end,
												children: <Widget>[
													Listener(
														child: Container(
															width: 120,
															height: 60,
															alignment: Alignment.center,
															decoration: BoxDecoration(
																	borderRadius: BorderRadius.circular(10),
																	border:Border.all(
																			width: 1,
																			color:Color(0xffC0C4CD)
																	)
															),
															child: Text('取消', style: TextStyle(
																	color: Color(0xff818693),
																	fontSize: 18
															)),
														),
														onPointerDown: (event) => {
															Navigator.of(context).pop(), // 关闭对话框
														},
													),
													Listener(
														child: Container(
															margin: hmSetEdgeInsetsLTRB(43, 0, 20, 0),
															width: 120,
															height: 60,
															alignment: Alignment.center,
															decoration: BoxDecoration(
																gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
																borderRadius: BorderRadius.circular(10),
															),
															child: Text('确定', style: TextStyle(
																	color: Colors.white,
																	fontSize: 18
															)),
														),
														onPointerDown: (event) => {
															Navigator.of(context).pop(true)
														},
													),
												],
											),
										)
									],
								),
							),
						);
					},
				);
			},
		);

	}

	// 人数修改
	Future<bool> SetMumber() {
		final numberList = ['1','2','3','4','5','6','7','8','9'];

		return showDialog<bool>(
			context: context,
			builder: (context) {
				return StatefulBuilder(
						builder: (context, mSetState){
							return AlertDialog(
								contentPadding: hmSetEdgeInsetsAll(0.0),
								shape: new BeveledRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
								content: Container(
									width: 460,
									height: 500,
									padding: hmSetEdgeInsetsLTRB(20, 20, 20, 0),
									decoration: BoxDecoration(
											borderRadius: BorderRadius.circular(10.0),
											color: Colors.white
									),
									child: Column(
										children: <Widget>[
											Row(
												mainAxisSize:MainAxisSize.max,
												mainAxisAlignment:MainAxisAlignment.center,
												children: <Widget>[
													Text('就餐人数：',style: TextStyle(
															color:Color(0xff818693),
															fontSize: 20
													),),
													Listener(
														child: Image.asset('assets/images/icon/btn_renshu_-@2x.png',width: hmSetWidth(72)),
														onPointerDown: (event){
															mSetState(() {
																activeMember = activeMember > 0 ?	activeMember-1 : 0;
															});
														},
													),
													Container(
															margin: hmSetEdgeInsetsLTRB(10, 0, 10, 0),
															child: Text(activeMember.toString(), style: TextStyle(
																	color: Color(0xff818693),
																	fontSize: 24
															),)
													),
													Listener(
														child: Image.asset('assets/images/icon/btn_caishuliang_+_nor@2x.png',width: hmSetWidth(72)),
														onPointerDown: (event){
															mSetState(() {
																activeMember++;
															});
														},
													),
												],
											),
											Wrap(
													children: numberList.map((item) => Container(
														margin: hmSetEdgeInsetsAll(10.0),
														child: Listener(
															child: Container(
																width: 120,
																height: 80,
																alignment: Alignment.center,
																decoration: BoxDecoration(
																	color: Color(0xffF3F3F3),
																	borderRadius: BorderRadius.circular(10),
																),
																child: Text(item, style: TextStyle(
																		color: Color(0xff818693),
																		fontSize: 24
																)),
															),
															onPointerDown: (event) => {
																mSetState(() {
																	activeMember = int.parse(activeMember.toString()+item.toString());
																})
															},
														),
													)).toList()
											),
											Row(
												children: <Widget>[
													Listener(
														child: Container(
															margin: hmSetEdgeInsetsAll(10.0),
															width: 120,
															height: 80,
															alignment: Alignment.center,
															decoration: BoxDecoration(
																color: Color(0xffF3F3F3),
																borderRadius: BorderRadius.circular(10),
															),
															child: Text('0', style: TextStyle(
																	color: Color(0xff818693),
																	fontSize: 24
															)),
														),
														onPointerDown: (event) => {
															Navigator.of(context).pop(true)
														},
													),
													GestureDetector(
														child: Container(
															margin: hmSetEdgeInsetsAll(10.0),
															width: 120,
															height: 80,
															alignment: Alignment.center,
															decoration: BoxDecoration(
																gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
																borderRadius: BorderRadius.circular(10),
															),
															child: Text('确定', style: TextStyle(
																	color: Colors.white,
																	fontSize: 24
															)),
														),
														onTap: () => {
															if(activeMember != 0){
																Navigator.of(context).pop(true)
															}else{
																print('开桌人数不能为零')
															}
														},
													),
													GestureDetector(
														child: Container(
															margin: hmSetEdgeInsetsAll(10.0),
															width: 120,
															height: 80,
															alignment: Alignment.center,
															decoration: BoxDecoration(
																color: Color(0xffF3F3F3),
																borderRadius: BorderRadius.circular(10),
															),
															child: Text('取消', style: TextStyle(
																	color: Color(0xff818693),
																	fontSize: 24
															)),
														),
														onTap: () => {
															Navigator.of(context).pop(), // 关闭对话框
														},
													),
												],
											),
										],
									),
								),
							);
						});
			},
		);
	}

	// 换桌
	Future<bool> setTargetTable() {
		return showDialog<bool>(
			context: context,
			builder: (context) {
				return StatefulBuilder(
					builder: (context, mSetState){
						return AlertDialog(
							contentPadding: hmSetEdgeInsetsAll(0.0),
							shape: new BeveledRectangleBorder(borderRadius: BorderRadius.circular(20.0)),
							content: Container(
								width: hmSetWidth(890),
								height: hmSetHeight(633),
								decoration: BoxDecoration(
									borderRadius: BorderRadius.circular(10.0),
									color: Colors.white
								),
								child: Flex(
									direction: Axis.vertical,
									children: <Widget>[
										ConstrainedBox(
											constraints: BoxConstraints(
												minWidth: double.infinity, //宽度尽可能大
											),
											child: Container(
												height: hmSetHeight(86),
												padding: hmSetEdgeInsetsLTRB(20, 0, 0, 0),
												alignment: Alignment.centerLeft,
												decoration: BoxDecoration(
													border: Border(
														bottom: BorderSide(
															width: 1,
															color: Color(0xffD8DDE3),
														)
													),
												),
												child:Flex(
													direction: Axis.horizontal,
													children: <Widget>[
														Expanded(
															flex: 1,
															child:  Text('更换桌台', style: TextStyle(
																color: Color(0xff818693),
																fontSize: 24,
															)),
														),
														Padding(
															padding: hmSetEdgeInsetsLTRB(0, 0, 20, 0),
															child: GestureDetector(
																child: Image.asset('assets/images/icon/btn_tanchuang_guanbi@2x.png',width: 32,),
																onTap: (){
																	Navigator.of(context).pop(); // 关闭对话框
																},
															),
														),
													],
												)
											),
										),
										Expanded(
											flex: 1,
											child:Flex(
												direction: Axis.vertical,
												children: <Widget>[
													Expanded(
														flex: 0,
														child: Container(
															width: hmSetWidth(890),
															height: hmSetHeight(80),
															decoration: BoxDecoration(
																color: Colors.white,
																boxShadow: [
																	BoxShadow(
																		offset: Offset(0,2),
																		color: Color.fromRGBO(24,35,65,0.07),
																		blurRadius: 4, // 模糊
																		spreadRadius: 2,  //阴影的半经
																	)
																],
																borderRadius: BorderRadius.only(topLeft: Radius.elliptical(10,10)),
															),
															child: Row(
																	textDirection:TextDirection.ltr,
																	children: AreaList.map((n) => Container(
																			padding: EdgeInsets.only(top: 5, left: 30, right: 30,bottom: 0),
																			child: Listener(
																				child: topActState == n['area_name'] ?
																				Column(
																					children: <Widget>[
																						Container(
																							padding: EdgeInsets.only(top: 15),
																							child:Text(n['area_name'], style: TextStyle(
																								fontSize: 18,
																							)
																							),
																						),
																						Container(
																							width: hmSetWidth(40),
																							height: hmSetHeight(8),
																							margin: EdgeInsets.only(top: 4),
																							decoration: BoxDecoration(
																								gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)]),
																								borderRadius: BorderRadius.circular(
																									hmSetHeight(8.0),
																								),
																							),
																						)
																					],
																				) : Text(n['area_name'], style: TextStyle(fontSize: 18)),
																				onPointerDown: (event) async {
																						mSetState((){
																							topActState = n['area_name'];
																							areaId = n['area_Id'];
																						});
																						Map<String, dynamic> params = {'areaId':n['area_id'],'page': '1', 'pageSize': '100' };
																						final TableListData = await ApiService.openTablePanel(params);
																						if(TableListData['code'] == 200){
																							final data = TableListData['data']['tablePage']['items'];
																							final list = [];
																							data.forEach((n){
																								if(n['status'] == 0){
																									list.add(n);
																								}
																							});
																							mSetState(() {
																								TableList = list;
																							});
																						}
																				},
																			)
																	)).toList()
															)
														),
													),
													Expanded(
														flex: 1,
														child: Padding(
															padding: hmSetEdgeInsetsLTRB(20, 20, 20, 20),
															child: GridView.builder(
																padding: hmSetEdgeInsetsAll(0.0),
																shrinkWrap: true,
																gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
																	crossAxisCount: 5, //每行三列
																	mainAxisSpacing: 10, //主轴距离10
																	crossAxisSpacing: 7, // 交叉轴距离7
																	childAspectRatio: 1.5 //显示区域宽高相等
																),
																itemCount:TableList.length,
																itemBuilder:(BuildContext context, int index) {
																	final item = TableList[index];
																	final iconUrl = 'assets/images/icon/icon_card_free_nor@2x.png';
																	final iconUrlAc = 'assets/images/icon/icon_card_free_sel@2x.png';
																	return GestureDetector(
																		child: Container(
																			width: hmSetWidth(216),
																			height: hmSetHeight(156),
																			padding: EdgeInsets.only(left: 15, right: 15,top: 10,bottom: 10),
																			margin: EdgeInsets.all(10),
																			decoration: BoxDecoration(
																				color: activeTableId == item['tableId'] ? Color(0xff556388) : Colors.white,
																				borderRadius: BorderRadius.circular(6.0),
																				border: Border.all(color: Color(0xffD8DDE3)),
																				boxShadow: [
																					BoxShadow(
																						offset: Offset(0,2),
																						color: Color.fromRGBO(0, 0, 0, 0.07),
																						blurRadius: 4, // 模糊
																						spreadRadius: 2,  //阴影的半经
																					)
																				]
																			),
																			child: Flex(
																				direction: Axis.vertical,
																				children: <Widget>[
																					Expanded(
																						flex: 1,
																						child: Row(
																							children: <Widget>[
																								Image.asset(activeTableId == item['tableId'] ? iconUrlAc : iconUrl,width: 32),
																								Text('空闲中', style:TextStyle(
																									fontSize: 18,
																									color: activeTableId == item['tableId'] ? Color(0xffFFEFD9) : Color(0xff818693)
																								)),
																							],
																						),
																					),
																					Text(item['tableName'], style: TextStyle(
																						fontSize: 18,
																						color: activeTableId == item['tableId'] ? Color(0xffFFEFD9) : Color(0xffBAC0CD)
																					),)
																				],
																			),
																		),
																		onTap: (){
																			mSetState((){
																				activeTableId = item['tableId'];
																				changeTableData = item;
																			});
																		},
																	);
																}
															),
														),
													),
												],
											)
										),
										Container(
											height: hmSetHeight(136),
											child: Row(
												mainAxisSize:MainAxisSize.max,
												mainAxisAlignment:MainAxisAlignment.end,
												children: <Widget>[
													Listener(
														child: Container(
															width: 120,
															height: 60,
															alignment: Alignment.center,
															decoration: BoxDecoration(
																borderRadius: BorderRadius.circular(10),
																border:Border.all(
																	width: 1,
																	color:Color(0xffC0C4CD)
																)
															),
															child: Text('取消', style: TextStyle(
																color: Color(0xff818693),
																fontSize: 18
															)),
														),
														onPointerDown: (event) => {
															Navigator.of(context).pop(), // 关闭对话框
														},
													),
													Listener(
														child: Container(
															margin: hmSetEdgeInsetsLTRB(43, 0, 20, 0),
															width: 120,
															height: 60,
															alignment: Alignment.center,
															decoration: BoxDecoration(
																gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
																borderRadius: BorderRadius.circular(10),
															),
															child: Text('确定', style: TextStyle(
																color: Colors.white,
																fontSize: 18
															)),
														),
														onPointerDown: (event) => {
															Navigator.of(context).pop(true)
														},
													),
												],
											),
										)
									],
								),
							),
						);
					},
				);
			},
		);
	}
}

// 添加到购物车的下单列表 --- start ---
class OrderList extends StatelessWidget{
	OrderList({Key key, this.checkList, this.onHandle, this.dishMarkhandle}) : super(key: key);

	List checkList;
	Function onHandle;
	Function dishMarkhandle;

	@override
	Widget build(BuildContext context) {
		return Container(
			padding: hmSetEdgeInsetsLTRB(20, 0, 20, 0),
			decoration: BoxDecoration(
				borderRadius: BorderRadius.only(topLeft: Radius.elliptical(6,6),topRight: Radius.elliptical(6,6)),
				color: Colors.white
			),
			child: Flex(
				direction: Axis.vertical,
				children: <Widget>[
					Expanded(
						flex: 1,
						child: Scrollbar(
							child: ListView.builder(
								itemCount: checkList.length,
								itemBuilder: (BuildContext context, int index) {
									final data = checkList[index];
									final flavorList = data['flavorList'];
									print(flavorList);
									return Flex(
										direction: Axis.vertical,
										children: <Widget>[
											Container(
												padding: hmSetEdgeInsetsLTRB(0, 10, 0, 10),
												child: Flex(
													direction: Axis.horizontal,
													children: <Widget>[
														Expanded(
															flex: 1,
															child: Container(
																child: GestureDetector(
																	child: Column(
																		children: <Widget>[
																			Row(
																				children: <Widget>[
																					Text(data['dishName'].toString(),textAlign:
																					TextAlign.left,style: TextStyle(
																							fontSize: 18,color: Color(0xff20232A)
																					),
																					),
																				],
																			),
																			Row(
																				children: <Widget>[
																					Text('￥ ${data['price']/100} ', style: TextStyle(color:Color(0xffE9503E),fontSize: 18),),
																					Expanded(
																						flex: 1,
																						child: Row(
																							children: flavorList.length > 0 ? flavorList.map<Widget>((it){
																								return Container(
																									padding: hmSetEdgeInsetsLTRB(6, 1, 6, 1),
																									margin: hmSetEdgeInsetsLTRB(10, 0, 0, 0),
																									decoration: BoxDecoration(
																										color: Color(0xffF3F4F7),
																										border: Border.all(color: Color(0xffD5D7DF)),
																										borderRadius:BorderRadius.all(Radius.elliptical(20,20)),
																									),
																									child: Text(it,style: TextStyle(
																										fontSize: 10.0,
																										color: Color(0xff818693)
																									),
																									)
																								);
																							}).toList() : <Widget> [Text('')]
																						),
																					),

																				],
																			)
																		],
																	),
																	onTap: (){
																		if (data['orderState'] == null) {
																			dishMarkhandle(data);
																		}
																	},
																),
															),
														),
														Container(
															child: Row(
																children: <Widget>[
																	GestureDetector(
																		child: Image.asset('assets/images/icon/btn_renshu_-@2x.png', width: 24,),
																		onTap: (){
																			if (data['orderState'] == null) {
																				onHandle(data, 'rec');
																			}
																		},
																	),
																	Container(
																		child: Text(' ${data['dishNumber']} '),
																	),
																	GestureDetector(
																		child: Image.asset('assets/images/icon/btn_caishuliang_+_nor@2x.png',width: 24,),
																		onTap: (){
																			if (data['orderState'] == null) {
																				onHandle(data, 'add');
																			}
																		},
																	),
																],
															),
														)
													],
												),
											),
											BorderDotted(color: Color(0xffD1D5E1)),
										],
									);
								},
							),
						),
					),

				],
			)
		);
	}
}
// 添加到购物车的下单列表 --- end ---

// 底部按钮列表 -- start --
class BottomButList extends StatefulWidget{
	BottomButList({Key key, this.onHandle, this.tableId}) : super(key: key);

	String tableId;
	Function onHandle;

	@override
	_BottomButList createState() => new _BottomButList();
}

class _BottomButList extends State<BottomButList> {

	@override
	Widget build(BuildContext context) {
		return Flex(
			direction: Axis.horizontal,
			children: <Widget>[
				Expanded(
					flex: 1,
					child: Row(
						children: <Widget>[
							Padding(
								padding: EdgeInsets.only(left: 30),
								child: OutlineButton(
									padding: EdgeInsets.only(left: 30,top: 15, bottom: 15, right: 30),
									color: Colors.white,
									shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
									child:  Row(
										children: <Widget>[
											Image.asset('assets/images/icon/icon_btn_qingtai@2x.png',width: 24,),
											Text(' 一键清台',style: TextStyle(fontSize: 18,color: Color(0xff818693)),)
										],
									),
									onPressed: () {
										widget.onHandle('clear');
									},
								),
							),
							Padding(
								padding: EdgeInsets.only(left: 30),
								child: OutlineButton(
									padding: EdgeInsets.only(left: 30,top: 15, bottom: 15, right: 30),
									color: Colors.white,
									shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
									child:  Row(
										children: <Widget>[
											Image.asset('assets/images/icon/icon_btn_beizhu@2x.png',width: 24,),
											Text(' 整单备注',style: TextStyle(fontSize: 18,color: Color(0xff818693)),)
										],
									),
									onPressed: () {
										widget.onHandle('mark');
									},
								),
							),
							Padding(
								padding: EdgeInsets.only(left: 30),
								child: OutlineButton(
									padding: EdgeInsets.only(left: 45,top: 15, bottom: 15, right: 45),
									color: Colors.white,
									shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
									child:  Row(
										children: <Widget>[
											Image.asset('assets/images/icon/icon_btn_jiacai@2x.png',width: 24,),
											Text(' 加菜',style: TextStyle(fontSize: 18,color: Color(0xff818693)),)
										],
									),
									onPressed: () {
										widget.onHandle('addDish');
									},
								),
							),
							Padding(
								padding: EdgeInsets.only(left: 30),
								child: OutlineButton(
									padding: EdgeInsets.only(left: 45,top: 15, bottom: 15, right: 45),
									color: Colors.white,
									shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
									child: Row(
										children: <Widget>[
											Image.asset('assets/images/icon/icon_btn_xiadan@2x.png',width: 24,),
											Text(' 下单',style: TextStyle(fontSize: 18,color: Color(0xff818693)),)
										],
									),
									onPressed: () {
										widget.onHandle('order');
									},
								),
							)
						],
					),
				),
				Row(
					textDirection: TextDirection.rtl,
					children: <Widget>[
						Container(
							width: hmSetWidth(136),
							margin: EdgeInsets.only(right: 20),
							decoration: BoxDecoration(
								gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
								borderRadius: BorderRadius.circular(4)
							),
							child:  StoreConnector(
								converter: (store) {
									return () => store.dispatch('acc');
								},
								builder: (context, callback) {
									return OutlineButton(
										padding: EdgeInsets.only(left: 30,top: 15, bottom: 15, right: 30),
										color: Colors.transparent,
										shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
										child: Text('结账',
											style: TextStyle(
												color: Colors.white,
												fontSize: 18
											),
										),
										onPressed: () async{
											Map data = await ApiService.getOrderDetile(widget.tableId);
											if(data['code'] == 200){
												print(data['data']['orderId']);
												if(data['data']['orderId'] == null){
													hmShowTosta('还未下单,请先下单!');
												} else {
													callback();
												}
											}else{
												hmShowTosta('请求出错了!');
											}
										},
									);
								}
							),
						),
						Container(
							width: hmSetWidth(136),
							margin: EdgeInsets.only(right: 20),
							decoration: BoxDecoration(
								gradient: LinearGradient(colors: [Color(0xFF4FBFFF), Color(0xFF208DFF)],begin:FractionalOffset(1, 0)),// 渐变色
								borderRadius: BorderRadius.circular(4)
							),
							child: OutlineButton(
								padding: EdgeInsets.only(left: 30,top: 15, bottom: 15, right: 30),
								color: Colors.transparent,
								shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
								child: Text('补单',
									style: TextStyle(
										color: Colors.white,
										fontSize: 18
									),
								),
								onPressed: () {
									print('打印小票');
//									widget.onHandle();
								},
							),
						),
					],
				)
			],
		);
	}
}
// 底部按钮列表 -- end --
