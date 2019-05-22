let defaultCity = '上海'
try {
  if (localStorage.city) {
    defaultCity = localStorage.city
  }
} catch (e) {}

let defaultProduct = []
try {
  if (localStorage.productList) {
    defaultProduct = localStorage.productList
  }
} catch (e) {}

let defaultCart = []
try {
  if (localStorage.cartList) {
    defaultCart = localStorage.cartList
  }
} catch (e) {}

export default {
  city: defaultCity,
  productList: defaultProduct,
  cartList: defaultCart,
  token: window.sessionStorage.getItem('token'),
  username: [],
  password: [],
  isLogin: false,
  currentuser: '',
    currentaccount:''
}
