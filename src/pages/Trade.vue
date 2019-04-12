<template>
    <div>
        <a-row style="marginTop:'30px'" :gutter="16">
            <a-col :span="20">
                <a-switch @change='onChangeSwitch' checkedChildren="全部" unCheckedChildren="已上线" defaultChecked></a-switch>
            </a-col>
            <div v-for="(detail,i) of detailList" :key="i">
                <a-col key="img" :span="6">
                    <div class="content">
                        <p>
                            <span>{{name[i]}}</span>
                        </p>
                        <img class="item" :src="imgsrc[i]" alt=""/>

                        <div class="center">
                            <a-button type='primary' block style="marginBottom:'10px'">
                                <router-link :to="'/host/detail/'+idList[i]">
                                    查看详情
                                </router-link>
                            </a-button>

                            <a-button v-if="isCeo" @click="remove(i)" type='primary' block>删除</a-button>

                        </div>
                    </div>
                </a-col>
            </div>
        </a-row>
    </div>
</template>

<script>
    import {ipfsPrefix,ProductListContract,web3} from '../config'
    export default {
        name: "trade",
        data () {
            return {
                detailList:[],
                idList:[],
                id:[],
                account:'',
                isCeo:false,
                showAll:true,
                name:[],
                content:'',
                price:[],
                img:[],
                imgsrc:[]
            }
        },
        created () {
            this.init()
        },
        methods: {
            async init() {
                const [account] = await web3.eth.getAccounts()
                const isCeo = await ProductListContract.methods.isCeo().call({
                    from:account
                })
                const idList = await ProductListContract.methods.getSecProduct().call({
                    from:account
                })
                console.log("idList "+idList)

                const detailList = await Promise.all(
                    idList.map(id=>{
                        return ProductListContract.methods.getSecDetail(id).call({
                            from:account
                        })
                    })
                )
                //console.log("detail" + detailList)
                this.detailList = detailList
                this.idList = idList
                this.account = account
                this.isCeo = isCeo

                //console.log("到底是啥"+detailList)
                this.detailList.map((detail,i)=> {
                    // const id = this.idList[i]
                    const [name, content, price, img, productindex] = Object.values(detail)
                    // buyPrice = web3.utils.fromWei(price)
                    this.name[i] = name
                    this.content= content
                    this.price = price
                    this.img[i] = img
                    this.imgsrc[i] = `${ipfsPrefix}${this.img[i]}`
                    this.id[i] = idList[i]
                })

            },
            onChangeSwitch:function(v){
                this.showAll = v;
            },
            async remove(i){
                await ProductListContract.methods.remove_sec_product(i)
                    .send({
                        from:this.account,
                        gas:"5000000"
                    })
                this.init()
            }
        }
    }
</script>

<style scoped>
    img.item{
        height: 150px;
        width:auto;
    }
</style>