import 'dart:typed_data';

import 'dart:convert' as convert;
import 'package:chanzhanggui_syd/utils/function.dart';
import 'package:flutter/material.dart';
import 'package:chanzhanggui_syd/widgets/Menulist.dart';
import 'package:flutter/widgets.dart';
import 'package:chanzhanggui_syd/widgets/border.dart';
import 'package:chanzhanggui_syd/common/api/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chanzhanggui_syd/widgets/search_bar_demo.dart';

class Accounts extends StatefulWidget {
	Accounts({Key key}) : super(key: key);

	@override
	_Accounts createState() => new _Accounts();
}

class _Accounts extends State<Accounts> {

	static Map TableData = {}; // 桌台的信息
	static Map orderData = {}; // 订单信息
	static String total = '';
	static List reasonsList = [];
	static List reasons = [];
	static String title = '赠菜原因';
	static String activeState = ''; // 点击弹出 赠菜、退菜操作窗口

	@override
	void initState() {
		super.initState();
		// 加载列表
		getOrderdata();
	}

	getOrderdata() async{
		String tableData = await FlutterSecureStorage().read(key: 'checkTableData');
		Map itemData = convert.jsonDecode(tableData);
		Map data = await ApiService.getOrderDetile(itemData['tableId']);
		if(data['code'] == 200){
			final dataes = data['data'];
			setState(() {
				TableData = itemData;
				orderData = dataes;
			});
		} else {
			hmShowTosta('请求出错了！');
		}
	}
// 获取备注列表
	getRemarkList(type) async{
		final data = await ApiService.remark(type);
		setState(() {
			reasonsList = data['data'];
		});
	}

	// 赠菜、退菜
	onHandle(item, st) async{
		setState(() {
			title = st == 'presentation' ? '赠菜原因' : '退菜原因';
		});
		getRemarkList(st == 'presentation' ? '1' : '6');
		bool delete = await setDish();
		if (delete == null) {
			print("取消");
		} else {
			Map params = {'detailId': item['detailId'], 'remarks':reasons};
     if(st == 'presentation') {
     	 final data = await ApiService.presentDish(params);
     	 print(data);
		 } else if(st == 'back'){
			 final data = await ApiService.backDish(params);
			 print(data);
		 }
		 getOrderdata();
     setState(() {
			 reasons = [];
			 activeState = '';
     });
		}
	}

  // 点击弹出 赠菜、退菜操作窗口
	activeHandle(id){
		setState(() {
			activeState = id;
		});
	}

