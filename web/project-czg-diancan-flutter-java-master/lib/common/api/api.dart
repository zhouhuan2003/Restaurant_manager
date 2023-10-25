import 'dart:async' show Future;

import 'package:chanzhanggui_syd/utils/http.dart';

class ApiService {
	// 下单接口
	static Future cashOrder(Map<dynamic, dynamic> params) async {
		return await HttpUtil.getInstance().post('/order/add', params: params);
	}
	// 删除沽清
	static Future delGuqing(List<String> params) async {
		return await HttpUtil.getInstance().deleteArr('/sellcalculation/delete', params: params);
	}
	// 加菜接口
	static Future addCash(Map<dynamic, dynamic> params) async {
		return await HttpUtil.getInstance().post('/order/plusDish/orderId/${params['orderId']}', params: params['dishs']);
	}
	//预定/释放
	static Future reserveAndrelease(Map<dynamic, dynamic> params) async {
		return await HttpUtil.getInstance().put('/table/'+params['tableId']+'/'+ params['status'], params: params);
	}
	// 开桌
	static Future openTable(Map<dynamic, dynamic> params) async {
		return await HttpUtil.getInstance().put('/table/openTable/${params['tableId']}/numbers/${params['numbers']}', params: params);
	}
	// 区域列表
	static Future areaList() async {
		return await HttpUtil.getInstance().get('/table/listTableArea');
	}
	// 开桌面板
	static Future openTablePanel(Map<String, dynamic> params) async {
		return await HttpUtil.getInstance().get('/table/search/'+params['areaId']+'/'+ params['page']+'/'+ params['pageSize']);;
	}
	// 换桌
	static Future changeTable(Map params) async {
		return  await HttpUtil.getInstance().put('/table/changeTable/'+ params['sourceTableId'] +'/'+ params['targetTableId']);
	}
	// 支付
	static Future pay(Map<String, String> params) async {
		return await HttpUtil.getInstance().post('/cash/pay', params: params);
	}
	// 查询分页沽清数据
	static Future sellcalculation(Map<String, String> params) async {
		return await HttpUtil.getInstance().get('/sellcalculation/pageList/'+ params['page']+'/'+ params['pageSize'], params: params);
	}
	// 根据编码搜索菜品
	static Future searchDish(Map<String, dynamic> params) async {
		return await HttpUtil.getInstance().get('/dish/queryByCode/' + params['code']+'/' + params['page']+'/'+ params['pageSize'], params: params);
	}
	// 添加沽清
	static Future addGuqing(Map<String, dynamic> params) async {
		return await HttpUtil.getInstance().post('/sellcalculation/add', params: params);
	}
	// 获取桌台所有未结账订单
	static Future getOrder(Map<String, String> params) async {
		return await HttpUtil.getInstance().get('/cash/orderDetails/$params.tableId', params: params);
	}
	// 获取菜品分类
	static Future getDishCategory() async {
		return await HttpUtil.getInstance().get('/dish/category');
	}
	// 获取菜品分页列表  Map<String, dynamic>.from(params)
	static Future getDishList(Map<dynamic, dynamic> params) async {
		return await HttpUtil.getInstance().get('/dish/dishPageList/'+ params['categoryId'] +'/' + params['type'] + '/' + params['page']+ '/' + params['pageSize'], params: params);
	}
	// 退菜接口
	static Future backDish(Map<dynamic, dynamic> params) async {
		return await HttpUtil.getInstance().post('/order/returnDish/${params['detailId']}', params: params);
	}
	// 赠菜接口
	static Future presentDish(Map<dynamic, dynamic> params) async {
		return await HttpUtil.getInstance().post('/order/presentDish/${params['detailId']}', params: params);
	}
	// 锁桌
	static Future lockTable(Map<String, String> params) async {
		return await HttpUtil.getInstance().post('/cash/lockTable', params: params);
	}
	// 收据
	static Future receiptList(Map<String, String> params) async {
		return await HttpUtil.getInstance().post('/order/receipt', params: params);
	}
	// 反结账- 从新结账
	static Future reReceipt(Map<String, dynamic> params) async {
		return  await HttpUtil.getInstance().put('/order/reverse/' + params['orderId'], params: params);
	}
	// 反结账- 备注信息 1 退菜原因 2 退单原因 3 撤单原因 4 反结账原因 5 打折原因 6 赠菜原因 7 免单原因 8整单备注 9传单备注
	static Future remark(String type) async {
		return  await HttpUtil.getInstance().get('/dish/remark/type/$type');
	}
	// 根据菜品Id 获取口味信息
	static Future getFlavor(String dishId) async {
		return  await HttpUtil.getInstance().get('/dish/flavor/dishId/$dishId');
	}
	// 根据tableID查询订单列表
	static Future getOrderDetile(String tableId) async {
		return await HttpUtil.getInstance().get('/table/getOrders/$tableId');
	}
	// 结账
	static Future accouts(Map params) async {
		return await HttpUtil.getInstance().post('/order/pay/orderId/${params['orderId']}', params: params);
	}
	// 改人数
	static Future changeMember(Map<dynamic, dynamic> params) async {
		return await HttpUtil.getInstance().put('/table/changeNumber/${params['tableId']}/${params['number']}', params: params);
	}
	// 获取员工列表
	static Future getMemberList() async {
		return await HttpUtil.getInstance().get('/order/getOperators');
	}
	// 获取挂账人/公司列表
	static Future getCreditList(type) async {
		return await HttpUtil.getInstance().get('/credit/list/${type}');
	}
}
