import 'package:flutter/material.dart';
import 'package:chanzhanggui_syd/common/api/user.dart';
import 'package:chanzhanggui_syd/common/pubs/flutter_screenutil/flutter_screenutil.dart';
import 'package:chanzhanggui_syd/utils/function.dart';

class Login extends StatefulWidget {

	@override
	LoginState createState() => LoginState();
}

class LoginState extends State {

	String shopId = 'f3deb';
	String loginName = 'zhangsan';
	String loginPass = '123456';
	String errMessage = '';

	// 输入商铺id
	onChangedShopId(id) {
		setState(() {
			errMessage = '';
		});
		shopId = id;
	}

	// 输入用户名
	onChangedLoginName(id) {
		setState(() {
			errMessage = '';
		});
		loginName = id;
	}

	// 输入密码
	onChangedLoginPass(id) {
		setState(() {
			errMessage = '';
		});
		loginPass = id;
	}

	@override
	Widget build(BuildContext context) {
		ScreenUtil.instance = ScreenUtil(width: 1366, height: 1024)..init(context);
		return Scaffold(
			backgroundColor: Colors.transparent,
			body: ConstrainedBox(
				constraints: BoxConstraints.expand(),
				child: Stack(
					alignment:Alignment.center , //指定未定位或部分定位widget的对齐方式
					children: <Widget>[
						Container(
							width: hmScreenWidth(),
							height: hmScreenHeight(),
							child: Image.asset(
								'assets/images/logBg.jpg',
								fit: BoxFit.fill,
							)
						),
						Container(
							width: hmSetWidth(450),
							height: hmSetHeight(540),
							padding: EdgeInsets.fromLTRB(30, 30, 30, 30),
							decoration:BoxDecoration(
								color: Colors.white,
								borderRadius: BorderRadius.circular(13.0),
							),
							child: Column(
								children: <Widget>[
									Flex(
										direction: Axis.horizontal,
										children: <Widget>[
											Expanded(
												flex: 1,
												child: Image.asset("assets/images/icon/icon_logo@2x.png",
													height: 50,
												),
											),
											Container(
												width: 1,
												height: 50,
												// margin: hmSetEdgeInsetsLTRB(0, top, right, bottom),
												decoration:BoxDecoration(
													border: Border(
														left: BorderSide(
															width: 2,
															color: Color(0xffC0C2C9)
														)
													)
												),
											),
											Expanded(
												flex: 1,
												child: Text("收银系统",
														textAlign: TextAlign.center,
														style: TextStyle(
															color: Colors.black,
															fontSize: 28.0,
															decoration:TextDecoration.none,
														)
												),
											),
										],
									),
									Container(
										margin: hmSetEdgeInsetsLTRB(0, 30, 0, 10),
										padding: hmSetEdgeInsetsLTRB(10, 0, 10, 0),
										decoration: BoxDecoration(
											borderRadius: BorderRadius.circular(4.0),
											border: Border.all(
												color: Color(0xffDCDFE6)
											)
										),
										child:TextField(
											autofocus: false,
											decoration: InputDecoration(
												hintText: "请输入商户号",
												border: InputBorder.none,
											),
										onChanged: (v){
											onChangedShopId(v);
										},
//											controller: TextEditingController.fromValue(TextEditingValue(
//												text: '${this.shopId == null ? "请输入商户号" : this.shopId}',)
//											)
										),
									),
									Container(
										margin: hmSetEdgeInsetsLTRB(0, 10, 0, 10),
										padding: hmSetEdgeInsetsLTRB(10, 0, 10, 0),
										decoration: BoxDecoration(
											borderRadius: BorderRadius.circular(4.0),
											border: Border.all(
												color: Color(0xffDCDFE6)
											)
										),
										child:TextField(
											autofocus: false,
											decoration: InputDecoration(
												hintText: "用户名或邮箱",
												border: InputBorder.none,
											),
										onChanged: (v){
											onChangedLoginName(v);
										},
//											controller: TextEditingController.fromValue(TextEditingValue(
//												text: '${this.loginName == null ? "" : this.loginName}',)
//											)
										),
									),
									Container(
										margin: hmSetEdgeInsetsLTRB(0, 10, 0, 10),
										padding: hmSetEdgeInsetsLTRB(10, 0, 10, 0),
										decoration: BoxDecoration(
											borderRadius: BorderRadius.circular(4.0),
											border: Border.all(
												color: Color(0xffDCDFE6)
											)
										),
										child:TextField(
											autofocus: false,
											decoration: InputDecoration(
												hintText: "您的登录密码",
												border: InputBorder.none,
											),
											onChanged: (v){
												onChangedLoginPass(v);
											},
//											controller: TextEditingController.fromValue(TextEditingValue(
//												text: '${this.loginPass == null ? "" : this
//													.loginPass}',)
//											)
										),
									),
									Padding(
										padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
										child: Container(
											alignment:Alignment.center,
											margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
											decoration: BoxDecoration(
												gradient: LinearGradient(colors: [Color(0xFFF6866F), Color(0xFFE94E3C)],begin:FractionalOffset(1, 0)),// 渐变色
												borderRadius: BorderRadius.circular(4)
											),
											child: RaisedButton(
												color: Colors.transparent,
												elevation: 0, // 正常时阴影隐藏
												highlightElevation: 0, // 点击时阴影隐藏
												colorBrightness: Brightness.dark,
												child: Text("登 陆"),
												onPressed: () async{
													if (shopId == '') {
														hmShowTosta('商铺ID不能为空');
													}else if (loginName == ''){
														hmShowTosta('用户名不能为空');
													}else if (loginPass == ''){
														hmShowTosta('密码不能为空');
													}else {
														final params = {'shopId': shopId,'loginName':loginName,'loginPass':loginPass};
														final data = await UserService.userLogin(params);
														if(data['status'].toString() == '200'){
															Navigator.pushNamed(context, "/index");
														}else{
															hmShowTosta(data['desc']);
														}
													}
												},
											),
										),
									),
									Text('忘记密码？请联系店长进行密码重置')
								],
							),
//							child: LoginIndexPage(),
//							width: 450,
//							height: 507,
						),
						Container(
							padding: EdgeInsets.only(top: 550.0),
							child: Text("Copyright @ 2019 传智播客教育集团 京ICP备08015045 All Rights Reserved",
								style: TextStyle(
									color: Colors.white,
									fontSize: 14.0,
									decoration:TextDecoration.none,
								)
							),
						)
					],
				),
			)
		);
	}
}
