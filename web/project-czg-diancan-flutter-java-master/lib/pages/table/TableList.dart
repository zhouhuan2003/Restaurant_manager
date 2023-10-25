import 'package:chanzhanggui_syd/utils/function.dart';
import 'package:flutter/material.dart';
import 'package:flutter_redux/flutter_redux.dart';
import 'package:chanzhanggui_syd/common/api/api.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert' as convert;
import 'package:chanzhanggui_syd/widgets/IndexTopButList.dart';
import 'package:flutter_swiper/flutter_swiper.dart';

class TableList extends StatefulWidget {
	TableList({Key key}) : super(key: key);

	@override
	_TableList createState() => new _TableList();
}

class _TableList extends State<TableList> {

	String topActState = '全部';
	String butActState = '';
	String areaId = 'all';
  String activeTableId = '';  // 餐桌ID
	String activeTableNum = '';  // 餐桌号
	String activeMember = ''; // 就餐人数
	String page = '1';
	String pageSize = '100';

	List TableList = [];
	List AreaList = [];
	Map checkData; // 选中的餐桌信息
	List pageList;

	String freeNumbers = '0';  // 空闲统计
	String lockedNumbers = '0'; // 锁定状态统计
	String openedNumbers = '0'; // 已开台 就餐人数

	@override
	void initState() {
		super.initState();
		// 加载公告列表
		loadAreaList();
		loadListData();
	}

	// 获取餐桌列表
	loadListData() async{
		final TableListData = await ApiService.openTablePanel({'areaId':areaId,'page': page, 'pageSize': pageSize });
		List dataes = convert.jsonDecode(convert.jsonEncode(TableListData['data']['tablePage']['items']));
		List tablePageList = [];
		if (dataes.length <= 20) {
			tablePageList = [dataes];
		} else {
			for(var i = 0; i < (dataes.length/20).ceil(); i++){
				 final num = 20*(i+1) > dataes.length ? dataes.length : 20*(i+1);
				 tablePageList.add(dataes.getRange(20*(i),num).toList());
			};
		}
		print((TableListData['data']['tablePage']['items']).length);
		setState(() {
			pageList = tablePageList;
			TableList = TableListData['data']['tablePage']['items'];
			freeNumbers = TableListData['data']['freeNumbers'].toString();
			lockedNumbers = TableListData['data']['lockedNumbers'].toString();
			openedNumbers	= TableListData['data']['openedNumbers'].toString();
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

	// 点击餐桌
	activeTableHandle(item){
		setState(() {
			activeTableId = item['tableId'];
			activeTableNum = item['tableName'];
			checkData = item;
		});
	}

	// 预定/释放 - 清台
	lockAndOpen() async{
		if(checkData != null){
			String errMessage = '';
			Map params = {'tableId':checkData['tableId']};
			if(checkData['status'] == 0){ // 空闲中 锁桌
				params['status'] = '2';
				errMessage = '${checkData['tableName']} 桌已锁定！';
			} else if(checkData['status'] == 2){ // 锁定中 释放
				params['status'] = '0';
				errMessage = '${checkData['tableName']} 桌已释放！';
			} else if(checkData['status'] == 1){ // 用餐中  清台
				params['status'] = '0';
				errMessage = '${checkData['tableName']} 桌已清台！';
			}

			final data = await ApiService.reserveAndrelease(params);
			if (data['code'] == 200){
				hmShowTosta(errMessage);
				loadListData();
			}else{
				hmShowTosta('请求出错了');
			}
		}
	}

	// 顶部点击事件
	topActHandle(String st, String id){
		setState((){
			topActState = st;
			areaId = id;
		});
		loadListData();
	}

	// 底部点击事件
	botActHandle(String st){
		print('bot:' + st);
	}

	@override
	Widget build(BuildContext context) {
		return Flex(
			direction: Axis.vertical,
			children: <Widget>[
				Expanded(
					flex: 0,
					child: Container(
							width: hmSetWidth(1224),
							height: hmSetHeight(80),
							decoration: BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.only(topLeft: Radius.elliptical(10,10)),
							),
							child: new TopButList(active: topActState, areaList: AreaList, onHandle:topActHandle)
					),
				),
				Expanded(
					flex: 1,
					child: Container(
						padding: EdgeInsets.only(left: 20),
						decoration: BoxDecoration(
							color: Colors.transparent,
						),
						child:

//						GridView.builder(
//								padding: hmSetEdgeInsetsAll(0.0),
//								shrinkWrap: true,
//								gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//										crossAxisCount: 5, //每行三列
//										mainAxisSpacing: 10, //主轴距离10
//										crossAxisSpacing: 7, // 交叉轴距离7
//										childAspectRatio: 1.5 //显示区域宽高相等
//								),
//								itemCount:TableList.length <=20 ? TableList.length : 20,
//								itemBuilder:(BuildContext context, int index) {
//									return ContList(item:TableList[index], activeId:activeTableId, onHandle: activeTableHandle);
//								}
//						)

						new Swiper(
								itemBuilder: (BuildContext context,int index){
									return ListPage(index);
								},
								itemCount: (TableList.length/20).ceil(),
								pagination: new SwiperPagination(
									builder: DotSwiperPaginationBuilder(
									color: Color.fromRGBO(189,165,149,1),
									activeColor: Color(0xffE94E3C),
									)
								),
								autoplay:false,
								loop:false
								)
					),
				),
				Expanded(
					flex: 0,
					child: Container(
						height: hmSetHeight(104),
						width: hmSetWidth(1224),
						decoration: BoxDecoration(
							color: Colors.white,
						),
						child: BotButList(item: checkData, freeNumbers: freeNumbers , lockedNumbers: lockedNumbers, openedNumbers: openedNumbers,lockAndOpen:lockAndOpen, loadListData:loadListData),
					),
				),
			],
		);
	}


	Widget ListPage(ind) => GridView.builder(
			padding: hmSetEdgeInsetsAll(0.0),
			shrinkWrap: true,
			gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
					crossAxisCount: 5, //每行三列
					mainAxisSpacing: 10, //主轴距离10
					crossAxisSpacing: 7, // 交叉轴距离7
					childAspectRatio: 1.5 //显示区域宽高相等
			),
			itemCount:pageList[ind].length, // <=20 ? TableList.length : 19,
			itemBuilder:(BuildContext context, int index) {
				final data = pageList[ind];
				print(pageList[ind].length);
				return ContList(item:data[index], activeId:activeTableId, onHandle: activeTableHandle);
			}
	);
}



class pageCont extends StatelessWidget{
	pageCont({this.index});

