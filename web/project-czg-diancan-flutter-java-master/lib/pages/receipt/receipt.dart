import 'package:chanzhanggui_syd/pages/guqing/guqing.dart';
import 'package:chanzhanggui_syd/utils/function.dart';
import 'package:flutter/material.dart';
import 'package:chanzhanggui_syd/widgets/border.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:chanzhanggui_syd/common/api/api.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:intl/intl.dart';

import 'package:chanzhanggui_syd/widgets/DateRangePicker/picker_fla_datetime.dart';
import 'package:chanzhanggui_syd/widgets/DateRangePicker/pick_callback.dart';

class Receipt extends StatefulWidget{
	Receipt({Key key}) : super(key: key);

	_Receipt createState() => new _Receipt();
}

class _Receipt extends State<Receipt> {

	static String page = '0';
	static String pageSize = '10';
	static String startDate;
	static String endDate;
	static String payType; //付款类型
	static String operatorName; //操作人
	static String orderNumber; // 流水号
	static String counts ='0'; // 总条数
	static String receivablesTotal = '0'; // 应收合计
	static String payTotal = '0'; // 实收合计
	static int activeTime = 0;
	static List reasonsList = [];  // 获取原因列表
	static List reasons = [];  // 反结账原因
  static List ListDataes = [];
  static List memberList = [];
	ScrollController _scrollController = ScrollController();

	@override
	void initState() {
		super.initState();
		// 初始化时间
		timeChange(0);
		setState(() {
			operatorName = null;
			orderNumber = null;
			payType = null;
		});
		// 加载公告列表
		loadListData();
		// 获取备注列表
		getRemarkList();
		// 获取人员列表
		getMemberList();
		_scrollController.addListener(() {
			if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
				int pag = int.parse(page);
				pag++;
				setState(() {
				  page = pag.toString();
				});
				getMore();
			}
		});
	}

	// 时间处理  几天前
	timeChange(int num){
		DateTime time = DateTime.now();
		var dat = time.microsecondsSinceEpoch - 86400000000*num;
		var start = new DateTime.fromMicrosecondsSinceEpoch(dat);

		setState(() {
			activeTime = num;
			String stateMonthData = start.month <= 9 ? '0${start.month}' : start.month.toString();
			String endMonthData = time.month <= 9 ? '0${time.month}' : time.month.toString();
			String stateDayData = start.day <= 9 ? '0${start.day}' : start.day.toString();
			String endDayData = time.day <= 9 ? '0${time.day}' : time.day.toString();
			startDate = start.year.toString() + '-' + stateMonthData + '-' +  stateDayData;
			endDate = time.year.toString() + '-' + endMonthData + '-' +  endDayData;
		});
	}

 // 下拉获取更多数据
	getMore() async{
		Map<String, String> params= {'page': page, 'pageSize': pageSize, 'start': startDate, 'end': endDate,'operatorName':operatorName, 'orderNumber': orderNumber, 'payType':payType};
		final dishListData = await ApiService.receiptList(Map<String, String>.from(params));
		final data = dishListData['data'];
		setState(() {
			ListDataes.addAll(data['items']);
		});
	}

  // 初始化获取列表数据
	loadListData() async{
		Map<String, String> params= {'page': page, 'pageSize': pageSize, 'startDate': startDate, 'endDate': endDate,'operatorName':operatorName, 'orderNumber': orderNumber, 'payType':payType};
		final dishListData = await ApiService.receiptList(Map<String, String>.from(params));
		final data = dishListData['data'];
		print(dishListData);
    setState(() {
			ListDataes = data['items'];
			counts = data['counts'].toString();
			receivablesTotal = data['alltotalAmount'].toString();
			payTotal = data['allPayAmount'].toString();
    });
	}

