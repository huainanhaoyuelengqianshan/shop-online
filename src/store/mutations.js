export default {
  changeCity (state, city) {
    state.city = city
    try {
      localStorage.city = city
    } catch (e) {}
  },
  setProductList (state, data) {
    state.productList = data
    try {
      localStorage.productList = data
    } catch (e) {}
  },
  // 添加到购物车
  addCart (state, id) {
    // 先判断购物车是否已有，如果有，数量+1
    const isAdded = state.cartList.find(item => item.id === id)
    if (isAdded) {
      isAdded.count++
    } else {
      state.cartList.push({
        id: id,
        count: 1
      })
    }
    try {
      const isAdded = localStorage.cartList.find(item => item.id === id)
      if (isAdded) {
        isAdded.count++
      } else {
        localStorage.cartList.push({
          id: id,
          count: 1
        })
      }
    } catch (e) {}
  },
  // 修改商品数量
  editCartCount (state, payload) {
    const product = state.cartList.find(item => item.id === payload.id)
    product.count += payload.count
  },
  // 删除商品
  deleteCart (state, id) {
    const index = state.cartList.findIndex(item => item.id === id)
    state.cartList.splice(index, 1)
  },
  // 清空购物车
  emptyCart (state) {
    state.cartList = []
  },
  LOGIN: (state, data) => {
    state.token = data
    window.sessionStorage.setItem('token', data)
  },
  LOGOUT: (state) => {
    // 登出的时候要清除token
    state.token = null
    window.sessionStorage.removeItem('token')
  },
  // USERNAME: (state, data) => {
  //   // 把用户名存起来
  //   state.username = data
  //   window.sessionStorage.setItem('username', data)
  // },
  saveinfo (state, data) {
    state.username.push(data.name)
    state.password.push(data.checkPass)
  },
    gologin (state, data) {
      state.isLogin = true
      state.currentuser = data
    },
    outlogin(state,data){
      state.isLogin = false
      state.currentuser = ''
    },
    getAccount(state,data){
      state.currentaccount = data
    }

}
