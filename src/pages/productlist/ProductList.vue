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
                            <!--<span>-->
                            <!--{isOnline-->
                            <!--? <Badge count="已上线" style={{backgroundColor:"#52c41a"}}></Badge>-->
                            <!--: <Badge count="众筹中"></Badge>-->
                            <!--}-->
                            <!--</span>-->
                        </p>
                        <img class="item" :src="imgsrc[i]" alt=""/>

                        <div class="center">
                            <p>
                                已有{{count[i]}}人购买
                            </p>
                            <!--<p>-->
                            <!--{-->
                            <!--isOnline ? <Badge count={`上线价${price}ETH`} style={{backgroundColor:"#52c41a"}}></Badge>-->
                            <!--: <Badge count={`众筹价${fundingPrice}ETH`}></Badge>-->
                            <!--}-->
                            <!--</p>-->
                            <a-button type='primary' block style="marginBottom:'10px'">
                                <router-link :to="'/detail/'+addressList[i]">
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
    import {ipfsPrefix,ProductListContract,web3,getProductContract} from '../../config'
    export default {
        name: "product-list",
        data () {
            return {
                detailList:[],
                addressList:[],
                address:[],
                account:'',
                isCeo:false,
                showAll:true,
                name:[],
                content:'',
                price:[],
                img:[],
                video:'',
                count:[],
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
                //console.log('是不是ceo',isCeo)
                const addressList = await ProductListContract.methods.getproduct().call({
                    from:account
                })

                const detailList = await Promise.all(
                    addressList.map(address=>{
                        return getProductContract(address).methods.getDetail().call({
                            from:account
                        })
                    })
                )
                //console.log("detail" + detailList)
                this.detailList = detailList
                this.addressList = addressList
                this.account = account
                this.isCeo = isCeo

                //console.log("到底是啥"+detailList)
                this.detailList.map((detail,i)=> {
                    const address = this.addressList[i]
                    const [name, content, price, img, video, count, role] = Object.values(detail)
                    // buyPrice = web3.utils.fromWei(price)
                    this.name[i] = name
                    this.content= content
                    this.price = price
                    this.img[i] = img
                    this.video = video
                    this.count[i] = count
                    this.role = role
                    this.imgsrc[i] = `${ipfsPrefix}${this.img[i]}`
                    this.address[i] = `/detail/${addressList[i]}`
                })

            },
            onChangeSwitch:function(v){
                this.showAll = v;
            },
            async remove(i){
                await ProductListContract.methods.removeproduct(i)
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