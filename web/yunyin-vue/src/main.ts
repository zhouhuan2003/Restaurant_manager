import { createApp } from 'vue'
import App from './App.vue'
import router from './router'
import store from './store'
import * as Icons  from '@element-plus/icons-vue'
import 'element-plus/theme-chalk/el-message.css';
import 'element-plus/theme-chalk/el-loading.css';
import ElementPlus from 'element-plus'
import lang from 'element-plus/lib/locale/lang/zh-cn'


const app=createApp(App);

for (let i in Icons ) {
    app.component(i, Icons[i])
  }
// app.use(locale)
app.use(ElementPlus, {
  locale: lang,
})
app.use(store)
app.use(router)
app.mount('#app')
// createApp(App).use(store).use(router).mount('#app')
