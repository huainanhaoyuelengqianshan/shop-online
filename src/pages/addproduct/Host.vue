<template>
    <div>
        <div>
            <host-info></host-info>
        </div>
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
                                <router-link v-on:click.native="transid(i)" :to="'/host/detail/'+idList[i]">
                                    查看详情
                                </router-link>
                            </a-button>

                            <!--<a-button v-if="isCeo" @click="remove(id[i])" type='primary' block>删除</a-button>-->

                        </div>
                    </div>
                </a-col>
            </div>
        </a-row>
    </div>
</template>

<script>
    import {ipfsPrefix,ProductListContract,web3} from '../config'
    import eventBus  from './eventBus.js'
    import HostInfo from './HostInfo'
    export default {
        name: "host",
        components :{
            HostInfo
        },
        data () {
            return {
                detailList:[],
                idList:[],
                //id:[],
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
        methods: {
            async init() {
                // const [account] = await web3.eth.getAccounts()
                const idList = await ProductListContract.methods.getProductsByOwner().call({
                    from:this.$store.state.currentaccount
                })
                console.log("商品序列："+idList)
                const detailList = await Promise.all(
                    idList.map(id=>{
                        return ProductListContract.methods.getSecDetail(id).call({
                            from:this.$store.state.currentaccount
                        })
                    })
                )
                this.detailList = detailList
                this.idList = idList
                // this.account = account
                //console.log("到底是啥"+detailList)
                this.detailList.map((detail,i)=> {
                    // const id = this.idList[i]
                    const [name,content,price,img,productindex] = Object.values(detail)
                    // buyPrice = web3.utils.fromWei(price)
                    this.name[i] = name
                    this.content= content
                    this.price[i] = price
                    this.img[i] = img
                    this.imgsrc[i] = `${ipfsPrefix}${this.img[i]}`
                    //this.id[i] = `/detail/${idList[i]}`
                })

            },
            transid:function(i){
                eventBus.$emit('id_trans', this.idList[i])
            },
            onChangeSwitch:function(v){
                this.showAll = v;
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