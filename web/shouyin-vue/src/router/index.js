import Vue from 'vue'
import VueRouter from 'vue-router'
import login from '../views/login/index.vue'

Vue.use(VueRouter)

const routes = [
  {
    path:'/',
    redirect:'/login'
  },
  {
    path: '/login',
    component: login
  },
  {
    path: '/index',
    name: 'index',
    component: () => import('../components/home/index.vue'),
    redirect:'/tangdian',
    children:[
      {
        path:'/tangdian',
        name:'tangdian',
        component:()=>import('../views/tangdian/index.vue')
      },
      {
        path:'/orderInfo',
        name:'orderInfo',
        component:()=>import('../views/orderInfo/index.vue')
      },
      {
        path:'/guqing',
        name:'guqing',
        component:()=>import('../views/guqing/index.vue')
      },
      {
        path:'/dingdan',
        name:'dingdan',
        component:()=>import('../views/dingdan/index.vue')
      },
      {
        path:'/shouju',
        name:'shouju',
        component:()=>import('../views/shouju/index.vue')
      },
    ]
  }
]

const router = new VueRouter({
  mode: 'history',
  base: process.env.BASE_URL,
  routes
})

export default router
