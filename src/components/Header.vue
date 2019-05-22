<template>
    <div>
        <div class="logo">
            <img src="../assets/logo.png" alt=""/>
        </div>
        <!--<vue-metamask-->
                <!--@onComplete="onComplete"-->
        <!--&gt;-->
        <!--</vue-metamask>-->
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
            <a-menu-item key="/recommend">
                <router-link to='/recommend'>智能推荐</router-link>
            </a-menu-item>
            <!--<a-menu-item key="/ann">-->
                <!--<router-link to='/ann'>神经网络</router-link>-->
            <!--</a-menu-item>-->
            <a-menu-item class="account">
                <a-button  @click="handleStart" v-if="flag===''"> 开始
                </a-button>
                <p class="username" v-else>{{this.$store.state.currentuser}}
                    <a-button  @click="handleLogout">登出
                    </a-button>
                </p>
            </a-menu-item>
        </a-menu>
        <a-modal
                v-model="modal_visible"
                title="账户注册"
                onOk="handleOk"
                centered
        >
            <template slot="footer">
                <a-button key="back" @click="handleCancel">取消</a-button>
                <a-button key="submit" type="primary" :loading="loading" @click="handleContinue">
                    继续
                </a-button>
            </template>
            <a-input
                    placeholder="请输入用户名"
                    v-model="userName">
            </a-input>
        </a-modal>

    </div>
</template>

<script>
import {notification,message} from 'ant-design-vue'
import { web3,userContract,saveImageToIpfs,ipfsPrefix} from '../config'
import VueMetamask from 'vue-metamask';
export default {
  name: 'Header',
  components: {
      VueMetamask,
  },
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
        userName:"",
        modal_visible:false,
        storage_token:'',
        index:-1,
        judgeAddress:false,
        web3_check:null,
        MetaMaskAddress:""
        // defaultSelectedKeys: this.props.location.pathname
    }
  },
    computed:{
        flag:function(){
            var flag = this.username
            return flag
        }
    },
    created(){
      this.account()
      this.username = localStorage.token
    },
    methods:{
        account: async function(){
            await web3.currentProvider.enable()
            var [account] =  await web3.eth.getAccounts()
            console.log("account:" +
                ""+account)
            this.MetaMaskAddress = account
            this.$store.commit('getAccount',account)
            // console.log("web3.eth.getAccounts: "+await web3.eth.getAccounts())
            // var account = web3.eth.getAccounts()
            setInterval(async () => {
                var [current_account] = await web3.eth.getAccounts()
                if ( current_account!== account) {
                    account = current_account
                    this.MetaMaskAddress = current_account
                    const hide = message.loading('账户已切换，请重新签名确认身份',2)
                    this.handleLogout()
                    console.log("this.MetaMaskAddress:" +
                        ""+this.MetaMaskAddress)
                    // this.$store.commit('getAccount', current_account)
                }
            }, 500);

        },
        handleStart:async function(){
            if (!window.web3) {//4 先检查是否安装了metamask
                window.alert('请先安装MetaMask插件');
                return;
            }
            await web3.currentProvider.enable()
            const [account] = await web3.eth.getAccounts()
            this.account = account
            this.judgeAddress = await userContract.methods.isExitUserAddress().call({
                from:account
            })
            console.log("judgeAddress:"+this.judgeAddress)
            if(this.judgeAddress === true){
                this.handleSignMessage()
                // this.handleAuthenticate()
            } else {
                this.modal_visible = true
            }
        },
        handleCancel() {
            this.modal_visible = false
        },
        handleContinue:function(){
            this.loading = true;
            setTimeout(() => {
                this.modal_visible = false;
                this.loading = false;
            }, 2000);
            this.handleSignup()
        },
        handleSignup :async function() {
            // await web3.currentProvider.enable()
            const [account] = await web3.eth.getAccounts()
            this.account = account
            const hide = message.loading('正在注册，请稍等',0)
            this.index = await userContract.methods.createUser(this.userName).send({
                from:account
            })
            hide()
            console.log("this.index:"+this.index)
            this.handleSignMessage()
        },
        handleSignMessage :async function() {
            const [account] = await web3.eth.getAccounts()
            this.account = account
            this.nonce = await userContract.methods.createRand().call({
                from:account
            })
            var userInfo = await userContract.methods.findUser().call({from:account})
            let [userAddress, username, time, index,img] = Object.values(userInfo)
            console.log("userAddress: "+userAddress)
            this.msg = web3.utils.fromUtf8(`我正在使用MeatMask进行身份确认: ${this.nonce}`)
            this.signature = await web3.eth.personal.sign(
                this.msg,
                account
            )
            console.log("this.signature :"+this.signature)
            const address_test = await web3.eth.personal.ecRecover(this.msg, this.signature)
            console.log("address_test: "+address_test)
            if(address_test === userAddress.toLowerCase()){
                console.log("true")
                this.username = username
                localStorage.token = this.username
                setTimeout(() => {
                    this.useruame = '';
                    localStorage.token = ''
                }, 6000000);
                this.$store.commit('gologin', username)
                this.$store.commit('getAccount', account)
            }else{
                console.log("false")
            }
        },
        handleLogout:function () {
            this.username = ''
            localStorage.token = ''
            this.$store.commit('outlogin')
        }
        }
    }
</script>

<!-- Add "scoped" attribute to limit CSS to this component only -->
<style scoped>
  .menu{
      line-height:64px
  }
  .logo{
      width:200px;
      float: left;
      margin-right: 15px;
      margin-top: 15px;
      margin-left: 5px;
  }
  .logo img{
      width:100%;
  }
    .account{
        float:right;
    }
    .username{
        /*font-size: 16px;*/
        /*color: ;*/
    }
</style>
