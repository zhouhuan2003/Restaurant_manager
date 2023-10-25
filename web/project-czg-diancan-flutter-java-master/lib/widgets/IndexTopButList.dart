import 'package:chanzhanggui_syd/utils/function.dart';
import 'package:flutter/material.dart';

// 顶部导航
class TopButList extends StatefulWidget{
	TopButList({Key key, this.active, this.onHandle,this.areaList, this.openedNumbers}) : super(key: key);
	final active;
	final areaList;
	final onHandle;
	final openedNumbers;

	@override
	_TopButList createState() => new _TopButList();
}

class _TopButList extends State<TopButList>{

	@override
	Widget build(BuildContext context) {
		List areaListData = widget.areaList;
		return  Row(
			textDirection:TextDirection.ltr,
			children: areaListData.map((n) => Container(
				padding: EdgeInsets.only(top: 5, left: 30, right: 30,bottom: 0),
				child: Listener(
					child: widget.active == n['area_name'] ?
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
					onPointerDown: (event) => widget.onHandle(n['area_name'],n['area_id']),
				)
			)).toList()
		);
	}

}