	@override
	Widget build(BuildContext context) {
		final time = new DateTime(2020,2,2);
		print(DateTime.parse(time.toIso8601String()));
		final dataTime = DateTime.parse(!orderData.isEmpty ? orderData['createTime']: time.toIso8601String());
		String tiemTitle = dataTime.year.toString() + '-'+ dataTime.month.toString()+ '-'+ dataTime.day.toString() + " " +dataTime.hour.toString() + ':'+ dataTime.minute.toString()+ ':'+ dataTime.second.toString();
		return !orderData.isEmpty ? Flex(
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
									decoration: BoxDecoration(
										borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(6,6),bottomRight: Radius.elliptical(6,6)),
										color: Colors.white
									),
									child: Flex(
										direction: Axis.vertical,
										children: <Widget>[
											Container(
												padding: hmSetEdgeInsetsAll(15.0),
												decoration: BoxDecoration(
													color: Colors.white,
													border: Border(
														bottom: BorderSide(
															color: Color.fromRGBO(24,35,65,0.07),
															width: 2,
														)
													),
												),
												child: Column(
													children: <Widget>[
														Row(
															children: <Widget>[
																Container(
																	child: Text('流水号：${orderData['orderNumber']}',
																		textAlign: TextAlign.left,
																		style: TextStyle(
																			color: Color(0xff818693),
																			fontSize: 18
																		),
																	),
																),
															],
														),
														Row(
															children: <Widget>[
																Container(
																	margin: EdgeInsets.only(top: 10.0),
																	child: Text('日期：$tiemTitle',
																		textAlign: TextAlign.left,
																		style: TextStyle(
																			color: Color(0xff818693),
																			fontSize: 18
																		),
																	),
																),
															],
														)
													],
												),
											),
											Expanded(
												flex: 1,
												child: OrderList(orderList:orderData, onHandle:onHandle, activeState: activeState, activeHandle: activeHandle),
											),
											Container( // 备注
												padding: hmSetEdgeInsetsAll(15.0),
												decoration: BoxDecoration(
													color: Color(0xffFBE9E7)
												),
												child: Row(
													children: <Widget>[
														Image.asset('assets/images/icon/icon_beizhu@2x.png',width: 22),
														Container(
															child: Text('备注',style: TextStyle(color:Color(0xffFFB302),fontSize: 14)),
														),
														Row(
															children: orderData['orderRemark'].map<Widget>((n) => Container(
																padding: hmSetEdgeInsetsLTRB(6, 1, 6, 1),
																margin: hmSetEdgeInsetsLTRB(10, 0, 5, 0),
																decoration: BoxDecoration(
																	color: Color(0xffFFF4F3),
																	border: Border.all(color: Color(0xffFFC5C5)),
																	borderRadius:BorderRadius.all(Radius.elliptical(20,20)),
																),
																child: Text(n ,style: TextStyle(fontSize: 10.0,color: Color(0xffF56C6C)),),
															)).toList(),
														),
													],
												),
											),
											Container( // 总价
												padding: hmSetEdgeInsetsAll(19.0),
												decoration: BoxDecoration(
													color: Color(0xffF56C6C),
													borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(6,6),bottomRight: Radius.elliptical(6,6)),
												),
												child: Row(
													textDirection: TextDirection.rtl,
													children: <Widget>[
														Text('￥${orderData['totalAmount']/100 }',style: TextStyle(color: Colors.white,fontSize: 18)),
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
									decoration: BoxDecoration(
										color: Colors.white,
										borderRadius: BorderRadius.all(Radius.elliptical(6,6)),
									),
									child:new AccountsList(TableData:TableData, orderData: orderData),
								),
							],
						),
					),
				),
			],
		) : Text('');
	}

	// 赠菜、退菜 弹窗
	Future<bool> setDish(){
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
															child:  Text(title, style: TextStyle(
																color: Color(0xff818693),
																fontSize: 24,
															),),
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

}

// 添加到购物车的下单列表 --- start ---
class OrderList extends StatefulWidget {
	OrderList({Key key, this.orderList,  this.onHandle, this.activeState, this.activeHandle}) : super(key: key);

	final Map orderList;
	final Function onHandle;
	final Function activeHandle;
	final String activeState;

	@override
	_OrderList createState() => new _OrderList();
}

