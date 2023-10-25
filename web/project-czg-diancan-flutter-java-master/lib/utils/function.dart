import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:easy_dialog/easy_dialog.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:chanzhanggui_syd/common/pubs/flutter_screenutil/flutter_screenutil.dart';

// ********** 尺寸换算 *************

/// 设置宽度按
double hmSetWidth(double width) {
	return ScreenUtil.getInstance().setWidth(width);
}

/// 设置宽度按
double hmSetHeight(double height) {
	return ScreenUtil.getInstance().setHeight(height);
}

/// 设置 EdgeInsets.fromLTRB
EdgeInsets hmSetEdgeInsetsLTRB(
	double left, double top, double right, double bottom) {
	return EdgeInsets.fromLTRB(
		ScreenUtil.getInstance().setWidth(left),
		ScreenUtil.getInstance().setHeight(top),
		ScreenUtil.getInstance().setWidth(right),
		ScreenUtil.getInstance().setHeight(bottom));
}

/// 设置 EdgeInsets.all
EdgeInsets hmSetEdgeInsetsAll(value) {
	return EdgeInsets.all(ScreenUtil.getInstance().setWidth(value));
}

/// 设置字体尺寸 设计稿比例
double hmSetFontSize(double size) {
	return ScreenUtil.getInstance().setSp(size);
}

/// 设置字体尺寸 设计稿+屏幕 比例
double hmSetFontSizeWithSystem(double size) {
	return ScreenUtil(allowFontScaling: true).setSp(size);
}

/// 屏幕宽度
double hmScreenWidth() {
	return ScreenUtil.screenWidthDp;
}

/// 屏幕高度
double hmScreenHeight() {
	return ScreenUtil.screenHeightDp;
}

/// 底部 bottomBar 高度
double hmBottomBarHeight() {
	return ScreenUtil.bottomBarHeight;
}

/// 顶部 statusBar 高度
double hmStatusBarHeight() {
	return ScreenUtil.statusBarHeight;
}

/// widget宽度
double hmWidgetWidth(BuildContext context) {
	return MediaQuery.of(context).size.width;
}

/// widget高度
double hmWidgetHeight(BuildContext context) {
	return MediaQuery.of(context).size.height;
}

/// 关闭键盘
hmHiddenKeyboard(BuildContext context) {
	FocusScope.of(context).requestFocus(FocusNode());
}

// ********** 设备权限 **************

/// 检查权限
hmCheckPermissions(PermissionGroup permissionType) async {
	PermissionStatus permission =
	await PermissionHandler().checkPermissionStatus(permissionType);
	return permission == PermissionStatus.granted;
}

/// 读取权限
hmGetPermissions(BuildContext context) {
	PermissionHandler().requestPermissions([
		PermissionGroup.storage,
		PermissionGroup.camera,
		PermissionGroup.speech,
		PermissionGroup.location,
	]).then((res) {
		if (res[PermissionGroup.storage] == PermissionStatus.denied ||
			res[PermissionGroup.storage] == PermissionStatus.disabled ||
			res[PermissionGroup.storage] == PermissionStatus.unknown) {
			//用户拒绝，禁用，或者不可用
			print('获取不到权限，APP不能正常使用');
//			hmShowDialog('获取不到权限，APP不能正常使用',
//				icon: Icon(
//					Iconfont.iconGonggao,
//					color: THEME_COLOR_PRIMARY,
//					size: 48,
//				),
//				context: context,
//				buttonText: '去设置', onPressed: () {
//					PermissionHandler().openAppSettings();
//				});
		} else if (res[PermissionGroup.storage] == PermissionStatus.granted) {
		} else if (res[PermissionGroup.storage] == PermissionStatus.restricted) {
			//用户同意IOS的回调
		}
	});
}

// ********** 字符串处理 *************

/// 获取图片路径
String hmGetImagePath(String name, {String format: 'png'}) {
	return 'assets/images/$name.$format';
}

/// 获取图片路径包含子目录
String hmGetImagePathWithDir(String name,
	{String dir: 'default', String format: 'jpg'}) {
	return 'assets/images/$dir/$name.$format';
}

