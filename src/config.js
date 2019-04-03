import ipfsApi from 'ipfs-api'


import {notification,message} from 'ant-design-vue'
import Web3 from 'web3';
import ProductList from '../src/compiled/ProductList.json'
//import Product from '../src/compiled/Product.json'
import address from './address'
let ipfs = ipfsApi("ipfs.infura.io","5001",{"protocol":"https"})


// let ipfsPrefix = "https://ipfs.infura.io:5001/ipfs/"
let ipfsPrefix = "https://ipfs.infura.io:5001/api/v0/cat?arg="

let web3
if(window.web3){
    web3 = new Web3(window.web3.currentProvider)
}else{
    notification.error({
        message:'没有检测到以太坊插件',
        description:'请安装metaMask或者激活'
    })
    // alert('请安装或者激活metamask')
}
let ProductListContract = new web3.eth.Contract(JSON.parse(ProductList.interface),address)
// let getProductContract = (addr) => new web3.eth.Contract(JSON.parse(Product.interface),addr)
// 存储图片
function saveImageToIpfs(file){
    const hide = message.loading('上传中')
    return new Promise(function(resolve, reject){
        let reader = new FileReader()
        reader.readAsArrayBuffer(file)
        reader.onloadend = async ()=>{
            const buffer = Buffer.from(reader.result)
            const res = await ipfs.add(buffer)
            console.log(res)
            hide()
            resolve(res[0].hash)
        }
    })
}
function saveJsonOnIpfs(json){
    return new Promise(async(reslove,reject)=>{
        const buffer = Buffer.from(JSON.stringify(json))
        const ret = await ipfs.add(buffer)
        console.log(ret)
        reslove(ret[0].hash)
    })
}


function readJsonFromIpfs(hash1,hash2){

    return new Promise(async(reslove,reject)=>{
        const hash = web3.utils.hexToAscii(hash1)+web3.utils.hexToAscii(hash2)
        const ret = await ipfs.cat(hash)
        const res = new TextDecoder('utf-8').decode(ret)
        reslove(JSON.parse(res))
    })
}
export {
    ipfs,
    ipfsPrefix,
    saveImageToIpfs,
    web3,
    ProductListContract,
    // getProductContract,
    saveJsonOnIpfs,
    readJsonFromIpfs
}