import 'package:chanzhanggui_syd/utils/function.dart';
import 'package:flutter/material.dart';
import 'package:chanzhanggui_syd/widgets/Menulist.dart';
import 'package:chanzhanggui_syd/common/api/api.dart';
import 'package:flutter_redux/flutter_redux.dart';

class Guqing extends StatefulWidget {
	Guqing({Key key}) : super(key: key);

	@override
	_Guqing createState() => new _Guqing();
}

class _Guqing extends State<Guqing> {

	static String page = '0';
	static String pageSize = '10';
	static String counts = '';
	static int guqingNumber = 0;
	List guqingList = [];
	List checkList = [];

	@override
	void initState() {
		super.initState();
		// 加载动态列表
		loadGuqingList();
	}

	loadGuqingList() async{
		Map<String, String> params= {'page': page, 'pageSize': pageSize};
		final dishListData = await ApiService.sellcalculation(Map<String, String>.from(params));
		final data = dishListData['data'];
    final List checkListData = [];
		data['items'].forEach((n){
			checkListData.add(n['dishId']);
		});
		setState(() {
		  guqingList = data['items'];
			checkList = checkListData;
		  counts = data['counts'].toString();
		});
	}

	// 上一页 下一页
	pageHandle(String st){
		int pag = int.parse(page);
		int pagAll = int.parse(pageSize);
		int cont = int.parse(counts);
		if(st == 'add' && pag < cont/pagAll){
			pag++;
		} else {
			hmShowTosta('已经是第一页了');
			return false;
		}

		if (st == 'reduce' && pag > 0){
			pag--;
		} else {
			hmShowTosta('已经是最后一页了');
			return false;
		}
		setState(() {
		  page = pag.toString();
		});

		loadGuqingList();
	}

	// 删除
	delHandle(id) async{
		List<String> params= [id];
		final data = await ApiService.delGuqing(params);
		if (data['code'] == 200){
			print('删除成功');
			loadGuqingList();
		} else {
			print('删除失败');
		}
	}

  // 添加沽清
	addHandle(item) async{
    setState(() {
			guqingNumber = 0;
    });
		bool delete = await SetNumber(title: item['dishName']);
		if (delete == null) {
			print("取消");
		} else {
			Map<String, dynamic> params= item;
			params['numbers'] = guqingNumber.toString();
			params['dishType'] = item['type'];
			params['active'] = true;
			final data = await ApiService.addGuqing(Map<String, dynamic>.from(params));
			print(data);
			if (data['code'] == 200){
				print('添加成功');
				loadGuqingList();
			} else {
				print('添加失败');
			}
		}
	}

