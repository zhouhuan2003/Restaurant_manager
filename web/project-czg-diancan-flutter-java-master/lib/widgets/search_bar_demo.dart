import 'package:flutter/material.dart';

class SearchBarDemo extends StatefulWidget {
  SearchBarDemo({this.onHandle, this.searchData});
  List searchData = [];
  Function onHandle;
  _SearchBarDemoState createState() => _SearchBarDemoState();
}

class _SearchBarDemoState extends State<SearchBarDemo> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.search),
      onPressed: (){
        // 调用写好的方法
        showSearch(context: context,delegate: SearchBar(onHandle: widget.onHandle,searchData:widget.searchData));
      },
    );
  }
}


class SearchBar extends SearchDelegate<String>{
  SearchBar({this.onHandle, this.searchData});
  List searchData = [];
  Function onHandle;

  // 点击清楚的方法
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        // 点击把文本空的内容清空
        onPressed: (){
          query = "";
        },
      )
    ];
  }

  // 点击箭头返回
  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        // 使用动画效果返回
        icon: AnimatedIcons.menu_arrow,progress: transitionAnimation,
      ),
      // 点击的时候关闭页面（上下文）
      onPressed: (){
        close(context, null);
      },
    );
  }

  // 点击搜索出现结果
  @override
  Widget buildResults(BuildContext context) {
    // 定义变量 并进行判断
    final suggestionList = query.isEmpty ? searchData : searchData.where((input) => input.startsWith(query)).toList();
    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context,index){
          final data = suggestionList[index];
          final name = data['companyName'] != '' ? data['companyName'] : data['userName'];
          return  GestureDetector(
            child: ListTile(
                title: RichText(
                    text: TextSpan(
                      // 获取搜索框内输入的字符串，设置它的颜色并让让加粗
                        text: name.substring(0, query.length),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            //获取剩下的字符串，并让它变成灰色
                              text: name.substring(query.length),
                              style: TextStyle(color: Colors.grey))
                        ]
                    )
                )
            ),
            onTap: (){
              onHandle(suggestionList[index]);
              close(context, null);
            },
          );


        }
    );

  }

  // 搜索下拉框提示的方法
  @override
  Widget buildSuggestions(BuildContext context) {
    // 定义变量 并进行判断
    final suggestionList = query.isEmpty ? searchData : searchData.where((input) => input.startsWith(query)).toList();
    return ListView.builder(
        itemCount: suggestionList.length,
        itemBuilder: (context,index){
          final data = suggestionList[index];
          final name = data['companyName'] != '' ? data['companyName'] : data['userName'];
          return  GestureDetector(
            child: ListTile(
                title: RichText(
                    text: TextSpan(
                      // 获取搜索框内输入的字符串，设置它的颜色并让让加粗
                        text: name.substring(0, query.length),
                        style: TextStyle(
                            color: Colors.black, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            //获取剩下的字符串，并让它变成灰色
                              text: name.substring(query.length),
                              style: TextStyle(color: Colors.grey))
                        ]
                    )
                )
            ),
            onTap: (){
              onHandle(suggestionList[index]);
              close(context, null);
            },
          );


        }
    );
  }
}