import Vue from 'vue'
import Router from 'vue-router'

Vue.use(Router)
//路由跳转之前

// export default new Router({
  const routes = [
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
          path: '/recommend',
          name: 'Recommend',
          component: () => import('@/pages/Recommend')
      },
      {
          path: '/host/detail/:address',
          name: 'HostDetail',
          component: () => import('@/pages/HostDetail')
      },
  ]
// })
const RouterConfig = {
    // 使用 HTML5 的 History 路由模式
    mode: 'history',
    routes: routes
};
const router = new Router(RouterConfig);
router.beforeEach((to, from, next) => {
    if (to.path !== '/'&& to.path !== '/trade' && !localStorage.token) {
        return next('/')
    }
    next()
});
export default router
