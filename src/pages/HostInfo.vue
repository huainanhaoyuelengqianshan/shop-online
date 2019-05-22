<template>
    <div class="userInfo">
        <!--<div>是否已登录：{{this.$store.state.isLogin}}</div>-->
        <div>
            <a-upload
                    :beforeUpload="handleUpload"
                    :showUploadList ="false"
            >
                <a-avatar :size="100" :src="avatar" alt=""/>
            </a-upload>
        </div>
        <div class="address">以太坊地址：
            <br></br><br></br>{{this.$store.state.currentaccount}}
        </div>
        <div class="balance">账户余额：
            <br></br><br></br>{{this.balance}}ETH
        </div>
        <div class="user">用户名：
            <br></br><br></br>{{this.$store.state.currentuser}}
        </div>
    </div>
</template>

<script>
    import {notification,message} from 'ant-design-vue'
    import {saveImageToIpfs,ipfsPrefix,userContract,web3} from '../config.js'
    export default {
        name: "host-info",
        data(){
            return{
                avatar:'',
                balance:0
            }
        },
        created () {
            this.init()
            //console.log()
        },
        methods:{
            init:async function(){
                const [account] = await web3.eth.getAccounts()
                const userInfo = await userContract.methods.findUser().call({from:account})
                this.balance = await web3.eth.getBalance(account)
                this.balance = web3.utils.fromWei(this.balance)
                // console.log("this.balance："+this.balance)
                let [userAddress, username, time, index,img] = Object.values(userInfo)
                // console.log("img:"+img)
                // console.log("userAddress:"+userAddress)
                // console.log("username"+username)
                if(img === ''){
                    this.avatar = 'https://zos.alipayobjects.com/rmsportal/ODTLcjxAfvqbxHnVXCYX.png'
                }else{
                    this.avatar = `${ipfsPrefix}${img}`
                }
            },
            handleUpload: async function(file){
                const hash = await saveImageToIpfs(file)
                //console.log(hash)
                // 3. ipfs哈希上链
                // console.log("img: "+this.avatar)
                const [account] = await web3.eth.getAccounts()
                //return false
                const hide = message.loading('头像上传中',0)
                await userContract.methods.updateUser(hash)
                    .send({
                        from:account
                    })
                this.avatar = `${ipfsPrefix}${hash}`
                hide()
            }
        }
    }
</script>

<style scoped>
    .userInfo{
        position : relative;
        top : 0;
        left: 0;
        right: 0;
        display: flex;
        line-height: .48rem;
        background: lightgray;
        justify-content: space-around;
        text-align: center;
        height: 120px;

    }
    .address{
        margin-top: 2rem;
        font-weight: bold;
        /*font-size: 15px;*/
    }
    .balance{
        margin-top: 2rem;
        font-weight: bold
    }
    .user{
        margin-top: 2rem;
        font-weight: bold
    }
</style>