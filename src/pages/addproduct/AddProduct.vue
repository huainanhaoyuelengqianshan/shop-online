<template>
    <div>
        <a-row
                type='flex'
                justify='center'
                style="{ marginTop:'30px' }"
        >
            <a-col :span="20">
            <a-form @submit="handleSubmit">
                <a-form-item label="商品名">
                    <a-input name='name' v-model="name" />
                </a-form-item>
                <a-form-item label="商品详情">
                    <a-textarea :rows="4" name='content' v-model="content" >
                    </a-textarea>
                </a-form-item>
                <a-form-item label="商品详情图">

                    <a-upload
                            :beforeUpload="handleUpload"
                            :showUploadList ="false"
                    >
                        <img v-if ="img" height='100px' :src="imgsrc" alt=""/>
                        <a-button v-else type='primary'>上传图片</a-button>
                    </a-upload>
                </a-form-item>
                <a-form-item label="上线价格">
                    <a-input name='price' v-model="price" />
                </a-form-item>
                <a-form-item label="库存量">
                    <a-input name='count' v-model="count" />
                </a-form-item>
                <a-form-item>
                    <a-button type='primary' htmlType="submit">添加商品</a-button>
                </a-form-item>
            </a-form>
            </a-col>
        </a-row>
    </div>
</template>

<script>
    import {notification,message} from 'ant-design-vue'
    import {saveImageToIpfs,ipfsPrefix,ProductListContract,web3} from '../../config.js'
    export default {
        name: "add-product",
        data(){
            return {
                toindex:false,
                name:'',
                content:'',
                img:'',
                price:'',
                count:0
            }
        },
        methods:{
            handleSubmit: async function(e){
                e.preventDefault()
                const [account] = await web3.eth.getAccounts()
                let time = Date.now();
                time = parseInt(time/1000/60/60);//先处理成小时
                const arr = [
                    this.name,
                    this.content,
                    web3.utils.toWei(this.price),
                    this.img,
                    this.count,
                    time
                ]
                window.web3.currentProvider.enable()
                const hide = message.loading('商品信息上链中',0)
                await ProductListContract.methods.createproduct(...arr)
                    .send({
                        from:account
                    })
                hide()
               this.toindex = true
            },
            handleUpload: async function(file){
                const hash = await saveImageToIpfs(file)
                //console.log(hash)
                this.img = hash
                console.log("img: "+this.img)
                //return false
            }
            // onChange = (e)=>{
            //     this.setState({
            //         [e.target.name]:e.target.value
            //     })
            // }
        },
        computed:{
          imgsrc: function () {
              var imgsrc = '';
              imgsrc = `${ipfsPrefix}${this.img}`;
              return imgsrc;
          }
        }
    }
</script>

<style scoped>

</style>