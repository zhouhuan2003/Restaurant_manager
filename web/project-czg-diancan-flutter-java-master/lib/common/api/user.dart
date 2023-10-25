import 'dart:async' show Future;

import 'package:chanzhanggui_syd/utils/http.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserService {
	// 用户登录
	static Future userLogin(Map<String, String> params) async {
		final data = await HttpUtil.getInstance().post('/login', params: params);
		await FlutterSecureStorage().write(key: 'UserToken', value: data['authorization']);
		return data;
	}
}