/// 获取文件名
String hmGetFathFileName(String path) {
	var fileName = path.substring(path.lastIndexOf("/") + 1, path.length);
	return fileName;
}

/// 电话号码安全 , 头 3 尾 4
String hmPhoneNumSecure(String phone) {
	if (phone.length <= 7) {
		return phone;
	}
	return '${phone.substring(0, 3)}****${phone.substring(phone.length - 4, phone.length)}';
}

// ********** 两点间距离 *************

const double DEF_PI = 3.14159265359; // PI3.141592653589793
const double DEF_2PI = 6.28318530712; // 2*PI
const double DEF_PI180 = 0.01745329252; // PI/180.0
const double DEF_R = 6370693.5; // 地球半径

/// 根据球面距离计算两点直接的距离
double hmGeoGetLongDistance(
	double lon1, double lat1, double lon2, double lat2) {
	double ew1, ns1, ew2, ns2;
	double distance;
	// 角度转换为弧度
	ew1 = lon1 * DEF_PI180;
	ns1 = lat1 * DEF_PI180;
	ew2 = lon2 * DEF_PI180;
	ns2 = lat2 * DEF_PI180;
	// 求大圆劣弧与球心所夹的角(弧度)
	distance = sin(ns1) * sin(ns2) + cos(ns1) * cos(ns2) * cos(ew1 - ew2);
	// 调整到[-1 1]范围内，避免溢出
	if (distance > 1.0)
		distance = 1.0;
	else if (distance < -1.0) distance = -1.0;
	// 求大圆劣弧长度
	distance = DEF_R * acos(distance);
	return distance;
}

/// 根据勾股定理计算两点之间的距离
double hmGeoGetShortDistance(
	double lon1, double lat1, double lon2, double lat2) {
	double ew1, ns1, ew2, ns2;
	double dx, dy, dew;
	double distance;
	// 角度转换为弧度
	ew1 = lon1 * DEF_PI180;
	ns1 = lat1 * DEF_PI180;
	ew2 = lon2 * DEF_PI180;
	ns2 = lat2 * DEF_PI180;
	// 经度差
	dew = ew1 - ew2;
	// 若跨东经和西经180 度，进行调整
	if (dew > DEF_PI)
		dew = DEF_2PI - dew;
	else if (dew < -DEF_PI) dew = DEF_2PI + dew;
	dx = DEF_R * cos(ns1) * dew; // 东西方向长度(在纬度圈上的投影长度)
	dy = DEF_R * (ns1 - ns2); // 南北方向长度(在经度圈上的投影长度)
	// 勾股定理求斜边长
	distance = sqrt(dx * dx + dy * dy);
	return distance;
}

// ********** 对话框 *************

/// tosta
hmShowTosta(String message) {
	Fluttertoast.showToast(
		msg: message,
		toastLength: Toast.LENGTH_SHORT,
		gravity: ToastGravity.CENTER,
		timeInSecForIos: 1,
		// backgroundColor: Colors.red,
		// textColor: Colors.white,
		fontSize: 16.0);
}

/// 显示对话框
hmShowDialog(String title,
	{@required BuildContext context,
		@required Icon icon,
		bool useCloseButton,
		String buttonText,
		VoidCallback onPressed}) {
	EasyDialog(
		closeButton: useCloseButton ?? false,
		cornerRadius: 10.0,
		fogOpacity: 0.1,
		width: 280,
		height: 220,
		contentPadding: EdgeInsets.all(30),
		contentList: [
			Padding(
				padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
				child: icon,
			),
			Padding(
				padding: EdgeInsets.fromLTRB(0, 5, 0, 15),
				child: Text(
					title,
					style: TextStyle(fontWeight: FontWeight.bold),
					textScaleFactor: 1.3,
				),
			),
//			GradientButton(
//				text: buttonText ?? '确定',
//				onPressed: () => onPressed(),
//			),
		],
	).show(context);
}

// ********** 其它 *************

/// 分割线
Widget hmSplitLine({double height = 1, color = Colors.transparent}) {
	return Container(
		height: height,
		color: color,
	);
}

/// 水平分割线
Widget hmDivider() {
	return Divider(
		height: 1.0,
		indent: 0.0,
		color: Colors.black12,
	);
}
