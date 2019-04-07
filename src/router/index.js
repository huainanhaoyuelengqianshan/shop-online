import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'ProductList',
      component: () => import('@/pages/productlist/ProductList')
    },
    {
        path: '/add',
        name: 'AddProduct',
        component: () => import('@/pages/addproduct/AddProduct')
    },
    {
      path: '/detail/:address',
      name: 'Detail',
      component: () => import('@/pages/Detail')
    },
    {
        path: '/host',
        name: 'Host',
        component: () => import('@/pages/Host')
    },
    {
        path: '/trade',
        name: 'Trade',
        component: () => import('@/pages/Trade')
    },
      {
          path: '/host/detail/:address',
          name: 'HostDetail',
          component: () => import('@/pages/HostDetail')
      },
  ]
})
