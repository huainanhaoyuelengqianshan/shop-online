//文件模块
const fs = require('fs')//node模块

const path = require('path')
const solc = require('solc')

const constractPath = path.resolve(__dirname,'../contracts/shop.sol')//这样即可在任意地方执行compile.js
//获取合约文件内容
const source = fs.readFileSync(constractPath,'utf-8')
//编译
const ret = solc.compile(source)
//console.log(ret)
if(Array.isArray(ret.errors) && ret.errors.length>0){
    console.log(ret.errors[0])
} else {
    Object.keys(ret.contracts).forEach(name=>{
        const contractName = name.slice(1)
        const filePath = path.resolve(__dirname, `../src/compiled/${contractName}.json`)
        fs.writeFileSync(filePath, JSON.stringify(ret.contracts[name]))
    console.log(`${filePath} success`)
})
}

