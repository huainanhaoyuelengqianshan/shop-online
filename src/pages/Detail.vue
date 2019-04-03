<template>
    <div>
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

                <a-form-item  label="已购买人数">
                    {{count}}
                </a-form-item>
                <a-form-item  label="身份">
                    <a-upload v-if="role == '0'" :beforeUpload="handleUpload" :showUploadList="false">
                        <a-button type='primary'>上传视频</a-button>
                    </a-upload>
                    <div v-if="role ==  '1'">已购买</div>
                    <div v-if="role ==  '2'">未购买</div>
                </a-form-item>
                <a-form-item  label="视频状态">
                <div v-if="video">
                    <video controls width='300px' src="videosrc"></video>
                </div>
                <div v-else>
                    等待商家上传
                </div>
                </a-form-item>
                <a-form-item  label="购买">
                    <a-button v-if="role === '2'" type='primary' @click="buy">
                        支付{{price}}ETH
                    </a-button>
                </a-form-item>
            </a-form>
            </a-col>
        </a-row>
        <com-ments :id="id"></com-ments>
    </div>
</template>

<script>
    import { web3,ProductListContract,saveImageToIpfs,ipfsPrefix} from '../config'
    import ComMents from './Comments'
    export default {
        name: "detail",
        components :{
          ComMents
        },
        data(){
            return {
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
                addcomment:false
            }
        },
        created () {
            this.init()
            //console.log()
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
                await ProductListContract.methods.buy(this.id)()
                    .send({
                        from:this.account,
                        value: web3.utils.toWei(this.price),
                        gas:'6000000'
                    })
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
            }
        }
    }
</script>

<style scoped>

</style>