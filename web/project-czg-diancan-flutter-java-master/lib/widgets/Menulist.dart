import 'package:chanzhanggui_syd/utils/function.dart';
import 'package:flutter/material.dart';
import 'package:chanzhanggui_syd/widgets/Menulist.dart';
import 'package:chanzhanggui_syd/common/api/api.dart';

class Menulist extends StatefulWidget {
	Menulist({Key key, this.checkList, this.checkHandle}) : super(key: key);

	final List checkList;
	final Function checkHandle;

	@override
	_Menulist createState() => new _Menulist();
}

class _Menulist extends State<Menulist> {

	static String activeId = 'all';
	static String categoryId = '';
	static int type = 1;
	static String page = '1';
	static String pageSize = '100';
  static List listData = [];
	static List dishListData = [];

	@override
	void initState() {
		super.initState();
		// 获取菜单信息
		loadgDishCategory();
		loadListes();
	}

	// 获取菜品分类列表
	loadgDishCategory() async{
		final getListData = await ApiService.getDishCategory();
		final data = getListData['data'].insert(0, {'categoryId': 'all', 'name': '全部'});
		setState(() {
			listData = getListData['data'];
//			activeId = getListData['data'][0]['categoryId'];
		});
	}

	// 获取菜品列表
	loadListes() async{
		Map<dynamic, dynamic> params= {'categoryId': activeId,'page': page, 'pageSize': pageSize, 'type': type.toString() };
		final getDishListData = await ApiService.getDishList(Map<String, dynamic>.from(params));

		//现在状态处理
		getDishListData['data']['items'].forEach((item){
			  item['active'] = false;
			for(int i=0; i<widget.checkList.length; i++) {
				if(widget.checkList[i] == item['dishId']){
					item['active'] = true;
				}
			}
		});

		setState(() {
			dishListData = getDishListData['data']['items'];
		});
	}

	// 搜索
	searchDish(val) async{
		if (val) {
			Map<String, dynamic> params= {'code': val,'page': page, 'pageSize': pageSize, 'type': type };
			final getDishListData = await ApiService.searchDish(Map<String, dynamic>.from(params));

			//现在状态处理
			getDishListData['data']['items'].forEach((item){
				item['active'] = false;
				for(int i=0; i<widget.checkList.length; i++) {
					if(widget.checkList[i] == item['dishId']){
						item['active'] = true;
					}
				}
			});

			setState(() {
				dishListData = getDishListData['data']['items'];
			});
		}
	}

