pragma solidity ^0.4.24;

contract ProductList{
  address public ceo;
  uint public productIndex;
  uint[] public productids;
  bytes23[] public empty;
  mapping (uint => address) public productToOwner;//商品编号-持有者地址映射
  mapping (address => uint) ownerProductCount;//持有者-拥有数量映射

  constructor() public {
    ceo = msg.sender;
    productIndex = 0;
  }

  struct Product{
    uint productIndex;
    address  ceo;
    address  owner;
    //卖家可以上传视频
    string name;
    string content;
    uint price;
    string img;
    string video;
    uint count;
    bytes23[] comments;
    // 用户够买信息
    // mapping(address=>uint) users;
  }
  Product[] public products;
  function createproduct(string _name,string _content,uint _price,string _img,uint _count) public{
    uint id = products.push(Product(productIndex,ceo,msg.sender,_name, _content, _price, _img,'',_count,empty)) - 1;
    productToOwner[id] = msg.sender;
    productids.push(id);
    ownerProductCount[msg.sender]++;
    productIndex += 1;
  }
  // 获取商品所有信息
  function getproduct() public view returns(uint[]){
    return productids;
  }

  function removeproduct(uint _id) public{
    // 只有ceo能删除
    require(msg.sender == ceo);
    // 根据索引删除
    require(_id<products.length);

    uint len = products.length;
    for(uint i=_id;i<len-1;i++){
      products[i] = products[i+1];
    }
    delete products[len-1];
    products.length--;
  }
  function isCeo() public view returns(bool){
    return msg.sender==ceo;
  }

    function createComment(uint _id, bytes23 _hash1,bytes23 _hash2) public{
      products[_id].comments.push(_hash1);
      products[_id].comments.push(_hash2);
    }
    function getComment(uint _id) public view returns(bytes23[]){
      return products[_id].comments;
    }
    // 更新 比如有回复的时候
    function updateComment(uint _id,uint _index, bytes23 _hash1, bytes23 _hash2) public{
        products[_id].comments[_index*2] = _hash1;
        products[_id].comments[_index*2+1] = _hash2;
    }
    function removeComment(uint _id,uint _index) public{
        uint index = _index*2;
        uint len = products[_id].comments.length;
        for(uint i=index;i<len-2;i=i+2){
          products[_id].comments[i] = products[_id].comments[i+2];
          products[_id].comments[i+1] = products[_id].comments[i+3];
       }
        delete products[_id].comments[len-1];
        delete products[_id].comments[len-2];
        products[_id].comments.length = products[_id].comments.length-2;
   }

  function addVideo(uint _id,string _video) public{
    require(msg.sender== products[_id].owner);
    require(products[_id].count > 0);
    products[_id].video = _video;
  }
  // 购买
  function buy(uint _id) public payable{
    if(products[_id].count > 0){
      require(products[_id].price == msg.value);
      uint value = msg.value;
      // 分成
      ceo.transfer(value/100);
      products[_id].owner.transfer(value-value/100);
    //   products[_id].users[msg.sender] = msg.value;
      // 统计商品数量
      products[_id].count = products[_id].count - 1;
      productToOwner[_id] = msg.sender;
      ownerProductCount[msg.sender]++;
    }else{
      msg.sender.transfer(msg.value);
    }
  }
  // 获取详情
  function getDetail(uint _id) public view returns(string,string,uint,string,string,uint,uint){
    uint role;
    if(products[_id].owner==msg.sender){
      role = 0; //卖家
    // }else if(products[_id].users[msg.sender]>0){
    //   role = 1; // 已购买
    }else{
      role = 2; // 没买
    }
    return (
      products[_id].name,
      products[_id].content,
      products[_id].price,
      products[_id].img,
      products[_id].video,
      products[_id].count,
      role
    );
  }
  function getProductsByOwner(address _owner) external view returns(uint[]) {
    uint[] memory result = new uint[](ownerProductCount[_owner]);
    uint counter = 0;
    for (uint i = 0; i < products.length; i++) {
      if (productToOwner[i] == _owner) {
        result[counter] = i;
        counter++;
      }
    }
    return result;
  }
}