	final index;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Text(index.toString());
  }


}



// 中间列表

class ContList extends StatefulWidget {
	ContList({Key key, this.item, this.activeId, this.onHandle}) : super(key: key);

	final item;
	final activeId;
	final onHandle;

  @override
	_ContList createState() => new _ContList();
}

class _ContList extends State<ContList> {
	@override
	Widget build(BuildContext context) {
		DateTime TimeDate;
		String time;
		final status = widget.item['status'];
		String iconUrl = '';
		String iconUrlAc = '';
		String title = '';
		switch(status){
			case 0 :
				title = '空闲中';
				iconUrl = 'assets/images/icon/icon_card_free_nor@2x.png';
				iconUrlAc = 'assets/images/icon/icon_card_free_sel@2x.png';
				break;
			case 1 :
				title = '用餐中';
				iconUrl = 'assets/images/icon/icon_card_eating_nor@2x.png';
				iconUrlAc = 'assets/images/icon/icon_card_eating_sel@2x.png';
				break;
			case 2:
				title = '锁定';
				iconUrl = 'assets/images/icon/icon_card_lock_nor@2x.png';
				iconUrlAc = 'assets/images/icon/icon_card_lock_sel@2x.png';
				break;
		}
    if(status == 1){
			TimeDate = DateTime.parse(widget.item['createTime'] != null ? widget.item['createTime'] : (new DateTime.now()).toIso8601String());
			time = TimeDate.hour.toString() + ':'+ TimeDate.minute.toString()+ ':'+ TimeDate.second.toString();
		}
		return GestureDetector(
			child: Container(
				width: hmSetWidth(216),
				height: hmSetHeight(156),
				padding: EdgeInsets.only(left: 15, right: 15,top: 10,bottom: 10),
				margin: EdgeInsets.all(10),
				decoration: BoxDecoration(
					color: widget.activeId == widget.item['tableId'] ? Color(0xff556388) : Colors.white,
					borderRadius: BorderRadius.circular(6.0),
					boxShadow: [
						BoxShadow(
							offset: Offset(0,2),
							color: Color.fromRGBO(0, 0, 0, 0.03),
							blurRadius: 4, // 模糊
							spreadRadius: 2,  //阴影的半经
						)
					]
				),
				child: Flex(
					direction: Axis.vertical,
					children: <Widget>[
						Row(
							children: <Widget>[
								Text(widget.item['tableName'], style: TextStyle(
									fontSize: 18,
									color: Color(0xffBAC0CD)
								),)
							],
						),
						Expanded(
							flex: 1,
							child: Column(
								children: <Widget>[
									Center(
										child: Image.asset(widget.activeId == widget.item['tableId'] ? iconUrlAc : iconUrl,
												width: 32),
									),
									Center(
										child: Text(title, style:TextStyle(
											fontSize: 18,
											color: widget.activeId == widget.item['tableId'] ? Color
												(0xffFFEFD9) : Color(0xff818693)
										)),
									),
								],
							),
						),
						status == 1 ? Flex(
							direction: Axis.horizontal,
							children: <Widget>[
								Expanded(
									flex: 1,
									child: Row(
										children: <Widget>[
											Image.asset('assets/images/icon/icon_renshu.png',width: 15,),
											Text(widget.item['userNumbers'].toString(),style: TextStyle(
												fontSize: 14,
												color: Color(0xffBAC0CD)
											)),
										],
									)
								),
								Expanded(
									flex: 1,
									child: Row(
										textDirection: TextDirection.rtl,
										children: <Widget>[
											Text(time,style: TextStyle(
												fontSize: 14,
												color: Color(0xffBAC0CD)
											)),
											Image.asset('assets/images/icon/icon_time.png',width: 15,),
										],
									),
								)
							],
						):Text(''),
					],
				),
			),
			onTap: (){
				widget.onHandle(widget.item);
			},
		);
	}
}

