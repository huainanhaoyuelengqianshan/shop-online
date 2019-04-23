<template>
    <div>
        <a-upload
                :beforeUpload="handleUpload"
                :showUploadList ="false"
        >
            <a-avatar height='100px' :src="avatar" alt=""/>
            <a-button type='primary'>更换头像</a-button>
        </a-upload>
    </div>
</template>

<script>
    import {notification,message} from 'ant-design-vue'
    import {saveImageToIpfs,ipfsPrefix,userContract,web3} from '../config.js'
    export default {
        name: "host-info",
        data(){
            return{
                avatar:''
            }
        },
        created () {
            this.init()
            //console.log()
        },
        methods:{
            init:async function(){
                const [account] = await web3.eth.getAccounts()
                const userInfo = await userContract.methods.findUser().call({from:account})
                let [userAddress, username, time, index,img] = Object.values(userInfo)
                console.log("img:"+img)
                console.log("userAddress:"+userAddress)
                console.log("username"+username)
                if(img === ''){
                    this.avatar = 'https://zos.alipayobjects.com/rmsportal/ODTLcjxAfvqbxHnVXCYX.png'
                }else{
                    this.avatar = `${ipfsPrefix}${img}`
                }
            },
            handleUpload: async function(file){
                const hash = await saveImageToIpfs(file)
                //console.log(hash)
                // 3. ipfs哈希上链
                console.log("img: "+this.avatar)
                const [account] = await web3.eth.getAccounts()
                //return false
                const hide = message.loading('头像上传中',0)
                await userContract.methods.updateUser(hash)
                    .send({
                        from:account
                    })
                this.avatar = `${ipfsPrefix}${hash}`
                hide()
            }
        }
    }
</script>

<style scoped>

</style>