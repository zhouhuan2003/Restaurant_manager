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
    path: '/group',
    name: 'group',
    component: () => import('../components/group/index.vue'),
    redirect: '/barnd',
    children: [
      {
        path: '/barnd',
        name: 'barnd',
        meta: {
          title: '品牌管理'
        },
        component: () => import('../views/group/barnd/index.vue')

      },
      {
        path: '/barnd/add',
        meta: {
          title: '添加品牌',
          hidden: true
        },
        component: () => import('../views/group/barnd/barndAdd.vue')
      },
      {
        path: '/shop',
        name: 'shop',
        meta: {
          title: '门店管理'
        },
        component: () => import('../views/group/shop/index.vue')
      },
      {
        path: '/shop/add',
        meta: {
          title: '添加门店'
        },
        component: () => import('../views/group/shop/addShop.vue')
      },
      {
        path: '/shopowner',
        name: 'shopowner',
        meta: {
          title: '店长管理'
        },
        component: () => import('../views/group/shopowner/index.vue')
      },
      {
        path: '/shopowner/add',
        meta: {
          title: '添加店长'
        },
        component: () => import('../views/group/shopowner/addShopowner.vue')
      },
    ]
  },
  {
    path: '/shopAdmin',
    name: 'shopAdmin',
    redirect:'/about',
    component: () => import('../components/shop/index.vue'),
    children: [
      {
        'path': '/about',
        'component': () => import(/* webpackChunkName: "tree" */ '@/views/shop/shopAbout/index.vue'),
        'meta': {
          'title': '门店概况'
        }
      },
      {
        'path': '/member',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/member/index.vue'),
        'meta': {
          'title': '员工管理'
        }
      },
      {
        'path': '/class',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/class/index.vue'),
        'meta': {
          'title': '分类管理'
        }
      },
      {
        'path': '/member/add',
        'component': () => import(/* webpackChunkName: "dashboard" */ '@/views/shop/member/addMember.vue'),
        'meta': {
          'title': '添加员工',
          'hidden': true
        }
      },
      {
        'path': '/fond',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/foodType/index.vue'),
        'meta': {
          'title': '菜品管理'
        }
      },
      {
        'path': '/fond/add',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/foodType/addFoodtype.vue'),
        'meta': {
          'title': '添加菜品',
          'hidden': true
        }
      },
      {
        'path': '/setmeal',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/package/index.vue'),
        'meta': {
          'title': '套餐管理'
        }
      },
      {
        'path': '/setmeal/add',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/package/addSetmeal.vue'),
        'meta': {
          'title': '添加套餐',
          'hidden': true
        }
      },
      {
        'path': '/shopTable',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/shopTable/index.vue'),
        'meta': {
          'title': '桌台管理'
        }
      },
      {
        'path': '/shopTable/add',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/shopTable/addTable.vue'),
        'meta': {
          'title': '新增桌台',
          'hidden': true
        }
      },
      {
        'path': '/area',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/area/index.vue'),
        'meta': {
          'title': '区域管理'
        }
      },
      {
        'path': '/accounts',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/account/index.vue'),
        'meta': {
          'title': '挂账管理'
        }
      },
      {
        'path': '/accounts/add',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/account/addAccount.vue'),
        'meta': {
          'title': '添加挂账',
          'hidden': true
        }
      },
      {
        'path': '/accounts/order',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/account/order.vue'),
        'meta': {
          'title': '订单详情',
          'hidden': true
        }
      },
      {
        'path': '/accounts/repayment',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/account/repayment.vue'),
        'meta': {
          'title': '还款',
          'hidden': true
        }
      },
      {
        'path': '/pay',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/pay/index.vue'),
        'meta': {
          'title': '支付方式',
          'hidden': true
        }
      },
      {
        'path': '/shopSet',
        'component': () => import(/* webpackChunkName: "shopTable" */ '@/views/shop/shopSet/index.vue'),
        'meta': {
          'title': '门店设置'
        }
      },
      {
        'path': '/chartAabout',
        'component': () => import(/* webpackChunkName: "tree" */ '@/views/shop/chart/index.vue'),
        'meta': {
            'title': '营收概况'
        }
    }
    ]
  },
  // {
  //   'path': '/chart',
  //   // 'component': () => import('../views/group/shopowner/addShopowner.vue'),
  //   'redirect': '/chart/about',
  //   'meta': {
  //       'title': '收银报表',
  //       'icon': 'shop',
  //       'roles': ['shop']
  //   },
  //   'children': [
        
//     ]
// },
]

const router = createRouter({
  history: createWebHistory(process.env.BASE_URL),
  routes
})

router.beforeEach((to, from, next) => {
  const token: String | null = localStorage.getItem("token")
  if (!token && to.path !== "/login") {
    next('/login')
  } else {
    next()
  }
})

export default router
