<template>
    <div v-if="reload">
        <a-row type='flex' justify="center" style="marginTop:'30px'">
            <a-col :span="20">
            <a-form>
                <a-form-item  label="商品名">
                    {{name}}
                </a-form-item>
                <a-form-item  label="商品简介">
                    {{content}}
                </a-form-item>
                <a-form-item  label="价格">
                    {{price}} ETH
                </a-form-item>
                <a-form-item  v-if="role ==  '0'" label="供应数量">
                    {{count}}
                </a-form-item>
                <a-form-item  v-if="role ==  '2'" label="可购买数量">
                    {{count}}
                </a-form-item>
                <a-form-item>
                    <div v-if="role === '0'">身份：商家</div>
                    <a-upload v-if="role === '0'" :beforeUpload="handleUpload" :showUploadList="false">
                        <a-button type='primary'>上传视频</a-button>
                    </a-upload>
                    <!--<div v-if="role ===  '1'">身份：买家<br></br>已购买</div>-->
                    <div v-if="role ===  '2'">身份：买家</div>
                </a-form-item>
                <a-form-item  label="视频状态">
                <div v-if="video">
                    <video controls width='300px' src="videosrc"></video>
                </div>
                <div v-else>
                    等待商家上传
                </div>
                </a-form-item>
                <a-form-item  v-if="role === '2'" label="购买数量">
                    <a-input name='buycount' v-model="buycount" />
                </a-form-item>
                <a-form-item  v-if="role ===  '2'" label="购买">
                    <a-button v-if="role === '2'" type='primary' @click="buy">
                        支付{{price*buycount}}ETH
                    </a-button>
                </a-form-item>
            </a-form>
            </a-col>
        </a-row>

    </div>
</template>

<script>
    import { web3,ProductListContract,saveImageToIpfs,ipfsPrefix} from '../config'
    import {notification,message} from 'ant-design-vue'
    import ComMents from './Comments'
    const BigNumber = require('bignumber.js')
    export default {
        name: "detail",
        components :{
          ComMents
        },
        data(){
            return {
                buycount:0,
                id: 0,
                showAll:true,
                account:'',
                name:'',
                content:'',
                img:'',
                video:'',
                count:0,
                role:0,
                price:0,
                reload:true
            }
        },
        created () {
            this.init()
            //console.log()
        },
        watch:{
            async getAddressChange(val){
                const detail = await ProductListContract.methods.getDetail(this.id).call({from:this.$store.state.currentaccount})
                let [name, content, price, img, video, count, role] = Object.values(detail)
                    this.role = role
            }
        },
        methods:{
            async init(){
                const [account] = await web3.eth.getAccounts()
                this.id = parseInt(this.$route.path.slice(8))
                // const contract = getProductContract(this.address)
                const detail = await ProductListContract.methods.getDetail(this.id).call({from:account})
                let [name, content, price, img, video, count, role] = Object.values(detail)
                this.account = account,
                this.name = name,
                this.content = content,
                this.img = img,
                this.video = video,
                this.count = count,
                this.role = role,
                this.price = web3.utils.fromWei(price)
            },
            buy: async function (){
                //console.log("this.buycount"+this.buycount)
                // const bg = new BigNumber(web3.utils.toWei(this.price))
                console.log("类别ID"+this.id)
                fetch("http://155.138.165.114:3001/users/user_data",{
                    method:'POST',
                    headers:{
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    },
                    body:JSON.stringify({
                        account:this.account,
                        id:this.id
                    })
                })
                await web3.currentProvider.enable()
                let time = Date.now();
                time = parseInt(time/1000/60/60);//先处理成小时
                const hide = message.loading('交易上链中',0)
                await ProductListContract.methods.buy(this.id,this.buycount,time)
                    .send({
                        from:this.$store.state.currentaccount,
                        value:new BigNumber(web3.utils.toWei(this.price)*this.buycount),
                        gas:'6000000'
                    })
                hide()
                //前端购物数据保存到后端

                    // .then(res => res.json())
                    // .then(data => {
                    //     console.log(data)
                    // })
                    // .catch(function (e) {
                    //     console.log('oops! error:', e.message)
                    // })

                this.init()
            },
            handleUpload:async function(file){
                const hash = await saveImageToIpfs(file)
                await ProductListContract.methods.addVideo(this.id,hash).send({
                    from:this.account,
                    gas:'6000000'
                })
                this.init()
            }
        },
        computed:{
            videosrc: function () {
                var videosrc = '';
                videosrc = `${ipfsPrefix}${this.video}`;
                return videosrc;
            },
            getAddressChange:function(){
                console.log("检测到账户变化")
                return this.$store.state.currentuser
            }
        }
    }
</script>

<style scoped>

</style>