import 'dart:io';
import 'dart:async';

import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart'

hide Options; // 过滤掉 Options 与 dio 冲突
import 'package:fluttertoast/fluttertoast.dart';
import 'package:chanzhanggui_syd/utils/authentication.dart';

//import '../config/config.dart';
 import 'package:chanzhanggui_syd/widgets/loading_dialog.dart' show Loading;

//'https://mock.boxuegu.com/mock/875';
//'http://canzg-wsl.itheima.net:8082';

const String SERVICE_API_BASEURL = 'http://canzg-wsl.itheima.net:8082';

/// storage api 地址
const String STORAGE_KEY_APIURL = 'ApiUrl';

/// storage token 地址
const String STORAGE_KEY_USER_TOKEN = 'UserToken';

/// 用户账号
const String KEY_LOGIN_ACCOUNT = 'key_login_account';

class HttpUtil {
	static dynamic ctx;
	final storage = new FlutterSecureStorage();
	static HttpUtil instance;
	Dio dio;
	BaseOptions options;

	CancelToken cancelToken = new CancelToken();

	static HttpUtil getInstance() {
		if (null == instance) instance = new HttpUtil();
		return instance;
	}

	HttpUtil() {
		//BaseOptions、Options、RequestOptions 都可以配置参数，优先级别依次递增，且可以根据优先级别覆盖参数
		options = new BaseOptions(
			//请求基地址,可以包含子路径
			baseUrl: '',
			// baseUrl: storage.read(key: STORAGE_KEY_APIURL) ?? SERVICE_API_BASEURL,
			//连接服务器超时时间，单位是毫秒.
			connectTimeout: 10000,
			//响应流上前后两次接受到数据的间隔，单位为毫秒。
			receiveTimeout: 5000,
			//Http请求头.
			headers: {
				"version": "1.0.0",
				'accept-language': 'zh-cn',
				// 'content-type': 'application/json'
			},
			//请求的Content-Type，默认值是[ContentType.json]. 也可以用ContentType.parse("application/x-www-form-urlencoded")
			contentType: ContentType.json,
			//表示期望以那种格式(方式)接受响应数据。接受三种类型 `json`, `stream`, `plain`, `bytes`. 默认值是 `json`,
			responseType: ResponseType.json,
		);

		dio = new Dio(options);

		//Cookie管理
		dio.interceptors.add(CookieManager(CookieJar()));

		//添加拦截器
		dio.interceptors
			.add(InterceptorsWrapper(onRequest: (RequestOptions options) {
//			 print("请求之前");
//			 Loading.before(options.uri, '正在通讯...');
			return options; //continue
		}, onResponse: (Response response) {
//			 print("响应之前");
//			 Loading.complete(response.request.uri);
			return response; // continue
		}, onError: (DioError e) {
			// print("错误之前");
//			 Loading.complete(e.request.uri);
			return e; //continue
		}));
	}

	/*
   * error统一处理
   */
	void formatError(DioError e) {
		print(e);
		String errMessage = '';
		if (e.type == DioErrorType.CONNECT_TIMEOUT) {
			// It occurs when url is opened timeout.
			errMessage = '连接超时';
		} else if (e.type == DioErrorType.SEND_TIMEOUT) {
			// It occurs when url is sent timeout.
			errMessage = '请求超时';
		} else if (e.type == DioErrorType.RECEIVE_TIMEOUT) {
			//It occurs when receiving timeout
			errMessage = '响应超时';
		} else if (e.type == DioErrorType.RESPONSE) {
			// When the server response, but with a incorrect status, such as 404, 503...
			// errMessage = e.response.data['errMessage'] ?? '出现异常, 详情请按接口说明自定义错误体！';
			if (e.response.data is String) {
				errMessage =
				e.response.data == '' ? '出现异常, 详情请按接口说明自定义错误体！' : e.response.data;
			} else {
				errMessage = e.response.data['errMessage'];
			}
			if (e.response.statusCode == 401) {
				print(401);
				gotoLogin(ctx);
			}
		} else if (e.type == DioErrorType.CANCEL) {
			// When the request is cancelled, dio will throw a error with this type.
			errMessage = '网络出岔子了，一会再试试吧';
		} else {
			//DEFAULT Default error type, Some other Error. In this case, you can read the DioError.error if it is not null.
			errMessage = '网络出岔子了';
		}
		Fluttertoast.showToast(
			msg: errMessage,
			toastLength: Toast.LENGTH_SHORT,
			gravity: ToastGravity.CENTER,
			timeInSecForIos: 1,
			// backgroundColor: Colors.red,
			// textColor: Colors.white,
			fontSize: 16.0);
		throw e;
	}