class _OrderList extends State<OrderList>{
	@override
	Widget build(BuildContext context) {
		final data = widget.orderList['dishs'];
		return Container(
			padding: hmSetEdgeInsetsLTRB(20, 0, 10, 10),
			decoration: BoxDecoration(
				color: Colors.white
			),
			child: Flex(
				direction: Axis.vertical,
				children: <Widget>[
					Expanded(
						flex: 1,
						child: Scrollbar(
							child: Container(
								padding: EdgeInsets.only(right: 10),
								child: ListView.builder(
									padding: EdgeInsets.only(top: 0),
									itemCount: data.length,
									itemBuilder: (BuildContext context, int index) {
										final item = data[index];
										final activeState = widget.activeState;
										return Flex(
											direction: Axis.vertical,
											children: <Widget>[
												Container(
													padding: hmSetEdgeInsetsLTRB(0, 15, 0, 15),
													child: Flex(
														direction: Axis.vertical,
														children: <Widget>[
															GestureDetector(
																child: Column(
																	children: <Widget>[
																		Row(
																			children: <Widget>[
																				Text('${item['dishName']}',textAlign: TextAlign.left,style: TextStyle(fontSize: 18,color: Color(0xff20232A)),),
																			],
																		),
																		Flex(
																			direction: Axis.horizontal,
																			children: <Widget>[
																				Row(
																					children: <Widget>[
																						Text('￥${(item['price']/100).toString()} ', style: TextStyle(color: Color(0xffE9503E),fontSize: 20),),
																						Text('x ${item['dishNumber']}', style: TextStyle(color: Color(0xff818693), fontSize: 18),)
																					],
																				),
																				Expanded(
																					flex: 1,
																					child: Row(
																						textDirection:TextDirection.rtl,
																						children:item['flavorList'] != null ? item['flavorList'].map<Widget>((n)=> Container(
																							margin: hmSetEdgeInsetsLTRB(10, 0, 0, 0),
																							padding: hmSetEdgeInsetsLTRB(6, 1, 6, 1),
																							decoration: BoxDecoration(
																								color: Color(0xffF3F4F7),
																								border: Border.all(color: Color(0xffD5D7DF)),
																								borderRadius:BorderRadius.all(Radius.elliptical(20,20)),
																							),
																							child: Text(n,style: TextStyle(fontSize: 10.0,color: Color(0xff818693)),),
																						)).toList(): Text('')
																					),
																				),
																			],
																		),
																	],
																),
																onTap: (){
																	widget.activeHandle(item['dishId']);
																},
															),
															activeState ==  item['dishId']?
															Container(
																height:hmSetHeight(86),
																margin:hmSetEdgeInsetsLTRB(0, 10, 0, 0),
																decoration: BoxDecoration(
																	border:Border.all(color: Color(0xffD8DDE3)),
																	color: Color(0xffF3F4F7),
																	borderRadius:BorderRadius.all(Radius.elliptical(6,6)),
																),
																child: Flex(
																	direction: Axis.horizontal,
																	children: <Widget>[
																		Expanded(
																			flex: 1,
																			child: Container(
																				margin: hmSetEdgeInsetsLTRB(20, 0, 10, 0),
																				height: hmSetHeight(50),
																				decoration: BoxDecoration(
																					gradient: LinearGradient(colors: [Color(0xFF4FBFFF), Color(0xFF208DFF)],begin:FractionalOffset(1, 0)),// 渐变色
																					borderRadius: BorderRadius.circular(4)
																				),
																				child: OutlineButton(
																					color: Colors.transparent,
																					shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
																					child: Text('赠菜',
																						style: TextStyle(
																							color: Colors.white,
																							fontSize: 14
																						),
																					),
																					onPressed: () {
																						widget.onHandle(item, 'presentation');
																					},
																				),
																			),
																		),
																		Expanded(
																			flex: 1,
																			child: Container(
																				margin: hmSetEdgeInsetsLTRB(20, 0, 10, 0),
																				height: hmSetHeight(50),
																				decoration: BoxDecoration(
																					gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
																					borderRadius: BorderRadius.circular(4)
																				),
																				child: OutlineButton(
																					color: Colors.transparent,
																					shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
																					child: Text('退菜',
																						style: TextStyle(
																							color: Colors.white,
																							fontSize: 14
																						),
																					),
																					onPressed: () {
																						widget.onHandle(item, 'back');
																					},
																				),
																			),
																		),
																	],
																),
															) : Text('')
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
					),

				],
			)
		);
	}
}
// 添加到购物车的下单列表 --- end ---


// 结账右侧列表 - start -
class AccountsList extends StatefulWidget{
	AccountsList({Key key, this.TableData, this.orderData}) : super(key: key);

	Map TableData;
	Map orderData;

	_AccountsList createState() => _AccountsList(TableData:TableData,orderData:orderData);
}

class _AccountsList extends State<AccountsList>{
	_AccountsList({Key key, this.TableData, this.orderData});

	var radio = '现金结账';
	var smallChange = '';
	Map TableData;
	Map orderData;
	String amount = '0'; // 现金
	int payType = 0;
	Map orderDetails;
	String creditType = '0' ; // 挂账类型
	String creditId = ''; // 挂账公司ID
	String creditName = ''; //挂账公司Name
	String creditUserName; // 挂账公司人
	List creditData = [];
	List creditCompayData = [];
  List numList = ['7','8','9','10','4','5','6','20', '1', '2', '3', '50', '0', '.', 'del', '100'];
  int payAmount = 0; // 应收金额
	int discount = 0; //抹零

	@override
	void initState() {
		super.initState();
		// 加载列表
		setState(() {
			orderDetails = convert.jsonDecode(convert.jsonEncode(orderData));
			payAmount = orderDetails['totalAmount'];
		});
	}
  // 挂账人/公司选择
	searchHandle(item){
		setState(() {
			creditId = item['creditId'];
			creditName = item['companyName'] != '' ? item['companyName'] : item['userName'];
		});
	}

  // 计算器按钮
  numHandle(num){
		String number;
		if (num == 'del'){
			number = amount.length > 0 ? amount.substring(0,amount.length-1) : '0';
		} else {
			number = amount == '0' ? num : amount + num;
		}
		setState(() {
			amount = number;
		});
	}
	//  重置
	retAmount(){
		setState(() {
			payAmount = orderDetails['totalAmount'];
			discount = 0;
			smallChange = '';
		});
	}

	// 付款方式单选
	radHandle(st) async{
  	if (st == '抹零') {
			final num = (payAmount/100).toString();
			final dbNum = int.parse(num.substring(0,num.lastIndexOf(".")));
			print(dbNum);
			setState(() {
				payAmount = dbNum*100;
				discount = orderData['totalAmount'] - dbNum*100;
				smallChange = st;
			});
		} else if(st == '挂账') {
        Map creditDataes = await ApiService.getCreditList('2');
				Map creditCompayDataes = await ApiService.getCreditList('1');
        setState(() {
					creditData = creditDataes['data'];
					creditCompayData = creditCompayDataes['data'];
        });
				bool delete = await SetAccountsType();
				if (delete == null) {
					print("取消");
				} else {
						setState(() {
							payType = 3;
							radio = st;
						});
				}
		} else {
  		int type = 0;
  		switch(st){
				case '现金结账' :
					type = 0 ;
					break;
				case '微信' :
					type = 1 ;
					break;
				case '支付宝' :
					type = 2 ;
					break;
				case '挂账' :
					type = 3 ;
					break;
				case '免单' :
					type = 4 ;
					break;
			}
			setState(() {
				payType = type;
				radio = st;
			});
		}
	}

   // 结账
	accounts() async{
  	Map params = {
  		'orderId':orderData['orderId'],
			'payType': payType,
			'payAmount':payAmount,
			'smallAmount': discount,
			'creditId': creditId,
			'creditUserName': creditName,
			'creditAmount': payAmount
  	};
  	print(params);
	  Map data = await ApiService.accouts(params);
	  if(data['code'] == 200){
	  	return true;
		}
	  return false;
	}


  @override
  Widget build(BuildContext context) {
    return Flex(
			direction: Axis.vertical,
			children: <Widget>[
				Container(
						padding: hmSetEdgeInsetsLTRB(0, 20, 0, 20),
						child: Flex(
							direction: Axis.horizontal,
							children: <Widget>[
								Expanded(
									flex: 1,
									child: Container(
										child: Column(
											children: <Widget>[
												Padding(
													padding: EdgeInsets.only(bottom: 20),
													child: new RadioBox(action: this.radio, title: '现金结账', IconUrl: 'assets/images/icon/icon_xianjin@2x.png', onHandle:radHandle),
												),
												new RadioBox(action: this.smallChange, title: '抹零', IconUrl: 'assets/images/icon/icon_moling@2x.png', onHandle:radHandle),
											],
										),
									),
								),
								Expanded(
									flex: 1,
									child: Container(
										decoration: BoxDecoration(
											border: Border(
												left: BorderSide(
													color: Color(0xffD1D5E1)
												),
												right: BorderSide(
													color: Color(0xffD1D5E1)
												),
											)
										),
										child: Column(
											children: <Widget>[
												Padding(
													padding: EdgeInsets.only(bottom: 20),
													child: new RadioBox(action: this.radio, title: '挂账', IconUrl: 'assets/images/icon/icon_guazhang@2x.png', onHandle:radHandle),
												),
												new RadioBox(action: this.radio, title: '微信支付', IconUrl: 'assets/images/icon/icon_weixin@2x.png', onHandle:radHandle),
											],
										),
									),
								),
								Expanded(
									flex: 1,
									child: Container(
										child: Column(
											children: <Widget>[
												Padding(
													padding: EdgeInsets.only(bottom: 20),
													child: new RadioBox(action: this.radio, title: '免单', IconUrl: 'assets/images/icon/icon_miandan@2x.png', onHandle:radHandle),
												),
												new RadioBox(action: this.radio, title: '支付宝', IconUrl: 'assets/images/icon/icon_zhifubao@2x.png', onHandle:radHandle),
											],
										),
									),
								),
							],
						),
				),
				Expanded(
					flex: 1,
					child: Text(''),
				),
				Container( // 消费金额
					decoration: BoxDecoration(
						border: Border(
							top: BorderSide(
								color: Color.fromRGBO(24,35,65,0.07),
								width: 1,
							)
						)
					),
					child: Flex(
						direction: Axis.horizontal,
						children: <Widget>[
							Expanded(
								flex: 1,
								child: Container(
									padding: hmSetEdgeInsetsAll(20.0),
									decoration: BoxDecoration(
										border: Border(
											right: BorderSide(
												color: Color.fromRGBO(24,35,65,0.07),
												width: 1,
											)
										)
									),
									child: Flex(
										direction: Axis.vertical,
										children: <Widget>[
											Container(
												child: Row(
													children: <Widget>[
														Text('消费金额： ', style: TextStyle(
															color: Color(0xff818693),
														),),
														Text('￥ ${widget.orderData['totalAmount']/100}')
													],
												),
											),
											Container(
												margin: EdgeInsets.only(top: 10),
												child: Row(
													children: <Widget>[
														Text('应收金额： ', style: TextStyle(
															color: Color(0xff818693),
														),),
														Text('￥ ${payAmount/100}')
													],
												),
											)
										],
									),
								),
							),
							Expanded(
								flex: 1,
								child: Container(
									padding: hmSetEdgeInsetsAll(20.0),
									child: Flex(
										direction: Axis.vertical,
										children: <Widget>[
											Container(
												child: Row(
													children: <Widget>[
														Text('优惠金额： ', style: TextStyle(
															color: Color(0xff818693),
														),),
														Text('￥${discount/100}')
													],
												),
											),
											Container(
												margin: EdgeInsets.only(top: 10),
												child: Row(
													children: <Widget>[
														Container(
															width: hmSetWidth(100),
															height: hmSetHeight(40),
															decoration: BoxDecoration(
																gradient: LinearGradient(colors: [Color(0xFF4FBFFF), Color(0xFF208DFF)],begin:FractionalOffset(1, 0)),// 渐变色
																borderRadius: BorderRadius.circular(4)
															),
															child: OutlineButton(
																color: Colors.transparent,
																shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
																child: Text('重置',
																	style: TextStyle(
																		color: Colors.white,
																		fontSize: 14
																	),
																),
																onPressed: () {
																	retAmount();
																},
															),
														),
													],
												),
											)
										],
									),
								),
							),
						],
					),
				),
				Container( // 现金抹零
					height: hmSetHeight(80),
					decoration: BoxDecoration(
						border: Border(
							top: BorderSide(
								color: Color.fromRGBO(24,35,65,0.07),
								width: 1,
							)
						)
					),
					child: Flex(
						direction: Axis.horizontal,
						children: <Widget>[
							Expanded(
								flex: 1,
								child: Container(
									padding: hmSetEdgeInsetsLTRB(20, 0, 20,0),
									decoration: BoxDecoration(
										border: Border(
											right: BorderSide(
												color: Color.fromRGBO(24,35,65,0.07),
												width: 1,
											)
										)
									),
									child: Row(
										crossAxisAlignment:CrossAxisAlignment.center,
										children: <Widget>[
											Text('现金', style: TextStyle(
												color: Color(0xff818693),
											)),
											Container(
												width: hmSetHeight(200),
												height: hmSetHeight(44),
												child:Text('￥ ${amount}',textAlign: TextAlign.center, style: TextStyle(
													color: Color(0xffE9503E),
													fontSize: 22,
												)),
											)
										],
									)
								),
							),
							Expanded(
								flex: 1,
								child: Container(
									padding: hmSetEdgeInsetsLTRB(20, 0, 20,0),
									decoration: BoxDecoration(
										border: Border(
											right: BorderSide(
												color: Color.fromRGBO(24,35,65,0.07),
												width: 1,
											)
										)
									),
									child: Row(
										crossAxisAlignment:CrossAxisAlignment.center,
										children: <Widget>[
											Text('抹零', style: TextStyle(
												color: Color(0xff818693),
											)),
											Container(
												width: hmSetHeight(200),
												height: hmSetHeight(44),
												child:Text('￥ ${discount/100}',textAlign: TextAlign.center, style: TextStyle(
													color: Color(0xffE9503E),
													fontSize: 22,
												)),
											)

										],
									)
								),
							),
						],
					),
				),
				Container(
					height: hmSetHeight(325),
					padding: hmSetEdgeInsetsLTRB(20, 0, 20, 0),
					decoration: BoxDecoration(
						color: Colors.white,
						borderRadius: BorderRadius.only(bottomLeft: Radius.elliptical(6,6),bottomRight: Radius.elliptical(6,6)),
						boxShadow: [BoxShadow(
							offset: Offset(0,4),
							color: Color.fromRGBO(24, 35, 65, 0.1),
							blurRadius: 4, // 模糊
							spreadRadius: 4,  //阴影的半经
						)]
					),
					child: Flex(
						direction: Axis.horizontal,
						children: <Widget>[
							Expanded(
								flex: 1,
								child: Container(
									child: GridView.builder(
										padding: hmSetEdgeInsetsAll(0.0),
										shrinkWrap: true,
										gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
											crossAxisCount: 4, //每行三列
											mainAxisSpacing: 10, //主轴距离10
											crossAxisSpacing: 7, // 交叉轴距离7
											childAspectRatio: 2.0 //显示区域宽高相等
										),
										itemCount:numList.length,
										itemBuilder:(BuildContext context, int index) {
											return NumBut(num: numList[index],onHandle: numHandle);
										}
									),
								)
							),
							Container(
								padding: hmSetEdgeInsetsLTRB(0, 20, 0, 0),
								child: Column(
									children: <Widget>[
										Container(
											width: hmSetWidth(210),
											height: hmSetHeight(60),
											margin: EdgeInsets.only(left: 10),
											decoration: BoxDecoration(
												gradient: LinearGradient(colors: [Color(0xFF4FBFFF), Color(0xFF208DFF)],begin:FractionalOffset(1, 0)),// 渐变色
												borderRadius: BorderRadius.circular(4)
											),
											child: OutlineButton(
												padding: EdgeInsets.only(left: 30,top: 15, bottom: 15, right: 30),
												color: Colors.transparent,
												shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
												child: Text('打印结账单',
													style: TextStyle(
														color: Colors.white,
														fontSize: 14
													),
												),
												onPressed: () {},
											),
										),
										Container(
											width: hmSetWidth(210),
											height: hmSetHeight(60),
											margin: EdgeInsets.only(left: 10,top: 10,bottom: 10),
											child: StoreConnector(
												converter: (store) {
													return () => store.dispatch('meal');
												},
												builder: (context, callback,) {
													return OutlineButton(
														color: Colors.transparent,
														shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
														child: Text('返回',
															style: TextStyle(
																fontSize: 14
															),
														),
														onPressed: () {
															callback();
														},
													);
												}
											),
										),
										Container(
											width: hmSetWidth(210),
											height: hmSetHeight(138),
											margin: EdgeInsets.only(left: 10),
											decoration: BoxDecoration(
												gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
												borderRadius: BorderRadius.circular(4)
											),
											child: StoreConnector(
												converter: (store) {
													return () => store.dispatch('ind');
												},
												builder: (context, callback,) {
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
															bool data = await accounts();
															if (data){
																callback();
															}
														},
													);
												}
											),
										),
									],
								),
							),
						],
					),
				)
			],
		);
  }

	// 设置挂账
	Future<bool> SetAccountsType(){
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
								height: hmSetHeight(423),
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
															child:  Text('挂账', style: TextStyle(
																color: Color(0xff818693),
																fontSize: 24,
															),),
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
														Container(
															margin:hmSetEdgeInsetsLTRB(30, 40, 30, 15),
															child: Row(
																children: <Widget>[
																	Container(
																		width:hmSetWidth(100),
																		child: Text('挂账类型',style: TextStyle(fontSize: 18),),
																	),
																	Container(
																		margin: hmSetEdgeInsetsLTRB(0, 0, 50, 0),
																		child: GestureDetector(
																			child: Row(
																				children: <Widget>[
																					Container(
																						width: 16,
																						height: 16,
																						decoration: BoxDecoration(
																								borderRadius: BorderRadius.circular(16.0),
																								border: creditType == '0'
																										? Border.all(color: Color(0xff419EFF),width: 6)
																										: Border.all(color: Color(0xffD5D8DE),width: 1)
																						),
																					),
																					Text(' 公司')
																				],
																			),
																			onTap: (){
																				mSetState((){
																					creditType = '0';
																				});
																			},
																		),
																	),
																	Container(
																		child: GestureDetector(
																			child: Row(
																				children: <Widget>[
																					Container(
																						width: 16,
																						height: 16,
																						decoration: BoxDecoration(
																								borderRadius: BorderRadius.circular(16.0),
																								border: creditType == '1'
																										? Border.all(color: Color(0xff419EFF),width: 6)
																										: Border.all(color: Color(0xffD5D8DE),width: 1)
																						),
																					),
																					Text(' 个人')
																				],
																			),
																			onTap: (){
																				mSetState((){
																					creditType = '1';
																				});
																			},
																		),
																	)

																],
															)
														),
														creditType == "0" ? Container(
																margin:hmSetEdgeInsetsLTRB(30, 10, 30, 15),
																child: Row(
																	children: <Widget>[
																		Container(
																			width:hmSetWidth(100),
																			child: Text('挂账公司', style: TextStyle(fontSize: 18)),
																		),
																		Container(
																			width: hmSetWidth(300),
																			height: hmSetHeight(40),
																			padding: hmSetEdgeInsetsLTRB(15, 0, 0, 0),
																			decoration: BoxDecoration(
																					borderRadius: BorderRadius.circular(6.0),
																					border: Border.all(color: Color(0xffD8DDE3),width: 1)
																			),
																			child: Row(
																				children: <Widget>[
																					Container(
																						width: hmSetWidth(230),
																						child: Text(creditName),
																					),
																					SearchBarDemo(onHandle:searchHandle,searchData:creditCompayData),
																				],
																			),
																		)
																	],
																)
														) : Text(''),
														creditType == "1" ? Container(
																margin:hmSetEdgeInsetsLTRB(30, 10, 30, 15),
																child: Row(
																	children: <Widget>[
																		Container(
																			width:hmSetWidth(100),
																			child: Text('挂账人', style: TextStyle(fontSize: 18)),
																		),
																		Container(
																			width: hmSetWidth(300),
																			height: hmSetHeight(40),
																			padding: hmSetEdgeInsetsLTRB(15, 0, 0, 0),
																			decoration: BoxDecoration(
																					borderRadius: BorderRadius.circular(6.0),
																					border: Border.all(color: Color(0xffD8DDE3),width: 1)
																			),
																			child: Row(
																				children: <Widget>[
																					Container(
																						width: hmSetWidth(230),
																						child: Text(creditName),
																					),
																					SearchBarDemo(onHandle:searchHandle,searchData:creditData),
																				],
																			),
																		)
																	],
																)
														) : Text(''),
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
															if (creditId != '') {
																Navigator.of(context).pop(true)
															} else{
															 hmShowTosta('请选择挂账主体！')
															}
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

// 结账右侧列表 - end -

//数字按钮
class NumBut extends StatelessWidget{
	NumBut({Key key, this.num = '0', this.onHandle}) : super(key: key);

	final num;
	final Function onHandle;

  @override
  Widget build(BuildContext context) {
    return Listener(
			child: Container(
				alignment: Alignment.center,
				decoration: BoxDecoration(
					color: Color(0xffF3F3F3),
					borderRadius: BorderRadius.circular(10),
				),
				child: Text('$num', style: TextStyle(
					color: Color(0xff818693),
					fontSize: 24
				)),
			),
			onPointerDown: (event) => {
				onHandle(num)
			},
		);
  }
}


// 支付方式单选

class RadioBox extends StatelessWidget{
	RadioBox({Key key, this.action, this.title, this.IconUrl, this.onHandle}) : super(key: key);

	final action;
	final title;
	final IconUrl;
	final Function onHandle;

	@override
  Widget build(BuildContext context) {
    return Listener(
			child: Container(
				width: hmSetWidth(190),
				height: hmSetHeight(60),
				padding: EdgeInsets.only(left: 15),
				decoration: BoxDecoration(
					color: action == this.title ? Colors.white : Color(0xffF3F4F7),
					borderRadius: BorderRadius.all( Radius.circular(6.0)),
					border: Border.all(
						width: 1,
						color: action == this.title ? Color(0xff419EFF) : Color(0xffD8DDE3),
					)
				),
				child: Row(
					children: <Widget>[
						Container(
							margin: EdgeInsets.only(right: 5),
							padding: EdgeInsets.only(top: 3),
							child: Image.asset(IconUrl, width: 30,),
						),
						Text(title , style: TextStyle(
							color: Color(0xff20232A),
							fontSize: 16
						)),
						Container(
							margin: EdgeInsets.only(left: 15),
							child: action == this.title ? Image.asset('assets/images/icon/icon_xuanzhong@2x.png', width: 24) : Text('')
						),
					],
				),
			),
			onPointerDown: (event){
				onHandle(title);
			},
		);
  }
}