	@override
	Widget build(BuildContext context) {
		return Padding(
			padding: hmSetEdgeInsetsAll(30.0),// EdgeInsets.all(30),
			child: Flex(
				direction: Axis.horizontal,
				children: <Widget>[
					Container(
						width: hmSetWidth(423),
						height: hmSetHeight(1000),
						decoration: BoxDecoration(
							color: Colors.white,
							borderRadius: BorderRadius.all(Radius.elliptical(6,6)),
						),
						child: Flex(
							direction: Axis.vertical,
							children: <Widget>[
								Padding(
									padding: hmSetEdgeInsetsLTRB(20, 23, 20, 23),
									child: Row(
										children: <Widget>[
											Text('已沽清种类 ',style: TextStyle(
												fontSize: 18,
												color: Color(0xff818693)
											),),
											Text(counts,style: TextStyle(
												fontSize: 28,
												color: Color(0xffE9503E)
											),)
										],
									),
								),
								Expanded(
									flex: 1,
									child: GuqingList(listData: guqingList, delHandle: delHandle,),
								),
								Container(
									height: hmSetHeight(100),
									decoration: BoxDecoration(
										color: Colors.white,
										boxShadow: [
											BoxShadow(
												offset: Offset(0,4),
												color: Color.fromRGBO(24, 35, 65, 0.1),
												blurRadius: 4, // 模糊
												spreadRadius: 4,  //阴影的半经
											)
										]
									),
									child: Row(
										  mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>[
												Container(
													padding: hmSetEdgeInsetsLTRB(20, 0, 20, 0),
													child: OutlineButton(
														padding: hmSetEdgeInsetsLTRB(20, 10, 20, 10),
														highlightedBorderColor: Color(0xffFFDEDA),
														child: Row(
															children: <Widget>[
																Image.asset('assets/images/icon/icon_shangyiye.png', width: 24,),

																Text(' 上一页',
																	style: TextStyle(
																		fontSize: 18,
																		color: Color(0xff818693)
																	),)
															],
														),
														onPressed: () {
															pageHandle('reduce');
														},
													),
												),
												Container(
													padding: hmSetEdgeInsetsLTRB(20, 0, 20, 0),
													child: OutlineButton(
														padding: hmSetEdgeInsetsLTRB(20, 10, 20, 10),
														highlightedBorderColor: Color(0xffFFDEDA),
														child: Row(
															children: <Widget>[
																Image.asset('assets/images/icon/icon_xiayiye.png', width: 24,),
																Text(' 下一页',
																	style: TextStyle(
																		fontSize: 18,
																		color: Color(0xff818693)
																	),)
															],
														),
														onPressed: () {
															pageHandle('add');
														},
													),
												)
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
		);
	}


	Future<bool> SetNumber({title}) {
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
								height: hmSetHeight(417),
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
																child:  Text('沽清', style: TextStyle(
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
										Container(
											height: hmSetHeight(56),
											padding: hmSetEdgeInsetsLTRB(20, 20, 0, 0),
											alignment: Alignment.centerLeft,
											child: Text(title,style: TextStyle(
												fontSize: 18,
											),),
										),
									  Expanded(
											flex: 1,
											child: 	Row(
												mainAxisSize:MainAxisSize.max,
												mainAxisAlignment:MainAxisAlignment.center,
												children: <Widget>[
													Listener(
														child: Image.asset('assets/images/icon/btn_renshu_-@2x.png',width: hmSetWidth(72)),
														onPointerDown: (event){
															mSetState(() {
																guqingNumber > 0 ?	guqingNumber-- : '';
															});
														},
													),
													Container(
														margin: hmSetEdgeInsetsLTRB(10, 0, 10, 0),
														child: Text(guqingNumber.toString(), style: TextStyle(
															color: Color(0xff818693),
															fontSize: 24
														),)
													),
													Listener(
														child: Image.asset('assets/images/icon/btn_caishuliang_+_nor@2x.png',width: hmSetWidth(72)),
														onPointerDown: (event){
															mSetState(() {
																guqingNumber++;
															});
														},
													),
												],
											),
										),
										Container(
											height: hmSetHeight(136),
											decoration: BoxDecoration(
												border: Border(
													top: BorderSide(
														width: 1,
														color: Color(0xffD8DDE3),
													)
												),
											),
											child: Row(
												mainAxisSize:MainAxisSize.max,
												mainAxisAlignment:MainAxisAlignment.center,
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
															margin: hmSetEdgeInsetsLTRB(43, 0, 0, 0),
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

// 沽清列表
class GuqingList extends StatelessWidget {
	GuqingList({Key key, this.listData, this.delHandle}) : super(key: key);

  final List listData;
  final delHandle;

	@override
	Widget build(BuildContext context) {
		print(8888);
		print(listData);
		return Container(
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
								Expanded(
									flex: 2,
									child: Text('菜名',style: TextStyle(
										color: Color(0xff818693)
									)),
								),
								Expanded(
									flex: 1,
									child: Text('剩余',textAlign: TextAlign.center, style: TextStyle(
										color: Color(0xff818693),
									)),
								),
								Expanded(
									flex: 1,
									child: Text('沽清',textAlign: TextAlign.center, style: TextStyle(
										color: Color(0xff818693),
									)),
								),
								Expanded(
									flex: 1,
									child: Text('操作',textAlign: TextAlign.center, style: TextStyle(
										color: Color(0xff818693),
									)),
								),
							],
						),
					),
					Expanded(
						flex: 1,
						child: ListView(
							shrinkWrap: true,
							padding: hmSetEdgeInsetsAll(1.0),
							children: listData.map((item) => Container(
								height: hmSetHeight(65),
								padding: hmSetEdgeInsetsLTRB(10, 10, 0, 10),
								decoration: BoxDecoration(
									border: Border(
										bottom: BorderSide(
											color: Color(0xffEBEEF5),
											width: 1.0,
											style: BorderStyle.solid,
										),
									),

								),
								child: Flex(
									direction: Axis.horizontal,
									children: <Widget>[
										Expanded(
											flex: 2,
											child: Text(item['dishName'], style: TextStyle(
												color: Color(0xff818693)
											)),
										),
										Expanded(
											flex: 1,
											child: Text(item['remainder'].toString(),textAlign: TextAlign.center, style: TextStyle(
												color: Color(0xff818693),
											)),
										),
										Expanded(
											flex: 1,
											child: Text(item['sellLimitTotal'].toString(),textAlign: TextAlign.center, style: TextStyle(
												color: Color(0xff818693),
											)),
										),
										Expanded(
											flex: 1,
											child: Container(
												width: hmSetWidth(60),
												height: hmSetHeight(36),
//												margin: EdgeInsets.only(right: 20),
												decoration: BoxDecoration(
													gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
													borderRadius: BorderRadius.circular(4)
												),
												child: OutlineButton(
//													padding: EdgeInsets.only(left: 30,top: 20, bottom: 20, right: 30),
													color: Colors.transparent,
													shape:RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0)),
													child: Text('删除',
														style: TextStyle(
															fontSize: 14,
															color: Colors.white
														),
													),
													onPressed: () {
														delHandle(item['id']);
													},
												),
											),
										),
									],
								),
							)
							).toList()
						),
					)
				],
			)
		);
	}
}