	/*
   * 取消请求
   *
   * 同一个cancel token 可以用于多个请求，当一个cancel token取消时，所有使用该cancel token的请求都会被取消。
   * 所以参数可选
   */
	void cancelRequests(CancelToken token) {
		token.cancel("cancelled");
	}

	// 读取本地配置
	Future<Options> getMyOptions() async {
		Options options;
		var token = await storage.read(key: STORAGE_KEY_USER_TOKEN);
		if (token != null) {
			options = Options(headers: {
				"version": "1.0.0",
				'accept-language': 'zh-cn',
				// 'content-type': 'application/json',
				'Authorization': token
				// 'Authorization': 'Bearer $token'
			});
		} else {
		  print('读取Token失败');
			gotoLogin(ctx);
		}

		return options;
	}

	// 读取 baseUrl
	Future<String> getBaseUrl() async {
		var baseUrl = await storage.read(key: STORAGE_KEY_APIURL);
		return baseUrl ?? SERVICE_API_BASEURL;
	}

	/// restful get 操作
	Future get(String url,
		{Map<String, dynamic> params,
			Options options,
			CancelToken cancelToken}) async {
		try {
			var tokenOptions = options ?? await getMyOptions();
			var baseUrl = await getBaseUrl();
			var response = await dio.get(baseUrl + url,
				queryParameters: params,
				options: tokenOptions,
				cancelToken: cancelToken);
			print(baseUrl + url);
			print(params);
			print(response);
			return response.data;
		} on DioError catch (e) {
			formatError(e);
		}
	}

	/// restful post 操作
	Future post(String url,
			{dynamic params,
				Options options,
				CancelToken cancelToken}) async {
		try {
			var tokenOptions;
			if(url != '/login'){
				tokenOptions = options ?? await getMyOptions();
			}
			var baseUrl = await getBaseUrl();
			var response = await dio.post(baseUrl + url,
					data: params, options: tokenOptions, cancelToken: cancelToken);
			print(baseUrl + url);
			print(params);
			print(response);

			return response.data;
		} on DioError catch (e) {
			formatError(e);
		}
	}
//	Future post(String url,
//		{Map<dynamic, dynamic> params,
//			Options options,
//			CancelToken cancelToken}) async {
//		try {
//			var tokenOptions;
//			if(url != '/login'){
//				tokenOptions = options ?? await getMyOptions();
//			}
//			var baseUrl = await getBaseUrl();
//			var response = await dio.post(baseUrl + url,
//				data: params, options: tokenOptions, cancelToken: cancelToken);
//			print(baseUrl + url);
//			print(params);
//			print(response);
//
//			return response.data;
//		} on DioError catch (e) {
//			formatError(e);
//		}
//	}

	/// restful put 操作
	Future put(String url,
		{Map<dynamic, dynamic> params,
			Options options,
			CancelToken cancelToken}) async {
		try {
			print(url);
			print(params);
			var tokenOptions = options ?? await getMyOptions();
			var baseUrl = await getBaseUrl();
			var response = await dio.put(baseUrl + url,
				data: params, options: tokenOptions, cancelToken: cancelToken);
			print(baseUrl + url);
			print(params);
			print(response);
			return response.data;
		} on DioError catch (e) {
			formatError(e);
		}
	}

	/// restful delete 操作
	Future delete(String url,
		{Map<String, dynamic> params,
			Options options,
			CancelToken cancelToken}) async {
		try {
			var tokenOptions = options ?? await getMyOptions();
			var baseUrl = await getBaseUrl();
			var response = await dio.delete(baseUrl + url,
				data: params, options: tokenOptions, cancelToken: cancelToken);
			print(params);
			print(response);
			return response.data;
		} on DioError catch (e) {
			formatError(e);
		}
	}

	/// restful delete 操作
	Future deleteArr(String url,
			{List<String> params,
				Options options,
				CancelToken cancelToken}) async {
		try {
			var tokenOptions = options ?? await getMyOptions();
			var baseUrl = await getBaseUrl();
			var response = await dio.delete(baseUrl + url,
					data: params, options: tokenOptions, cancelToken: cancelToken);
			print(params);
			print(response);
			return response.data;
		} on DioError catch (e) {
			formatError(e);
		}
	}

	/// restful post form 表单提交操作
	Future postForm(String url,
		{Map<String, dynamic> params,
			Options options,
			CancelToken cancelToken}) async {
		try {
			var tokenOptions = options ?? await getMyOptions();
			var baseUrl = await getBaseUrl();
			var response = await dio.post(baseUrl + url,
				data: FormData.from(params),
				options: tokenOptions,
				cancelToken: cancelToken);
			return response.data;
		} on DioError catch (e) {
			formatError(e);
		}
	}
}
