import 'package:flutter/material.dart';
import 'package:chanzhanggui_syd/utils/function.dart';

Set dict = Set();
bool loadingStatus = false;

class Loading {
  static dynamic ctx;

  static void before(uri, text) {
    dict.add(uri); // 放入set变量中
    // 已有弹窗，则不再显示弹窗, dict.length >= 2 保证了有一个执行弹窗即可，
    if (loadingStatus == true || dict.length >= 2) {
      return;
    }
    loadingStatus = true; // 修改状态
    // 请求前显示弹窗
    showDialog(
      context: ctx,
      builder: (context) {
        return Index(text: text);
      },
    );
  }

  static void complete(uri) {
    dict.remove(uri);
    // 所有接口接口返回并有弹窗
    if (dict.length == 0 && loadingStatus == true) {
      loadingStatus = false; // 修改状态
      // 完成后关闭loading窗口
      Navigator.of(ctx, rootNavigator: true).pop();
    }
  }
}

// 弹窗内容
class Index extends StatelessWidget {
  final String text;

  Index({Key key, @required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Image.asset(
          'assets/images/loading.gif',
          width: hmSetWidth(227.0),
          height: hmSetWidth(227.0),
        ),
      ),
    );
  }
}
