import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import * as Icons  from '@element-plus/icons-vue'
import 'element-plus/theme-chalk/el-message.css';
import 'element-plus/theme-chalk/el-loading.css';
import ElementPlus from 'element-plus'
import 'default-passive-events'
// import * as echarts from 'echarts';//引入echarts

import ECharts from 'vue-echarts'
import 'echarts'


import lang from 'element-plus/lib/locale/lang/zh-cn'


const app=createApp(App);

// app.config.globalProperties.$echarts = echarts;//全局使用

for (let i in Icons ) {
    app.component(i, Icons[i])
  }
// app.use(locale)
app.use(ElementPlus, {
  locale: lang,
})
app.component('ECharts',ECharts)
app.use(store)
app.use(router)
app.mount('#app')
// createApp(App).use(store).use(router).mount('#app')



