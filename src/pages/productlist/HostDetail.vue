<template>
    <div>
        <a-col>
            <a-row type='flex' justify="center" style="marginTop:'30px'">
                <a-col :span="20">
                    <a-form @submit="handleSubmit">
                        <a-form-item  label="商品名">
                            {{name}}
                        </a-form-item>
                        <a-form-item  label="商品简介">
                            {{content}}
                        </a-form-item>
                        <a-form-item  label="当前价格">
                            {{price}} ETH
                        </a-form-item>
                        <a-form-item  label="商品图片">
                            <img class="item" :src="sec_img" alt=""/>
                        </a-form-item>
                        <a-button  @click="sec_out">我要卖出</a-button>
                        <a-form-item>
                            <a-upload  :beforeUpload="handleUpload" :showUploadList="false">
                                <a-button type='primary'>上传图片</a-button>
                            </a-upload>
                        </a-form-item>
                        <a-form-item  label="卖出价格">
                            <a-input name='sell_price' v-model="sell_price" />
                        </a-form-item>
                        <a-form-item>
                            <a-button  type='primary' htmlType="submit">卖出</a-button>
                        </a-form-item>

                    </a-form>
                </a-col>
            </a-row>
        </a-col>
        <com-ments v-if="role ===  '0'" :id="productindex" :tag="id"></com-ments>
    </div>

</template>

<script>
    import { web3,userContract,ProductListContract,saveImageToIpfs,ipfsPrefix} from '../config'
    import {notification,message} from 'ant-design-vue'
    import ComMents from './Comments'
    import eventBus from './eventBus.js'
    // const BigNumber = require('bignumber.js')
    export default {
        name: "hostdetail",
        components :{
            ComMents
        },
        data(){
            return {
                id: 0,
                showAll:false,
                account:'',
                name:'',
                content:'',
                img:'',
                sec_img:'',
                price:0,
                sell_price:0,
                role:0,
                secInfo:[],
                pre_owner:[],
                pre_price:[],
                pre_name:[],
                time:[],
                secInfo_l:0,
                avatar:'',
                productindex:0,
                secout:false
            }
        },
        created () {
            this.init()
            //console.log()
        },
        computed: {
            getAccount() {
                return this.$store.state.currentaccount;
            }
        },
        watch: {
            getAccount(val) {
                this.init()
            }
        },
        methods:{
            async init(){
                // const [account] = await web3.eth.getAccounts()
                console.log(this.$route.path)
                // eventBus.$on('id_trans', args => {
                //     this.id = parseInt(args)
                //     // console.log("args:"+typeof (args))
                // }) //需要修改
                this.id = parseInt(this.$route.path.slice(13))
                //console.log("args:"+args)
                console.log("this.id:"+this.id)
                // const contract = getProductContract(this.address)
                const detail = await ProductListContract.methods.getSecDetail(this.id).call({from:this.$store.state.currentaccount})
                console.log("detail"+detail)
                let [name,content,price,img,role,productindex] = Object.values(detail)
                // this.account = account
                this.sec_img = `${ipfsPrefix}${img}`
                this.name = name
                console.log("name:"+name)
                this.content = content
                this.role = role
                this.productindex = parseInt(productindex)
                console.log("role"+this.role)
                this.price = web3.utils.fromWei(price)
                const user_detail = await userContract.methods.findUser().call({from:this.$store.state.currentaccount})
                let [userAddress,username, usertime, userindex, userimg] = Object.values(user_detail)
                if(userimg === ''){
                    this.avatar = 'https://zos.alipayobjects.com/rmsportal/ODTLcjxAfvqbxHnVXCYX.png'
                } else {
                    this.avatar = `${ipfsPrefix}${userimg}`
                }
                // this.avatar = `${ipfsPrefix}${userimg}`
                console.log("userimg:"+userimg)
            },
            // getNowFormatDate:function(user_time) {
            //     var seperator1 = "-";
            //
            //     var year = user_time.getFullYear();
            //     var month = user_time.getMonth() + 1;
            //     var hour = user_time.getHours();
            //     // var minutes = date.getMinutes() ;
            //     // var seconds = date.getSeconds();
            //     // var strDate = date.getDate();
            //     if (month >= 1 && month <= 9) {
            //         month = "0" + month;
            //     }
            //     if (strDate >= 0 && strDate <= 9) {
            //         strDate = "0" + strDate;
            //     }
            //     var currentdate = year + seperator1 + month + seperator1 + strDate+"  "+hour;
            //
            //     return currentdate;
            // },

            handleUpload: async function(file){
                const hash = await saveImageToIpfs(file)
                this.img = hash
                this.init()
            },
            handleSubmit: async function(e){
                e.preventDefault()
                window.web3.currentProvider.enable()
                let sell_price = web3.utils.toWei(this.sell_price)
                const hide = message.loading('正在售出',0)
                await ProductListContract.methods.sec_sell(this.id,sell_price,this.img)
                    .send({
                        from:this.$store.state.currentaccount,
                        gas:'6000000'
                    })
                hide()
                this.init()
            },
            sec_out:function(){
                this.secout = true
            }
        },
        activated(){
            this.getInformation()
        }
    }
</script>

<style scoped>

</style>