//	时间处理 - start -
	void _flaDatePickDateRangeCallback(DateTime startDt, DateTime endDt,DatePickType dateType){
		String stateMonthData = startDt.month <= 9 ? '0${startDt.month}' : startDt.month.toString();
		String endMonthData = endDt.month <= 9 ? '0${endDt.month}' : endDt.month.toString();
		String stateDayData = startDt.day <= 9 ? '0${startDt.day}' : startDt.day.toString();
		String endDayData = endDt.day <= 9 ? '0${endDt.day}' : endDt.day.toString();
		setState(() {
			activeTime = 1;
			startDate = startDt.year.toString() + '-' + stateMonthData + '-' + stateDayData;
			endDate = endDt.year.toString() + '-' + endMonthData + '-' + endDayData;
		});
	}
	FlaDatePickerController controller;
//	时间处理 - end -

// 获取备注列表
  getRemarkList() async{
		final data = await ApiService.remark('4');
		print( data['data']);
		setState(() {
			reasonsList = data['data'];
		});
	}
 // 获取收银员列表
	getMemberList() async{
  	final memberListdata = await ApiService.getMemberList();
  	if (memberListdata['code'] == 200 ){
			setState(() {
				memberList = memberListdata['data'];
			});
		}
	}


//	查询
	searchHandle(){
		setState(() {
		  page ='1';
		});
		loadListData();
	}
  // 下拉加载
	scrollHandle(){
		print('下一页了');
	}
	// 重新结账
	reAccountsHandle(item, store) async{
  	setState(() {
			reasons = [];
  	});
		bool delete = await SetNumber();
		if (delete == null) {
			print("取消");
		} else {
			Map<String, dynamic> params = {'orderId': item['orderId']};
			params['remarks'] = reasons;
			final data = await ApiService.reReceipt(Map<String, dynamic>.from(params));
			print(data);
			if (data['code'] == '200'){
				store.dispatch('ind');
				print('添加成功');
			} else {
				print('添加失败');
			}
		}
//		print(item);
	}
	// 补打订单
	reOrderHandle(item){
//		print(item);
	}
	// 补打发票
	reInvoiceHandle(item){
//		print(item);
	}
	@override
	Widget build(BuildContext context) {
		controller = new FlaDatePickerController(
			dateRangeCallback: _flaDatePickDateRangeCallback
		);
		return Container(
			margin: hmSetEdgeInsetsAll(30.0),
			decoration: BoxDecoration(
				color: Colors.white,
				borderRadius: BorderRadius.all(Radius.elliptical(6,6)),
			),
			child: Flex(
				direction: Axis.vertical,
				children: <Widget>[
					Container( // 顶部检索条件
						padding: hmSetEdgeInsetsAll(20.0),
						child: Column(
							children: <Widget>[
								Row(
									children: <Widget>[
										Container(
											width: hmSetWidth(100),
											child: Text('时间',textAlign: TextAlign.right,style: TextStyle(color: Color(0xff20232A), fontSize: 16),),
										),
										MaterialButton(
											child: Container(
												width: hmSetWidth(200),
												height: hmSetHeight(50),
												margin: hmSetEdgeInsetsLTRB(10, 0, 0, 0),
												alignment: Alignment.center,
												decoration: BoxDecoration(
													border: Border.all(width: 1,color: Color(0xffD8DDE3)),
													borderRadius: BorderRadius.all(Radius.circular(6)),
												),
												child: Text( '$startDate 至 $endDate' ),
											),
											onPressed: () {
												showFlaDatePicker(context: context, controller: controller);
											},
										),
										GestureDetector(
											child: Container(
												width: hmSetWidth(80),
												height: hmSetHeight(50),
												margin: hmSetEdgeInsetsLTRB(10, 0, 10, 0),
												padding: hmSetEdgeInsetsLTRB(0, 5, 0, 0),
												decoration: BoxDecoration(
													color:activeTime == 0 ? Color(0xffFFDEDA) : Colors.white,
													border: Border.all(
														width: 1,
														color:activeTime == 0 ? Color(0xffE94E3C) : Color(0xffD5D7DF),
													),
													borderRadius: BorderRadius.all(Radius.elliptical(4,4)),
												),
												child: Text('今天',textAlign: TextAlign.center,style: TextStyle(
													color: activeTime == 0 ? Color(0xffE9503E) : Color(0xff20232A),
													fontSize: 16),
												),
											),
											onTap: () => timeChange(0),
										),
										GestureDetector(
											child: Container(
												width: hmSetWidth(80),
												height: hmSetHeight(50),
												margin: hmSetEdgeInsetsLTRB(10, 0, 10, 0),
												padding: hmSetEdgeInsetsLTRB(0, 5, 0, 0),
												decoration: BoxDecoration(
													color:activeTime == 6 ? Color(0xffFFDEDA) : Colors.white,
													border: Border.all(
														width: 1,
														color:activeTime == 6 ? Color(0xffE94E3C) : Color(0xffD5D7DF),
													),
													borderRadius: BorderRadius.all(Radius.elliptical(4,4)),
												),
												child: Text('7天',textAlign: TextAlign.center,style: TextStyle(
													color: activeTime == 6 ? Color(0xffE9503E) : Color(0xff20232A),
													fontSize: 16),),
											),
											onTap: () => timeChange(6),
										),
										GestureDetector(
											child: Container(
												width: hmSetWidth(80),
												height: hmSetHeight(50),
												margin: hmSetEdgeInsetsLTRB(10, 0, 10, 0),
												padding: hmSetEdgeInsetsLTRB(0, 5, 0, 0),
												decoration: BoxDecoration(
													color:activeTime == 14 ? Color(0xffFFDEDA) : Colors.white,
													border: Border.all(
														width: 1,
														color:activeTime == 14 ? Color(0xffE94E3C) : Color(0xffD5D7DF),
													),
													borderRadius: BorderRadius.all(Radius.elliptical(4,4)),
												),
												child: Text('15天',textAlign: TextAlign.center,style: TextStyle(
													color: activeTime == 14 ? Color(0xffE94E3C) : Color(0xff20232A),
													fontSize: 16),),
											),
											onTap: () => timeChange(14),
										),
										GestureDetector(
											child: Container(
												width: hmSetWidth(80),
												height: hmSetHeight(50),
												margin: hmSetEdgeInsetsLTRB(10, 0, 10, 0),
												padding: hmSetEdgeInsetsLTRB(0, 5, 0, 0),
												decoration: BoxDecoration(
													color:activeTime == 29 ? Color(0xffFFDEDA) : Colors.white,
													border: Border.all(
														width: 1,
														color:activeTime == 29 ? Color(0xffE94E3C) : Color(0xffD5D7DF),
													),
													borderRadius: BorderRadius.all(Radius.elliptical(4,4)),
												),
												child: Text('30天',textAlign: TextAlign.center,style: TextStyle(
													color: activeTime == 29 ? Color(0xffE94E3C) : Color(0xff20232A)
													, fontSize: 16),),
											),
											onTap: () => timeChange(29),
										),
									],
								),
								Padding(
									padding: hmSetEdgeInsetsLTRB(0, 20, 0, 10),
									child: Row(
										children: <Widget>[
											Container(
												width: hmSetWidth(100),
												child: Text('流水号',textAlign: TextAlign.right,style: TextStyle(color: Color(0xff20232A), fontSize: 16),),
											),
											Container(
												width: hmSetWidth(200),
												height: hmSetHeight(50),
												margin: hmSetEdgeInsetsLTRB(28, 0, 0, 0),
												alignment: Alignment.centerLeft,
												decoration: BoxDecoration(
													border: Border.all(width: 1,color: Color(0xffD8DDE3)),
													borderRadius: BorderRadius.all(Radius.circular(6)),
												),
												child: TextField(
													decoration: InputDecoration(
														hintText: "请输入流水号",
														contentPadding: hmSetEdgeInsetsLTRB(10, 0, 10, 10),
														border: InputBorder.none,
													),
													onSubmitted:(val){
														setState(() {
															orderNumber = val;
														});
													},
												),
											),
											Container(
												width: hmSetWidth(100),
												child: Text('收银员',textAlign: TextAlign.right,style: TextStyle(color: Color(0xff20232A), fontSize: 16),),
											),
											Container(
												width: hmSetWidth(155),
												height: hmSetHeight(50),
												margin: hmSetEdgeInsetsLTRB(10, 0, 0, 0),
												padding: hmSetEdgeInsetsLTRB(10, 0, 0, 0),
												decoration: BoxDecoration(
													border: Border.all(width: 1,color: Color(0xffD8DDE3)),
													borderRadius: BorderRadius.all(Radius.circular(6)),
												),
												child: new DropdownButton(
													items: dropdownItems(),
													hint:new Text("请选择收银员 "),// 当没有初始值时显示
													onChanged: (selectValue){//选中后的回调
														setState(() {
															operatorName = selectValue;
														});
													},
													value: operatorName,// 设置初始值，要与列表中的value是相同的
													icon: Icon(
														Icons.expand_more,
														color: Colors.grey,
														size: 22,
													),
													underline: Container(height: 1,color: Colors.white,),// 下划线
												),
												),
											Container(
												width: hmSetWidth(100),
												child: Text('付款方式',textAlign: TextAlign.right,style: TextStyle(color: Color(0xff20232A), fontSize: 16),),
											),
											Container(
												width: hmSetWidth(165),
												height: hmSetHeight(50),
												margin: hmSetEdgeInsetsLTRB(10, 0, 0, 0),
												padding: hmSetEdgeInsetsLTRB(10, 0, 0, 0),
												decoration: BoxDecoration(
													border: Border.all(width: 1,color: Color(0xffD8DDE3)),
													borderRadius: BorderRadius.all(Radius.circular(6)),
												),
												child: new DropdownButton(
													items: <DropdownMenuItem<String>>[
														DropdownMenuItem(child: Text("免单",style: TextStyle(color: payType=="0"? Colors.black:Colors.grey),),value: "0",),
														DropdownMenuItem(child: Text("现金",style: TextStyle(color: payType=="1"? Colors.black:Colors.grey),),value: "1",),
														DropdownMenuItem(child: Text("微信",style: TextStyle(color: payType=="2"? Colors.black:Colors.grey),),value: "2",),
														DropdownMenuItem(child: Text("支付宝",style: TextStyle(color: payType=="3"? Colors.black:Colors.grey),),value: "3",),
														DropdownMenuItem(child: Text("银行卡",style: TextStyle(color: payType=="4"? Colors.black:Colors.grey),),value: "4",),
														DropdownMenuItem(child: Text("挂账",style: TextStyle(color: payType=="5"? Colors.black:Colors.grey),),value: "5",),
													],
													hint:new Text("请选择付款方式 "),// 当没有初始值时显示
													onChanged: (selectValue){//选中后的回调
														setState(() {
															payType = selectValue;
														});
													},
													value: payType,// 设置初始值，要与列表中的value是相同的
													icon: Icon(
														Icons.expand_more,
														color: Colors.grey,
														size: 22,
													),
													underline: Container(height: 1,color: Colors.white,),// 下划线
												),
											),
											Container(
												child: Container(
													width: hmSetWidth(100),
													height: hmSetHeight(50),
													margin: EdgeInsets.only(left: 20),
													decoration: BoxDecoration(
														gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
														borderRadius: BorderRadius.circular(4)
													),
													child: OutlineButton(
														color: Colors.transparent,
														shape: RoundedRectangleBorder(
															borderRadius: BorderRadius.circular(5.0)),
														child: Text('查询',
															style: TextStyle(
																fontSize: 16,
																color: Colors.white
															),
														),
														onPressed: (){
															searchHandle();
														},
													),
												),
											)
										],
									),
								)
							],
						),
					),
					Expanded( //列表
						flex: 1,
						child: Container(
							padding: hmSetEdgeInsetsLTRB(20, 0, 20, 0),
							child: Flex(
								direction: Axis.vertical,
								children: <Widget>[
									Container(
										padding: hmSetEdgeInsetsLTRB(10, 10, 0, 10),
										decoration: BoxDecoration(
											border: Border(
												top: BorderSide(
													color: Color(0xffEBEEF5),
													width: 1.0,
												),
												bottom: BorderSide(
													color: Color(0xffEBEEF5),
													width: 1.0,
												),
											),
										),
										child: Flex(
											direction: Axis.horizontal,
											children: <Widget>[
												new TitleWidget(flex: 1, title: '流水号', fontColor: Color(0xff818693)),
												new TitleWidget(flex: 2, title: '订单号',fontColor: Color(0xff818693)),
												new TitleWidget(flex: 1, title: '应收金额',fontColor: Color(0xff818693)),
												new TitleWidget(flex: 1, title: '实收金额',fontColor: Color(0xff818693)),
												new TitleWidget(flex: 1, title: '收银员',fontColor: Color(0xff818693)),
												new TitleWidget(flex: 1, title: '收银时间',fontColor: Color(0xff818693)),
												new TitleWidget(flex: 1, title: '付款方式',fontColor: Color(0xff818693)),
												new TitleWidget(flex: 0, title: '操作',fontColor: Color(0xff818693), width:300.0),
											],
										),
									),
									Expanded(
										flex: 1,
										child: RefreshIndicator(
											onRefresh: (){
												print("滚动到边界");
											},
											child: ListView.builder(
												itemCount: ListDataes.length,
												itemBuilder: (context, index) {
													final data = ListDataes[index];
													final dataTime = DateTime.parse(data['lastUpdateTime']);
													String tiemTitle = dataTime.year.toString() + '-'+ dataTime.month.toString()+ '-'+ dataTime.day.toString();
													String type = '无';
													switch(data['payType'].toString()){
														case '0' : type = '免单'; break;
														case '1' : type = '现金'; break;
														case '2' : type = '微信'; break;
														case '3' : type = '支付宝'; break;
														case '4' : type = '银行卡'; break;
														case '5' : type = '挂账'; break;
													}
													return ListDataes.length > 0 ? Flex(
														direction: Axis.vertical,
														children: <Widget>[
															Container(
																padding: hmSetEdgeInsetsLTRB(10, 10, 0, 10),
																child: Flex(
																	direction: Axis.horizontal,
																	children: <Widget>[
																		new TitleWidget(flex: 1, title: data['orderNumber'], fontColor: Color(0xff20232A)),
																		new TitleWidget(flex: 2, title: data['orderId'], fontColor: Color(0xff20232A)),
																		new TitleWidget(flex: 1, title: '￥'+ (data['totalAmount']/100).toString(), fontColor: Color(0xff20232A)),
																		new TitleWidget(flex: 1, title: '￥'+ (data['payAmount']/100).toString(), fontColor: Color(0xff20232A)),
																		new TitleWidget(flex: 1, title: data['operatorName'], fontColor: Color(0xff20232A)),
																		new TitleWidget(flex: 1, title: tiemTitle, fontColor: Color(0xff20232A)),
																		new TitleWidget(flex: 1, title: type, fontColor: Color(0xff20232A)),
																		Expanded(
																			flex: 0,
																			child: Row(
																				children: <Widget>[
																					StoreConnector(
																						converter: (store) {
																							return  ()=>{
																								reAccountsHandle(data, store)
																							};
																						},
																						builder: (context, callback) {
																							return Container(
																								width: hmSetWidth(90),
																								height: hmSetHeight(36),
																								margin: EdgeInsets.only(right: 10),
																								decoration: BoxDecoration(
																									gradient: LinearGradient(colors: [Color(0xFF4FBFFF), Color(0xFF208DFF)],begin:FractionalOffset(1, 0)),// 渐变色
																									borderRadius: BorderRadius.circular(4)
																								),
																								child: OutlineButton(
																									color: Colors.transparent,
																									shape: RoundedRectangleBorder(
																										borderRadius: BorderRadius.circular(5.0)),
																									child: Text('重新结账',
																										style: TextStyle(
																											fontSize: 12,
																											color: Colors.white
																										),
																									),
																									onPressed: callback
																								),
																							);
																						}
																					),
//																					new ActionBut(title: '重新结账',item: data, onHandle: reAccountsHandle),
																					new ActionBut(title: '补打账单',item: data, onHandle: reOrderHandle),
																					new ActionBut(title: '补打发票',item: data, onHandle: reInvoiceHandle),
																				],
																			)
																		),
																	],
																),
															),
															BorderDotted(color: Color(0xffD1D5E1)),
														],
													): Text('无数据！');
												},
												controller:_scrollController,
											),
										),
									),
								],
							)
						)
					),
					Container(  //底部信息
						padding: hmSetEdgeInsetsLTRB(20, 15, 20, 15),
						decoration: BoxDecoration(
							color: Colors.white,
							boxShadow: [
								BoxShadow(
									offset: Offset(0, 2),
									color: Color.fromRGBO(24, 35, 65, 0.1),
									blurRadius: 4, // 模糊
									spreadRadius: 4,  //阴影的半经
								)
							]
						),
						child: Flex(
							direction: Axis.horizontal,
							children: <Widget>[
								Expanded(
									flex: 1,
									child: Text('共$counts单',style: TextStyle(color: Color(0xff20232A),fontSize: 16)),
								),
								Container(
									child: Column(
										children: <Widget>[
											Row(
												children: <Widget>[
													Text('应收合计：',style: TextStyle(color: Color(0xff818693)),),
													Text('￥${int.parse(receivablesTotal)/100}',style: TextStyle(color: Color(0xff20232A),fontSize: 20)),
												],
											),
											Row(
												children: <Widget>[
													Text('实收合计：',style: TextStyle(color: Color(0xff818693))),
													Text('￥${int.parse(payTotal)/100}',style: TextStyle(color: Color(0xff20232A),fontSize: 20)),
												],
											)
										],
									),
								)
							],
						),
					)
				],
			),
		);
	}

	dropdownItems() {
		List<DropdownMenuItem<String>> list = new List();
		memberList.forEach((key) {
			list.add(
				new DropdownMenuItem(
					child: Text(key,
						style: TextStyle(
								color: operatorName==key
										? Colors.black
										:Colors.grey)
					),
					value: key,),
			);
		});
		return list;
	}

	// 反结账弹窗
	Future<bool> SetNumber() {
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
															child:  Text('反结账原因', style: TextStyle(
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

}

// 标题
class TitleWidget extends StatelessWidget{

	const TitleWidget({Key key, this.flex = 1, this.title = '标题', this.fontColor = Colors.black, this.width = null}) : super(key: key);

	final int flex;
	final dynamic title;
	final Color fontColor;
	final double width;

  @override
  Widget build(BuildContext context) {

    return Expanded(
			flex: flex,
			child: width != null ?  Container(
				width: hmSetWidth(width),
				child: Text(title.toString(),textAlign: TextAlign.center, style: TextStyle(color: fontColor)),
			) : Text(title.toString(), style: TextStyle(color: fontColor))
		);
  }
}

// 按钮

class ActionBut extends StatelessWidget{
	ActionBut({Key key, this.title = '按钮', this.onHandle, this.item }) : super(key: key);

	final item;
	final onHandle;
	final String title;

	@override
	Widget build(BuildContext context) {
    return Container(
			width: hmSetWidth(90),
			height: hmSetHeight(36),
			margin: EdgeInsets.only(right: 10),
			decoration: BoxDecoration(
				gradient: LinearGradient(colors: [Color(0xFF4FBFFF), Color(0xFF208DFF)],begin:FractionalOffset(1, 0)),// 渐变色
				borderRadius: BorderRadius.circular(4)
			),
			child: OutlineButton(
				color: Colors.transparent,
				shape: RoundedRectangleBorder(
					borderRadius: BorderRadius.circular(5.0)),
				child: Text(title,
					style: TextStyle(
						fontSize: 12,
						color: Colors.white
					),
				),
				onPressed: (){
					onHandle();
				},
			),
		);
  }
}
