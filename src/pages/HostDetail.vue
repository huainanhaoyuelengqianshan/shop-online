<template>
    <div>
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
                        <a-button type='primary' htmlType="submit">卖出</a-button>
                    </a-form-item>
                </a-form>
            </a-col>
        </a-row>
    </div>
</template>

<script>
    import { web3,ProductListContract,saveImageToIpfs,ipfsPrefix} from '../config'
    // const BigNumber = require('bignumber.js')
    export default {
        name: "hostdetail",
        data(){
            return {
                id: 0,
                showAll:true,
                account:'',
                name:'',
                content:'',
                img:'',
                price:0,
                sell_price:0
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
                let [name,content,price,img,productindex] = Object.values(detail)
                this.account = account,
                    this.name = name,
                    this.content = content,
                    //this.img = img,
                    this.price = web3.utils.fromWei(price)
            },

            handleUpload:async function(file){
                const hash = await saveImageToIpfs(file)
                this.img = hash
                this.init()
            },
            handleSubmit: async function(e){
                e.preventDefault()
                window.web3.currentProvider.enable()
                this.sell_price = web3.utils.toWei(this.sell_price)
                await ProductListContract.methods.sec_sell(this.id,this.sell_price,this.img)
                    .send({
                        from:this.account,
                        gas:'6000000'
                    })
                this.init()
            }


        }
    }
</script>

<style scoped>

</style>