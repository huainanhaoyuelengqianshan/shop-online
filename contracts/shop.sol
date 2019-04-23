pragma solidity ^0.4.24;

contract ProductList{
  address public ceo;
  uint public productIndex;
  uint public id;
  uint sec_count;
  uint[] public productsids;
  uint[] public Productids;
  bytes23[] public empty;
  address[] public p_owner;
  uint[] public p_price;
  uint[] public p_time;
  mapping (uint => address) public ProductToOwner;//商品类编号-持有者地址映射
//  mapping (uint => address) public producttoowner;//商品编号-持有者地址映射
  mapping (address => uint) ownerProductCount;//持有者-拥有商品类数量映射

  constructor() public {
    ceo = msg.sender;
    productIndex = 0;
    id = 0;
    sec_count = 0;
  }

  struct Product{
    uint productIndex;
    address  owner;
    //卖家可以上传视频
    string name;
    string content;
    uint price;
    string img;
    string video;
    uint count;
    bytes23[] comments;
    uint time;
    // 用户够买信息
    // mapping(address=>uint) users;
  }
  struct sec_Product{
    uint productIndex;
    uint id;
    address owner;
    uint price;
    string img;
    bool sell;
    address[] pre_owner;
    uint[] pre_price;
    uint[] time;
  }
  Product[] public products;
  sec_Product[] public sec_products;
  //商家添加商品
  function createproduct(string _name,string _content,uint _price,string _img,uint _count,uint _time) public{
    uint ID = products.push(Product(productIndex,msg.sender,_name, _content, _price, _img,'',_count,empty,_time)) - 1;
    ProductToOwner[ID] = msg.sender;
    productsids.push(ID);
    //ownerProductCount[msg.sender]++;
    productIndex += 1;
  }
  // 首次购买
  function buy(uint _productIndex,uint _count,uint _time) public payable{
    if(products[_productIndex].count - _count >= 0){
      require(products[_productIndex].price * _count == msg.value);
      uint value = msg.value;
      // 分成
      ceo.transfer(value/100);
      products[_productIndex].owner.transfer(value-value/100);
      // 统计商品数量
      products[_productIndex].count = products[_productIndex].count - _count;
      for(uint i = 0; i < _count; i++) {
        uint ID = sec_products.push(sec_Product(_productIndex,id,msg.sender,products[_productIndex].price,products[_productIndex].img,false,p_owner,p_price,p_time)) - 1;
        address c_owner = products[sec_products[id].productIndex].owner;
        uint c_time = products[sec_products[id].productIndex].time;
        uint c_price = products[sec_products[id].productIndex].price;
        sec_products[id].pre_owner.push(c_owner);
        sec_products[id].pre_owner.push(msg.sender);
        sec_products[id].time.push(c_time);
        sec_products[id].time.push(_time);
        sec_products[id].pre_price.push(0);
        sec_products[id].pre_price.push(c_price);
//        producttoowner[ID] = msg.sender;
        Productids.push(ID);
        id = id + 1;
        ownerProductCount[msg.sender]++;
      }
    }else{
      msg.sender.transfer(msg.value);
    }
  }
  //二手交易卖出
  function sec_sell(uint _id,uint _sec_price,string _sec_img) public {
    sec_products[_id].sell = true;
    sec_count++;
    sec_products[_id].price = _sec_price;
    sec_products[_id].img = _sec_img;
  }
  //二手交易买入
  function sec_buy(uint _id,uint _time) public payable {
    if(sec_products[_id].sell == true){
      require(sec_products[_id].price == msg.value);
      uint value = msg.value;
      // 分成
      ceo.transfer(value/100);
      sec_products[_id].owner.transfer(value-value/100);
      //标记为售出，从二手市场移除
      sec_products[_id].sell = false;
      //商品所属标记更改
      sec_products[_id].owner = msg.sender;
//      //全部商品标号与所属对应关系
//      producttoowner[_id] = msg.sender;
      ownerProductCount[msg.sender]++;
      uint pr_price = sec_products[_id].price;
      sec_products[_id].pre_owner.push(msg.sender);
      sec_products[_id].pre_price.push(pr_price);
      sec_products[_id].time.push(_time);
    } else {
      msg.sender.transfer(msg.value);
    }
  }
  // 获取所有商品信息
  function getproduct() public view returns(uint[]){
    return productsids;
  }
  function getSecProduct() public view returns(uint[]){
    uint[] memory result = new uint[](sec_count);
    uint counter = 0;
    for (uint i = 0; i < sec_products.length; i++) {
      if (sec_products[i].sell == true) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
  // 获取二手商品详情
  function getSecDetail(uint _id) public view returns(string, string,uint,string,uint){
    uint role;
    if(sec_products[_id].owner==msg.sender){
      role = 0; //卖家自己
    }else{
      role = 2; // 买家
    }
    uint productindex = sec_products[_id].productIndex;
    return (
    products[productindex].name,
    products[productindex].content,
    sec_products[_id].price,
    sec_products[_id].img,
    role
    );
  }
  function getSecInfo(uint _id) public view returns(address[],uint[],uint[]){
    return (
    sec_products[_id].pre_owner,
    sec_products[_id].pre_price,
    sec_products[_id].time
    );
  }
  // 获取详情
  function getDetail(uint _productIndex) public view returns(string,string,uint,string,string,uint,uint){
    uint role;
    if(products[_productIndex].owner==msg.sender){
      role = 0; //卖家自己
    }else{
      role = 2; // 买家
    }
    return (
    products[_productIndex].name,
    products[_productIndex].content,
    products[_productIndex].price,
    products[_productIndex].img,
    products[_productIndex].video,
    products[_productIndex].count,
    role
    );
  }
  function getInfo(uint _productIndex) public view returns(uint){
    return (
    products[_productIndex].time
    );
  }
  //删除上架商品
  function removeproduct(uint _productIndex) public{
    // 只有ceo能删除
    require(msg.sender == ceo);
    // 根据索引删除
    require(_productIndex<products.length);
    uint len = products.length;
    for(uint i=_productIndex;i<len-1;i++){
      products[i] = products[i+1];
    }
    delete products[len-1];
    products.length--;
  }
  //删除二手商品
  function remove_sec_product(uint _id) public{
    // 只有ceo能删除
    require(msg.sender == ceo);
    // 根据索引删除
    require(_id<sec_products.length);
    uint len = sec_products.length;
    for(uint i=_id;i<len-1;i++){
      sec_products[i] = sec_products[i+1];
    }
    delete sec_products[len-1];
    sec_products.length--;
  }
  function isCeo() public view returns(bool){
    return msg.sender==ceo;
  }
  function createComment(uint _productIndex, bytes23 _hash1,bytes23 _hash2) public{
    products[_productIndex].comments.push(_hash1);
    products[_productIndex].comments.push(_hash2);
  }
  function getComment(uint _productIndex) public view returns(bytes23[]){
    return products[_productIndex].comments;
  }
  // 更新 比如有回复的时候
  function updateComment(uint _productIndex,uint _index, bytes23 _hash1, bytes23 _hash2) public{
    products[_productIndex].comments[_index*2] = _hash1;
    products[_productIndex].comments[_index*2+1] = _hash2;
  }
  function removeComment(uint _productIndex,uint _index) public{
    uint index = _index*2;
    uint len = products[_productIndex].comments.length;
    for(uint i=index;i<len-2;i=i+2){
      products[_productIndex].comments[i] = products[_productIndex].comments[i+2];
      products[_productIndex].comments[i+1] = products[_productIndex].comments[i+3];
    }
    delete products[_productIndex].comments[len-1];
    delete products[_productIndex].comments[len-2];
    products[_productIndex].comments.length = products[_productIndex].comments.length-2;
  }

  function addVideo(uint _productIndex,string _video) public{
    require(msg.sender== products[_productIndex].owner);
    require(products[_productIndex].count > 0);
    products[_productIndex].video = _video;
  }
  //  function addImg(uint _id,string _img) public{
  //    require(msg.sender== sec_products[_id].owner);
  //    sec_products[_id].img = _img;
  //  }


  function getProductsByOwner() public view returns(uint[]) {
    uint result_count = ownerProductCount[msg.sender];
    uint[] memory result = new uint[](result_count);
    uint counter = 0;
    for (uint i = 0; i < sec_products.length; i++) {
      if (sec_products[i].owner == msg.sender) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }

}
