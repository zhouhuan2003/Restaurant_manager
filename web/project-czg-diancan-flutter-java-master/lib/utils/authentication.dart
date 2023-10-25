import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// storage token 地址
const String STORAGE_KEY_USER_TOKEN = 'UserToken';

/// 是否授权登录
/// 检查是否有 token
Future<bool> isAuthenticated() async {
	var token = await FlutterSecureStorage().read(key: STORAGE_KEY_USER_TOKEN);
	return token != null ? true : false;
}

/// 清空授权登录
/// 删除缓存 token
deleteAuthentication() async {
	await FlutterSecureStorage().delete(key: STORAGE_KEY_USER_TOKEN);
}

/// 重新登录
gotoLogin(BuildContext context) async {
	await FlutterSecureStorage().delete(key: STORAGE_KEY_USER_TOKEN);
//	Navigator.pushNamed(context, "/login");
	Navigator.pushNamedAndRemoveUntil(
		context, "/login", (Route<dynamic> route) => false);
}
