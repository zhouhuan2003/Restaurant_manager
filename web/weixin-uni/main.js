
// #ifndef VUE3
import Vue from 'vue'
import App from './App'
//导入网络请求的包
import { $http } from '@escook/request-miniprogram'
import '@/static/iconfont.css'

uni.$http=$http

$http.baseUrl="http://192.168.1.3:8086"

$http.beforeRequest=function(options){
	options.header={
		"storeId":'1665683364679761922',
		"shopId":"16513893"
	}
	uni.showLoading({
		title:"数据加载中..."
	})
}

$http.afterRequest=function(options){
	uni.hideLoading()
}

//封装弹框的方法
uni.$showMsg=function(title="数据请求失败!",duration=1500){
	uni.showLoading({
		title,
		
		duration,
		
		icon:'none'
	})
}

Vue.config.productionTip = false


App.mpType = 'app'

const app = new Vue({
    ...App
})
app.$mount()
// #endif

// #ifdef VUE3
import { createSSRApp } from 'vue'
import App from './App.vue'
export function createApp() {
  const app = createSSRApp(App)
  return {
    app
  }
}
// #endif