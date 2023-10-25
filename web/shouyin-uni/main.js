
// #ifndef VUE3
import Vue from 'vue'
import App from './App'
import {request} from './utils/request.js'
Vue.prototype.$request=request
Vue.config.productionTip = false

App.mpType = 'app'

// 判断是否是平板
uni.getSystemInfo({
	success: (res)=>{
		console.log("屏幕尺寸：", res.windowWidth, res.windowHeight)
		if(res.windowWidth > 500){
			Vue.prototype.pad = true
		}else{
			Vue.prototype.pad = false
		}
	}
});


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