<template>
    <div>
        <div>
            <a-button @click="reccommendByuser">基于用户的推荐</a-button>
        </div>
        <a-row style="marginTop:'30px'" :gutter="16">
            <div v-for="(detail,i) of recommendList2" :key="i">
                <a-col key="img" :span="6">
                    <div class="content">
                        <p>
                            <span>{{name[i]}}</span>
                        </p>
                        <img class="item" :src="imgsrc[i]" alt=""/>

                        <div class="center">
                            <p>
                                剩余{{count[i]}}件
                            </p>
                            <a-button type='primary' block style="marginBottom:'10px'">
                                <router-link :to="'/detail/'+idList2[i]">
                                    查看详情
                                </router-link>
                            </a-button>
                        </div>
                    </div>
                </a-col>
            </div>
        </a-row>
        <a-row style="marginTop:'30px'" :gutter="16">
            <div class="recommendList" v-for="(single,i) of reccommendList" :key="i">
                <a-col :span="6">
                    <div class="content">
                        <p>
                            <span class="title">{{single.title}}</span>
                        </p>
                        <img class="item" :src="single.img_URL" alt=""/>

                        <div class="center">
                            <p>
                                价格{{single.low_price}}
                            </p>
                        </div>
                        <div>
                            商品编号{{single.rank}}
                        </div>
                        <!--<h1>{{single.tag}}</h1>-->
                        <!--<h1>{{single.score}}</h1>-->
                    </div>
                </a-col>
            </div>
        </a-row>
    </div>
</template>

<script>
    import axios from 'axios'
    import {ipfsPrefix,ProductListContract,web3} from '../config'
    export default {
        name: "recommend",
        data() {
            return {
                username: '',
                reccommendList: [],
                recommendList2:[],
                name:[],
                tag:[],
                similar_id:[],
                content:'',
                price:[],
                img:[],
                video:'',
                count:[],
                imgsrc:[],
                idList2:[],
                idlist:[]
            }
        },
        mounted() {
            this.init()
            console.log("tag:"+this.tag)
        },
        activated(){
            this.init()
        },
        methods:{
            async init(){
                // const [account] = await web3.eth.getAccounts()
                // this.account = account
                const idList = await ProductListContract.methods.getProductsByOwner().call({
                    from:this.$store.state.currentaccount
                })
                var idlist = []
                for(var i=0;i<idList.length;i++){
                    if(idList[i]!=='0'){
                        var number_test = parseInt(idList[i])-1
                        idlist.push(number_test.toString())
                    }
                }
                console.log("更改后序列："+idlist)
                this.idlist = idlist
                const detailList = await Promise.all(
                    idlist.map(id=>{
                        return ProductListContract.methods.getSecDetail(id).call({
                            from:this.$store.state.currentaccount
                        })
                    })
                )
                // this.detailList = detailList
                detailList.map((detail,i)=> {
                    const [name,content,price,img,productindex,tag] = Object.values(detail)
                    // console.log("pre tag:"+this.tag)
                    this.tag[i] = tag
                    console.log("tag:"+this.tag)
                })
                fetch("http://155.138.165.114:3001/users/data",{
                    method:'POST',
                    headers:{
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    },
                    body:JSON.stringify({
                        account:this.$store.state.currentaccount,
                        tagList:this.tag
                    })
                })
                    .then(res => res.json())
                    .then(data => {
                        this.reccommendList = data.data
                        console.log(data.weight)
                    })
                    .catch(function (e) {
                        console.log('oops! error:', e.message)
                    })
            },
            reccommendByuser(){
                fetch("http://155.138.165.114:3001/users/data2",{
                    method:'POST',
                    headers:{
                        'Accept': 'application/json',
                        'Content-Type': 'application/json'
                    },
                    body:JSON.stringify({
                        account:this.$store.state.currentaccount,
                        tagList:this.tag
                    })
                })
                    .then(res => res.json())
                    .then(data => {
                        for(var item in data.count){
                            this.similar_id.push(parseInt(item))
                        }
                        this.reccommendByuser_child()
                        console.log("this.similar_id:"+this.similar_id)
                    })
                    .catch(function (e) {
                        console.log('oops! error:', e.message)
                    })
            },
            async reccommendByuser_child(){
                const recommendList2 = await Promise.all(
                    this.similar_id.map(id=>{
                        return ProductListContract.methods.getDetail(id).call({
                            from:this.$store.state.currentaccount
                        })
                    })
                )
                console.log("recommendList2:"+recommendList2)
                const idList2 = await ProductListContract.methods.getproduct().call({
                    from:this.$store.state.currentaccount
                })
                this.idList2 = idList2
                console.log("this.idList2:"+this.idList2)
                this.recommendList2 = recommendList2
                this.recommendList2.map((detail,i)=> {
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
                    console.log("图片地址"+this.imgsrc[i])
                })
            }
        }
    }
</script>

<style scoped>
    img.item{
        height: 200px;
        width:auto;
    }
    .content{
        height: 15 rem;
        margin-left: 1.5rem;
        margin-right: 1.5rem;
        margin-top: 3.5rem;
    }
    .title{
        height: 3rem;
        overflow: hidden;
        text-overflow: ellipsis;
        display: -webkit-box;
        -webkit-line-clamp: 2;
        -webkit-box-orient: vertical;
    }
</style>