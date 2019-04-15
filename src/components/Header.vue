<template>
    <div>
        <!--<div className="logo">-->
          <!--<img src="/logo.png" alt=""/>-->
        <!--</div>-->
        <a-menu class="menu"
                theme='dark'
                mode='horizontal'
                :defaultSelectedKeys="['1']"
        >
          <a-menu-item key="/">
            <router-link to='/'>商品列表</router-link>
          </a-menu-item>
          <a-menu-item key="/add">
            <router-link to='/add'>添加商品</router-link>
          </a-menu-item>
          <a-menu-item key="/host">
            <router-link to='/host'>个人主页</router-link>
          </a-menu-item>
            <a-menu-item key="/trade">
                <router-link to='/trade'>二手市场</router-link>
            </a-menu-item>
            <a-menu-item>
                <a-button class="Login-button Login-mm" @click="handleClick"> 点击进行登录
                </a-button>
            </a-menu-item>
        </a-menu>

    </div>
</template>

<script>
import { web3,userContract,saveImageToIpfs,ipfsPrefix} from '../config'
export default {
  name: 'Header',
  // props:{
  //     SelectedKeys:
  // }
  data () {
    return {
        loading:false,
        nonce:-1,
        signature:"",
        msg:'',
        username:"",
        img:""
        // defaultSelectedKeys: this.props.location.pathname
    }
  },
    watch: {
        $route(to, from) {
            console.log(this.$route.path);
        }
    },
    methods:{
        handleClick:async function() {//3
            const onLoggedIn  = this.$route.path;//React中的每一个组件，都包含有一个属性（props），属性主要是从父组件传递给子组件的，在组件内部，我们可以通过this.props获取属性对象
            //就是点击页面按钮时传来的属性对象
            if (!window.web3) {//4 先检查是否安装了metamask
                window.alert('请先安装MetaMask插件');
                return;
            }
            // if (!web3) {//5 检查metamask是否连接上了网络
            //     web3 = new Web3(window.web3.currentProvider);
            // }
            // if (!web3.eth.coinbase) {//6 检查metamask是否登录
            //     window.alert('请先在MetaMask中激活');
            //     return;
            // }
            web3.currentProvider.enable()
            const [account] = await web3.eth.getAccounts()
            this.account = account
            this.loading = true //到这里metamask就连接上了，状态为true
            //Look if user with current publicAddress is already present on backend
            let judgeAddress = await userContract.methods.isExitUserAddress().call({
                from:account
            })
            this.nonce = await userContract.methods.createRand().call({
                from:account
            })
            if(judgeAddress === true){
                this.handleSignMessage()
                    this.handleAuthenticate()

            } else {
                this.handleSignup()
                this.handleSignMessage()
                this.handleAuthenticate()

            }
        },
        handleSignup :async function() {
            const [account] = await web3.eth.getAccounts()
            this.index = await userContract.methods.createUser(this.username,this.img).call({
                from:account
            })
            //console.log(this.index)
        },
        handleSignMessage :async function() {
            const [account] = await web3.eth.getAccounts()
            this.msg = web3.utils.fromUtf8(`我正在使用MeatMask进行身份确认: ${this.nonce}`)
            this.signature = await web3.eth.personal.sign(
                this.msg,
                account
            ).then(
                console.log("this.signature :"+this.signature)
            )
        },
        handleAuthenticate :async function() {
            const [account] = await web3.eth.getAccounts()
            console.log("account: "+account)
            const address_test = await web3.eth.personal.ecRecover(this.msg, this.signature)
            console.log("address_test: "+address_test)
        }

        }
    }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  .menu{
      line-height:64px
  }

</style>
