pragma solidity ^0.4.24;

contract ProductList{
  address public ceo;
  address[] public products;
  bytes23[] public comments;
  constructor() public {
    ceo = msg.sender;
  }
  // 新建
  function createComment(bytes23 _hash1,bytes23 _hash2) public{
    comments.push(_hash1);
    comments.push(_hash2);
  }
  function getComment() public view returns(bytes23[]){
    return comments;
  }
  // 更新 比如有回复的时候
  function updateComment(uint _index, bytes23 _hash1, bytes23 _hash2) public{
      comments[_index*2] = _hash1;
      comments[_index*2+1] = _hash2;
  }
  function removeComment(uint _index) public{
      uint index = _index*2;
      uint len = comments.length;
      for(uint i=index;i<len-2;i=i+2){
        comments[i] = comments[i+2];
        comments[i+1] = comments[i+3];
     }
      delete comments[len-1];
      delete comments[len-2];
      comments.length = comments.length-2;
 }
  function createproduct(string _name,string _content,uint _price,string _img) public{
    address newproduct = new Product(ceo,msg.sender, _name, _content, _price, _img);
    products.push(newproduct);
  }
  // 获取课程所有地址
  function getproduct() public view returns(address[]){
    return products;
  }

  function removeproduct(uint _index) public{
    // 只有ceo能删除
    require(msg.sender == ceo);
    // 根据索引删除
    require(_index<products.length);

    uint len = products.length;
    for(uint i=_index;i<len-1;i++){
      products[i] = products[i+1];
    }
    delete products[len-1];
    products.length--;
  }
  function isCeo() public view returns(bool){
    return msg.sender==ceo;
  }
}

contract Product{
  address public ceo;
  address public owner;
  //卖家可以上传视频
  string public name;
  string public content;
  uint public price;
  string public img;
  string public video;
  //bool public isSpare;
  uint public count;
  // 用户够买信息
  mapping(address=>uint) public users;
  constructor(address _ceo, address _owner,string _name,string _content,uint _price,string _img) public{
    ceo = _ceo;
    owner = _owner;
    name = _name;
    content = _content;
    price = _price;
    img = _img;
    video = '';
    count = 0;
    //isSpare = true;
  }
  function addVideo(string _video) public{
    require(msg.sender==owner);
    require(count > 0);
    video = _video;
  }
  // 购买
  function buy() public payable{
    if(count > 0){
      require(price == msg.value);
      uint value = msg.value;
      // 分成
      ceo.transfer(value/100);
      owner.transfer(value-value/100);
      users[msg.sender] = msg.value;
      // 统计人数
      count += 1;
    }else{
      msg.sender.transfer(msg.value);
    }
  }
  // 获取详情
  function getDetail() public view returns(string,string,uint,string,string,uint,uint){
    uint role;
    if(owner==msg.sender){
      role = 0; //卖家
    }else if(users[msg.sender]>0){
      role = 1; // 已购买
    }else{
      role = 2; // 没买
    }
    return (
      name,
      content,
      price,
      img,
      video,
      count,
      role
    );
  }
}