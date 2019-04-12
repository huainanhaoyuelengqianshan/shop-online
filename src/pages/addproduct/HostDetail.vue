<template>
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
                    <a-form-item  label="新品价格">
                        {{price}} ETH
                    </a-form-item>
                    <a-form-item  label="身份">
                        <a-upload  :beforeUpload="handleUpload" :showUploadList="false">
                            <a-button type='primary'>上传图片</a-button>
                        </a-upload>
                    </a-form-item>
                    <a-form-item  label="卖出价格">
                        <a-input name='sell_price' v-model="sell_price" />
                    </a-form-item>
                    <a-form-item>
                        <a-button  v-if="role === '0'" type='primary' htmlType="submit">卖出</a-button>
                    </a-form-item>
                    <a-form-item  label="购买">
                        <a-button v-if="role === '2'" type='primary' @click="sec_buy">
                            支付{{price}}ETH
                        </a-button>
                    </a-form-item>
                    <a-form-item>
                        <a-button  v-if="role === '2'" @click="getInformation">
                            查看溯源结果
                        </a-button>
                        <div v-if="showAll === true" v-for="(item,i) of pre_owner" :key="i">
                            <!--<a-col :span="6">-->
                                <div>
                                    <div>曾经的使用者：{{pre_owner[i]}}</div>
                                    <div>曾经的价格：{{pre_price[i]}}</div>
                                    <div>曾经的時間：{{time[i]}}</div>
                                    <div v-if="i+1<pre_owner.length">
                                        使用时间：{{time[i+1]-time[i]}}
                                    </div>
                                </div>
                            <!--</a-col>-->
                        </div>
                    </a-form-item>
                </a-form>
            </a-col>
        </a-row>
    </a-col>
</template>

<script>
    import { web3,ProductListContract,saveImageToIpfs,ipfsPrefix} from '../config'
    // const BigNumber = require('bignumber.js')
    export default {
        name: "hostdetail",
        data(){
            return {
                id: 0,
                showAll:false,
                account:'',
                name:'',
                content:'',
                img:'',
                price:0,
                sell_price:0,
                role:0,
                secInfo:[],
                pre_owner:[],
                pre_price:[],
                time:[],
                secInfo_l:0
            }
        },
        created () {
            this.init()
            //console.log()
        },
        methods:{
            async init(){
                const [account] = await web3.eth.getAccounts()
                console.log(this.$route.path)
                this.id = parseInt(this.$route.path.slice(13))//需要修改
                // const contract = getProductContract(this.address)
                const detail = await ProductListContract.methods.getSecDetail(this.id).call({from:account})
                console.log("detail"+detail)
                let [name,content,price,img,role] = Object.values(detail)
                this.account = account,
                    this.name = name,
                    this.content = content,
                    this.role = role;
                    this.price = web3.utils.fromWei(price)
            },
            sec_buy: async function (){
                //console.log("this.buycount"+this.buycount)
                // const bg = new BigNumber(web3.utils.toWei(this.price))
                console.log("类别ID"+this.id)
                window.web3.currentProvider.enable()
                let time = Date.now();
                time = parseInt(time/1000/60/60);//先处理成小时
                await ProductListContract.methods.sec_buy(this.id,time)
                    .send({
                        from:this.account,
                        value:web3.utils.toWei(this.price),
                        gas:'6000000'
                    })
                this.init()
            },
            getInformation:async function(){
                const secInfo = await ProductListContract.methods.getSecInfo(this.id).call({from:this.account})
                this.secInfo = secInfo
                console.log("secInfo"+typeof(secInfo))
                const [pre_owner, pre_price,time] = Object.values(secInfo)
                this.pre_owner = pre_owner
                this.pre_price = pre_price
                this.time = time
                console.log("pre1"+pre_owner,"pre2"+pre_price,"pre3"+time)
                // for(let i =0 ;i<pre_owner.length;i++){
                //     // this.pre_owner[i] = pre_owner[i]
                //     this.pre_price[i] = pre_price[i]
                //     this.time[i] = time[i]
                //     this.secInfo_l = this.secInfo_l + 1
                // }
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
                await ProductListContract.methods.sec_sell(this.id,sell_price,this.img)
                    .send({
                        from:this.account,
                        gas:'6000000'
                    })
                this.init()
            }
        },
        activated(){
            this.getInformation()
        }
    }
</script>

<style scoped>

</style>