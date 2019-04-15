//文件模块
const fs = require('fs')//node模块

const path = require('path')
const solc = require('solc')

const constractPath_shop = path.resolve(__dirname,'../contracts/shop.sol')//这样即可在任意地方执行compile.js
//获取合约文件内容
const constractPath_user = path.resolve(__dirname,'../contracts/user.sol')
const source_shop = fs.readFileSync(constractPath_shop,'utf-8')
const source_user = fs.readFileSync(constractPath_user,'utf-8')
//编译
const ret_shop = solc.compile(source_shop)
const ret_user = solc.compile(source_user)
//console.log(ret)
if(Array.isArray(ret_shop.errors) && ret_shop.errors.length>0){
    console.log(ret_shop.errors[0])
} else {
    Object.keys(ret_shop.contracts).forEach(name=>{
        const contractName_shop = name.slice(1)
        const filePath = path.resolve(__dirname, `../src/compiled/${contractName_shop}.json`)
        fs.writeFileSync(filePath, JSON.stringify(ret_shop.contracts[name]))
        console.log(`${filePath} success`)
    })
}
if(Array.isArray(ret_user.errors) && ret_user.errors.length>0){
    console.log(ret_user.errors[0])
} else {
    Object.keys(ret_user.contracts).forEach(name=>{
        const contractName_user = name.slice(1)
        const filePath = path.resolve(__dirname, `../src/compiled/${contractName_user}.json`)
        fs.writeFileSync(filePath, JSON.stringify(ret_user.contracts[name]))
        console.log(`${filePath} success`)
    })
}


