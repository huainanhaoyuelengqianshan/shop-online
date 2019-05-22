const path = require('path')
const assert = require('assert')
const Web3 = require('web3')
const ganache = require('ganache-cli')
const BigNumber = require('bignumber.js')
const web3 = new Web3(ganache.provider())
// 引入合约的json
const ProductList = require(path.resolve(__dirname,'../src/compiled/ProductList.json'))
const User = require(path.resolve(__dirname,'../src/compiled/user.json'))

// 定义几个全局变量，所有测试都需要
let accounts
// 实例
let productList
let user

describe('测试',()=>{
    before(async ()=>{
        // 测试前的数据初始化
        accounts = await web3.eth.getAccounts()
        // console.log(accounts)
        // 1. 虚拟部署一个合约
        productList = await new web3.eth.Contract(JSON.parse(ProductList.interface))
            .deploy({data:ProductList.bytecode})
            .send({
                // 最后一个是创建者
                from:accounts[9],
                gas:'5000000'
            })
    })
    it('合约部署成功',()=>{
        assert.ok(productList.options.address)
    })
    it('测试添加商品',async()=>{
        const oldproductlist = await productList.methods.getproduct().call()
        assert.equal(oldproductlist.length,0)
        await productList.methods.createproduct(
            '电脑',
            "戴尔",
            web3.utils.toWei('0.3'),
            "图片的hash",
            2,
            10,
            1
        )
            .send({
                from:accounts[0],
                gas:'3000000'
            })
        const productlist = await productList.methods.getproduct().call()
        assert.equal(productlist.length,1)
        const balance = web3.eth.getBalance(accounts[2])
        console.log(balance)
    })
    // it('测试购买商品',async()=>{
    //     await productList.methods.buy(
    //         0,
    //         1,
    //         10
    //     ).send({
    //         from:accounts[2],
    //         value:web3.utils.toWei('0.3')
    //     })
    //     const ownerproductlist = await productList.methods.getProductsByOwner().call({from:accounts[1]})
    //     assert.equal(ownerproductlist.length,1)
    //     console.log(ownerproductlist)
    // })
})