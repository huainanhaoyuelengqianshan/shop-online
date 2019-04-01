<template>
    <div>
        <a-row justify='center' type='flex'>
            <a-col :span="20">
            <div v-for="(item,index) of comments">
                <a-comment
                    :key="item.content"
                    :content="item.content"
                    avatar="https://zos.alipayobjects.com/rmsportal/ODTLcjxAfvqbxHnVXCYX.png"
                    >
                        <!--<div v-for="ans of item.answers">-->
                        <!--<a-comment-->
                                <!--:key=ans.text-->
                                <!--:content=ans.text-->
                        <!--&gt;-->
                        <!--</a-comment>-->
                        <!--</div>-->
            </a-comment>
            </div>
            <a-form @submit="handleSubmit" style="marginTop:'20px'">
                <a-form-item label='撰写评论'>
                    <a-textarea
                            rows="6"
                            :value="content"
                            name='content'
                            v-model="content"></a-textarea >
                </a-form-item>
                <a-form-item>
                    <a-button type='primary' html-type="submit">提交评论</a-button>
                </a-form-item>
            </a-form>
            <a-modal
                    title="回复"
                    :visible="showModal"
                    @ok="handleOk"
                    @cancel="handleCancel"
            >
                <a-input value="answer" v-model="answer"></a-input>

            </a-modal>

            </a-col>

        </a-row>
    </div>
</template>

<script>
    import {notification,message} from 'ant-design-vue'
    import {web3,saveJsonOnIpfs,getProductContract,readJsonFromIpfs} from '../config'
    export default {
        name: "comments",
        data () {
            return {
                ansIndex:0,
                comments:[],
                account:'',
                answer:'',
                showModal:false,
                content:'',
                address:''
            }
        },
        created () {
            this.init()
        },
        methods:{
            async init () {
                window.web3.currentProvider.enable()
                this.address = this.$route.path.slice(8)
                let [account] = await web3.eth.getAccounts()
                const contract = getProductContract(this.address)
                const coms = await contract.methods.getComment().call()
                //console.log(coms)
                let ret = []
                for(let i=0;i<coms.length;i+=2){
                    ret.push(readJsonFromIpfs(coms[i],coms[i+1]))
                }
                const comments = await Promise.all(ret)
                //console.log(questions)
                this.account = account
                this.comments = comments
            },
            showInfoModal(i){
                    this.ansIndex = i,
                    this.showModal = true
            },
            handleSubmit: async function (e){
                e.preventDefault()
                // 1. 数据转为json
                const obj = {
                    content:this.content,
                }
                const hide = message.loading('评论上传中',0)
                // 2. json存储ipfs
                const hash = await saveJsonOnIpfs(obj)
                // 3. ipfs哈希上链
                const hash1 = hash.slice(0,23)
                const hash2 = hash.slice(23)

                const contract = getProductContract(this.address)
                await contract.methods.createComment(
                    web3.utils.asciiToHex(hash1),
                    web3.utils.asciiToHex(hash2))
                    .send({
                    from:this.account,
                    gas:'6000000'
                })

                    this.content = ''
                hide()
                this.init()
            },
            handleOk: async function(e){
                const item = this.comments[this.ansIndex]
                item.answers.push({
                    text:this.answer
                })
                const hash = await saveJsonOnIpfs(item)
                const hash1 = web3.utils.asciiToHex(hash.slice(0,23))
                const hash2 = web3.utils.asciiToHex(hash.slice(23))
                const contract = getProductContract(this.address)
                await contract.methods.updateComment(this.ansIndex,hash1,hash2)
                    .send({
                        from:this.account,
                        gas:'5000000'
                    })
                this.init()
                    this.showModal = false,
                    this.answer = ''
            },
            handleCancel :function (e){
                    this.showModal = false,
                    this.answer = ''
            }
        }
    }
</script>

<style scoped>

</style>