// 底部按钮列表
class BotButList extends StatefulWidget{
	BotButList({Key key,this.item,this.freeNumbers,this.lockedNumbers, this.openedNumbers,this.lockAndOpen, this.loadListData}) : super(key: key);

  final item;
	final freeNumbers;
	final lockedNumbers;
  final openedNumbers;
  final Function lockAndOpen;
  final loadListData;

	@override
	_BotButList createState() => new _BotButList();
}

class _BotButList extends State<BotButList> {

	static int activeMember = 0;
	String errMessage = '';

	@override
	Widget build(BuildContext context) {
		final ButStatus  = widget.item != null && widget.item['status'] == 1 ? true : false;
		final openLock =  widget.item != null && widget.item['status'] == 2 ? true : false;
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
									shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
									child: Text('空闲中(' + widget.freeNumbers + ')'),
									onPressed: () {},
								),
							),
							Padding(
								padding: EdgeInsets.only(left: 30),
								child: OutlineButton(
									padding: EdgeInsets.only(left: 30,top: 15, bottom: 15, right: 30),
									color: Colors.white,
									shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
									child: Text('用餐中(' + widget.openedNumbers + ')'),
									onPressed: () {},
								),
							),
							Padding(
								padding: EdgeInsets.only(left: 30),
								child: OutlineButton(
									padding: EdgeInsets.only(left: 30,top: 15, bottom: 15, right: 30),
									color: Colors.white,
									shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
									child: Text('已锁定(' + widget.lockedNumbers + ')'),
									onPressed: () {},
								),
							),
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
								gradient: LinearGradient(colors: [Color(0xFF4FBFFF), Color(0xFF208DFF)],begin:FractionalOffset(1, 0)),// 渐变色
								borderRadius: BorderRadius.circular(4)
							),
							child: OutlineButton(
								padding: EdgeInsets.only(left: 30,top: 20, bottom: 20, right: 30),
								color: Colors.transparent,
								shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
								child: Text(openLock ? '释放' : '预定',
									style: TextStyle(
										color: Colors.white
									),
								),
								onPressed: () async {
									if(widget.item != null && widget.item['status'] == 0){
										bool delete = await SetMumber();
										if (delete == null) {
											print("取消");
										} else {
											Map params = {'tableId':widget.item['tableId'], 'status': '2', 'numbers': activeMember};
											final data = await ApiService.reserveAndrelease(params);
											if (data['code'] == 200){
												hmShowTosta('${widget.item['tableName']} 桌已锁定！');
												widget.loadListData();
											}else{
												hmShowTosta('请求出错了');
											}
										}
									} else if (widget.item != null && widget.item['status'] == 2){
										widget.lockAndOpen();
									}
								},
							),
						),
						Container(
						  width: hmSetWidth(136),
							margin: EdgeInsets.only(right: 20),
							decoration: BoxDecoration(
								gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
								borderRadius: BorderRadius.circular(4)
							),
							child: StoreConnector(
								converter: (store) {
									return () => store.dispatch('meal');
								},
								builder: (context, callback) {
									return OutlineButton(
										padding: EdgeInsets.only(left: 30,top: 20, bottom: 20, right: 30),
										color: Colors.transparent,
										shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
										child: Text(ButStatus ? '清台' : '开桌',
											style: TextStyle(
												color: Colors.white
											),
										),
										onPressed: () async{
                      final data = widget.item;
                      if (data['status'].toString() == '0') { // 空闲
												setState(() {activeMember = 0;});
												// 弹出对话框并等待其关闭
												bool delete = await SetMumber();
												if (delete == null) {
													print("取消");
												} else {
													Map params = widget.item;
													params['activeMember'] = activeMember;
													await FlutterSecureStorage().write(key: 'checkTableData', value:	convert.jsonEncode(params));
													Map openParams = {'tableId': params['tableId'], 'numbers': activeMember};
													Map data = await ApiService.openTable(openParams);
													if (data['code'].toString() == '200'){
														callback();
													} else {
														hmShowTosta(data['message']);
													}
												}
											} else if(data['status'].toString() == '1'){ // 用餐中
												Map data = await ApiService.getOrderDetile(widget.item['tableId']);
												if(data['code'] == 200){
													print(data);
													print(data['data']['orderId']);
													if(data['data']['orderId'] != null){
														hmShowTosta('${widget.item['tableName']} 桌台已下单,请先去结账!');
													} else {
														widget.lockAndOpen();
													}
												}else{
													hmShowTosta('请求出错了!');
												}
											}
										}
									);
								}
							),
						),
						ButStatus ? Container(
							width: hmSetWidth(136),
							margin: EdgeInsets.only(right: 20),
							decoration: BoxDecoration(
									gradient: LinearGradient(colors: [Color(0xFF4FBFFF), Color(0xFF208DFF)],begin:FractionalOffset(1, 0)),// 渐变色
									borderRadius: BorderRadius.circular(4)
							),
							child: StoreConnector(
									converter: (store) {
										return () => store.dispatch('meal');
									},
									builder: (context, callback) {
										return OutlineButton(
												padding: EdgeInsets.only(left: 30,top: 20, bottom: 20, right: 30),
												color: Colors.transparent,
												shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
												child: Text('点餐',
													style: TextStyle(
															color: Colors.white
													),
												),
												onPressed: () async{
													await FlutterSecureStorage().write(key: 'checkTableData', value:	convert.jsonEncode(widget.item));
													callback();
												}
										);
									}
							),
						) : Text('')
					],
				)
			],
		);
	}

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
															print(widget.item),
															if(activeMember > widget.item['seatNumber']){
																mSetState((){
																	activeMember = 0;
																}),
																hmShowTosta('开桌人事不能大于桌台座位数')
															} else {
																Navigator.of(context).pop(true)
															}
														}else{
															hmShowTosta('开桌人事不能为零')
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
}
