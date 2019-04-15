//部署合约到ropsten测试网络
const fs = require('fs')
const path = require('path')
const Web3 = require('web3')
const HDWalletProvider = require('truffle-hdwallet-provider')


const contractPath_shop = path.resolve(__dirname, '../src/compiled/ProductList.json')
const interface_shop = require(contractPath_shop).interface
const bytecode_shop = require(contractPath_shop).bytecode
const contractPath_user = path.resolve(__dirname, '../src/compiled/user.json')
const interface_user = require(contractPath_user).interface
const bytecode_user = require(contractPath_user).bytecode

const provider = new HDWalletProvider(
    "struggle area pull major luggage horn crop warrior giraffe clog aisle bomb",
    "https://ropsten.infura.io/v3/9495a1fc05a34c16a1cfaea665601144"
)
const web3 = new Web3(provider);

(async()=>{
    console.log('自执行')
    const accounts = await web3.eth.getAccounts();
    console.log('合约部署的账号：', accounts[0])
    // await
    console.time('合约部署消耗时间')
    console.log(typeof (interface))
    const result_shop = await new web3.eth.Contract(JSON.parse(interface_shop))
        .deploy({data: bytecode_shop})
        .send({
            from:accounts[0],
            gas:'5000000'
        })
    // var {interface, bytecode} = require(contractPath_user)
    const result_user = await new web3.eth.Contract(JSON.parse(interface_user))
        .deploy({data: bytecode_user})
        .send({
            from:accounts[0],
            gas:'5000000'
        })
    console.timeEnd('合约部署消耗时间')
    const contractAddress_shop = result_shop.options.address
    const contractAddress_user = result_user.options.address
    console.log('Productlist合约部署成功', contractAddress_shop)
    console.log('user合约部署成功', contractAddress_user)
    console.log('Productlist合约查看地址', `https://ropsten.etherscan.io/address/${contractAddress_shop}`)
    console.log('user合约查看地址', `https://ropsten.etherscan.io/address/${contractAddress_user}`)
    const addressFile_shop = path.resolve(__dirname,'../src/address_shop.js')
    const addressFile_user = path.resolve(__dirname,'../src/address_user.js')
    fs.writeFileSync(addressFile_shop, "export default "+JSON.stringify(contractAddress_shop))
    fs.writeFileSync(addressFile_user, "export default "+JSON.stringify(contractAddress_user))
    console.log("地址写入成功",addressFile_shop)
    console.log("地址写入成功",addressFile_user)
})()
