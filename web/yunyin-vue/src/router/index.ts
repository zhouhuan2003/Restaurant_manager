import { createRouter, createWebHistory, RouteRecordRaw } from 'vue-router'


const routes: Array<RouteRecordRaw> = [
  {
    path: '/',
    name: 'home',
    redirect: '/login'
  },
  {
    path: '/login',
    name: 'login',
    component: () => import('../views/login/index.vue')
  },
  {
    path: '/admin',
    name: 'admin',
    component: () => import('../components/admin/index.vue'),
    redirect: '/member',
    children: [
      {
        path: '/member',
        name: 'member',
        meta: {
          title: '账号管理'
        },
        component: () => import('../views/member/index.vue')
      },
      {
        path: '/addMember',
        name: 'addMember',
        meta: {
          title: '添加账号'
        },
        component: () => import('../views/member/addMember.vue')
      }
    ]
  }
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

export default router