	@override
	Widget build(BuildContext context) {
		return Flex(
			direction: Axis.horizontal,
			children: <Widget>[
				Container(
					width: hmSetWidth(140),
					height: hmSetHeight(1000),
					padding: hmSetEdgeInsetsLTRB(0, 20, 0, 0),
					decoration: BoxDecoration(
						color: Color(0xff818693),
						borderRadius:BorderRadius.only(topLeft: Radius.elliptical(6,6),bottomLeft: Radius.elliptical(6,6)),
					),
					child: ListView.builder(
						shrinkWrap: true,
						scrollDirection:Axis.vertical,
						itemCount: listData.length,
						itemExtent: 80,
						itemBuilder: (BuildContext context, int index) {
							final data = listData[index];
							return data['categoryId'] == activeId ? Container(
								decoration: BoxDecoration(
									color: Colors.white,
								),
								child: Flex(
									direction: Axis.horizontal,
									children: <Widget>[
										Container(
											width: hmSetWidth(6),
											height: hmSetHeight(30),
											color: Colors.blue,
										),
										Expanded(
											flex: 1,
											child: Container(
												padding:hmSetEdgeInsetsLTRB(0, 0, 10, 0),
												child: Center(
													child: Text(data['name'],textAlign: TextAlign.center,style: TextStyle(
														color: Colors.black,
													),
													),
												),
											)
										)
									],
								)
							) : GestureDetector(
								child: Container(
									decoration: BoxDecoration(
										border: index == 0 ? Border(
											top: BorderSide(
												color: Color(0xFFA6ACBA),
												width: 1.0,
											),
											bottom: BorderSide(
												color: Color(0xFFA6ACBA),
												width: 1.0,
											),
										):
										Border(
											bottom: BorderSide(
												color: Color(0xFFA6ACBA),
												width: 1.0,
											),
										)
									),
									child: Center(
										child: Text(data['name'],textAlign: TextAlign.center,style: TextStyle(
											color: Colors.white,
										),
										),
									)
								),
								onTap: () => {
								  loadListes(),
								  print(data),
									setState(()=> {
										activeId = data['categoryId'],
										type = data['type']
										}
								  )
								},
							);
						}
					),
				),
				Expanded(
					flex: 1,
					child: Flex(
						direction: Axis.vertical,
						children: <Widget>[
							Container(
								margin: hmSetEdgeInsetsLTRB(20, 20, 20, 10),
								decoration: BoxDecoration(
									borderRadius: BorderRadius.all(Radius.circular(50)),
									border: Border.all(width: 1,color: Color(0xffD8DDE3))
								),
								child: TextField(
									decoration: InputDecoration(
										border:InputBorder.none,
										contentPadding: hmSetEdgeInsetsLTRB(10, 0, 10, 0),
										labelText: "请输入商品码快速搜索",
										labelStyle: TextStyle(
											color: Color(0xffBAC0CD),
											fontSize: 18,
										),
										prefixIcon: Icon(Icons.search,color: Color(0xffD8DDE3),)
									),
									onSubmitted:(value){
										searchDish(value);
									}
								),
							),
							Expanded(
								flex: 1,
								child: Padding(
									padding: hmSetEdgeInsetsLTRB(0, 0, 10, 0),
									child: Scrollbar(
										child: Container(
											padding: hmSetEdgeInsetsLTRB(20, 0, 10, 10),
											child: GridView.builder(
												padding: hmSetEdgeInsetsLTRB(0, 10, 0, 0),
												shrinkWrap: true,
												gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
													crossAxisCount: 3, //每行三列
													mainAxisSpacing: 10, //主轴距离10
													crossAxisSpacing: 7, // 交叉轴距离7
													childAspectRatio: 2.0 //显示区域宽高相等
												),
												itemCount: dishListData.length,
												itemBuilder: (context, index) {
													final data = dishListData[index];
													return GestureDetector(
														child: Container(
															padding: hmSetEdgeInsetsLTRB(10.0, 12.0, 10.0, 0.0),
															decoration: BoxDecoration(
																color: data['active'] ? Color(0xff556388) :Colors.white,
																border: Border.all(color: Color(0xffD8DDE3)),
																borderRadius: BorderRadius.all(Radius.circular(6)),
															),
															child: Flex(
																direction: Axis.vertical,
																children: <Widget>[
																	Expanded(
																		flex: 1,
																		child: FractionallySizedBox(
																			widthFactor: 1,
																			child: Text(data['dishName'],textAlign: TextAlign.left,style: TextStyle(
																				color: data['active'] ? Color(0xffFBEBD7) : Color(0xff818693)
																			),),
																		)
																	),
																	Container(
																		height: hmSetHeight(40),
																		child: Flex(
																			direction: Axis.horizontal,
																			children: <Widget>[
																				Expanded(
																					flex: 1,
																					child: Text('￥'+ (data['price']/100).toString(),style: TextStyle(
																						color: data['active'] ? Color(0xffFBEBD7) : Color(0xff818693),
																						fontSize: 16
																					)),
																				),
																				Container(
																					child:data['count'] != null ? Text('剩余 '+ data['count'].toString(),style: TextStyle(
																						color: Color(0xffE9503E),
																						fontSize: 14
																					)) : Text('')
																				)
																			],
																		),
																	)
																],
															),
														),
														onTap: () => widget.checkHandle(data),
													);
												}
											),
										)
									),
								),
							)
						],
					),
				),
			],
		);
	}
}

