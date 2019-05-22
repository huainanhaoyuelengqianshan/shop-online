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
                        <a-form-item label="购买">
                            <a-button  type='primary' @click="sec_buy">
                                支付{{price}}ETH
                            </a-button>
                        </a-form-item>
                        <a-form-item>
                            <a-button  @click="getInformation">
                                查看溯源结果
                            </a-button>
                            <div v-if="showAll === true" v-for="(item,i) of pre_owner" :key="i">
                                <!--<a-col :span="6">-->
                                <div v-if="i===0">
                                    <a-avatar :size="50" :src="avatar" alt=""/>
                                    <div>商家地址：{{pre_owner[i]}}</div>
                                    <div>用户名：{{pre_name[i]}}</div>
                                    <div>新品价格：{{pre_price[i+1]}} ETH</div>
                                </div>
                                <div v-if="i>0">
                                    <a-avatar :size="50" :src="avatar" alt=""/>
                                    <div>第{{i}}位买家地址：{{pre_owner[i]}}</div>
                                    <div>用户名：{{pre_name[i]}}</div>
                                    <div>购买时价格价格：{{pre_price[i]}} ETH</div>
                                    <div>使用时间：<p v-if="days[i]!==0">{{days[i]}}天</p>{{hours[i]}}小时</div>
                                </div>
                            </div>
                        </a-form-item>
                    </a-form>
                </a-col>
            </a-row>
        </a-col>
    </div>

</template>

<script>
    import { web3,userContract,ProductListContract,saveImageToIpfs,ipfsPrefix} from '../config'
    import {notification,message} from 'ant-design-vue'
    import ComMents from './Comments'
    export default {
        name: "hostdetail",
        components :{
            ComMents
        },
        data(){
            return {
                id: 0,
                showAll:false,
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
                days:[],
                hours:[],
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
                this.id =parseInt(this.$route.path.slice(14))
                console.log("this.id:"+this.id)
                // const contract = getProductContract(this.address)
                const detail = await ProductListContract.methods.getSecDetail(this.id).call({from:this.$store.state.currentaccount})
                console.log("detail"+detail)
                let [name,content,price,img,role,productindex] = Object.values(detail)
                // this.account = account
                this.sec_img = `${ipfsPrefix}${img}`
                this.name = name
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
            sec_buy: async function (){
                console.log("二手买入商品序列号："+this.id)
                await window.web3.currentProvider.enable()
                let time = Date.now();
                time = parseInt(time/1000/60/60);//先处理成小时
                const hide = message.loading('交易信息正在上链',0)
                await ProductListContract.methods.sec_buy(this.id,time)
                    .send({
                        from:this.$store.state.currentaccount,
                        value:web3.utils.toWei(this.price),
                        gas:'6000000'
                    })
                hide()
                fetch("http://155.138.165.114:3001/users/user_data",{
                    method:'POST',
                    headers:{
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    },
                    body:JSON.stringify({
                        account:this.$store.state.currentaccount,
                        id:this.productindex
                    })
                })
                // console.log("当前产品地址："+t_address)
                this.init()
            },
            getInformation:async function(){
                const secInfo = await ProductListContract.methods.getSecInfo(this.id).call({from:this.$store.state.currentaccount})
                this.secInfo = secInfo
                console.log("secInfo"+typeof(secInfo))
                const [pre_owner, pre_price,time] = Object.values(secInfo)
                this.pre_owner = pre_owner
                for(let i= 0;i<pre_owner.length;i++){
                    this.pre_name[i] = await userContract.methods.findUsernameByAddress(this.pre_owner[i]).call({from:this.$store.state.currentaccount})
                }
                //this.pre_price = web3.utils.fromWei(pre_price)
                // this.time = time
                for(let i=0;i<time.length;i++){
                    var date = new Date();
                    date = Math.floor(date/(3600*1000))
                    var date_temp = date - time[i]
                    this.days[i] = Math.floor(date_temp/24)
                    console.log("this.days[i]:"+typeof(this.days[i]))
                    this.hours[i] = date_temp%24    //计算天数后剩余的小时数
                    console.log("this.hours[i]:"+this.hours[i])
                }

                // this.time = this.getNowFormatDate(this.time)
                //console.log("pre1"+pre_owner,"pre2"+pre_price,"pre3"+time)
                for(let i =0 ;i<pre_price.length;i++){
                    // this.pre_owner[i] = pre_owner[i]
                    this.pre_price[i] = web3.utils.fromWei(pre_price[i])
                }
                this.showAll = true
            },
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