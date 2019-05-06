pragma solidity ^0.4.24;

contract user {
//    string public empty;
    //定义用户数据结构
    struct UserStruct {
        address userAddress;
        string username;
        uint time;
        uint index;
        string img;
        uint[5] predict;
    }
    //定义用户列表数据结构
    struct UserListStruct {
        address userAddress;
        uint index;
    }
    uint[5] public init = [0,0,0,0,0];
    uint randNonce = 0;
    address[] public userAddresses; //所有地址集合
    string[] private usernames; //所有用户名集合
    mapping(address => UserStruct) private userStruct; //账户个人信息
    mapping(string => UserListStruct) private userListStruct; //用户名映射地址
    //判断用户地址是否存在
    function isExitUserAddress() public constant returns(bool) {
        if (userAddresses.length == 0) return false;
        return (userAddresses[userStruct[msg.sender].index] == msg.sender);
    }
    function createRand() public returns(uint){
        bytes memory encode = abi.encodePacked(now, msg.sender, randNonce);
        uint nonce = uint(keccak256(encode)) % 100;
        randNonce++;
        return nonce;
    }
    //判断用户名是否存在
    function isExitUsername(string _username) public constant returns(bool) {
        if (usernames.length == 0) return false;
        bytes memory encode = abi.encodePacked(usernames[userListStruct[_username].index]);
        return (keccak256(encode) == keccak256(abi.encodePacked(_username)));
    }
    //根据用户名查找对于的address
    function findUserAddressByUsername(string _username) public constant returns (address) {
//        require(isExitUsername(_username));
        return userListStruct[_username].userAddress;
    }
    //创建用户信息
    function createUser(string _username) public returns (uint) {
        require(!isExitUserAddress()); //如果地址已存在则不允许再创建
        userAddresses.push(msg.sender); //地址集合push新地址
        userStruct[msg.sender] = UserStruct(msg.sender, _username, now, userAddresses.length - 1,'',init);
        usernames.push(_username); //用户名集合push新用户
        userListStruct[_username] = UserListStruct(msg.sender, usernames.length - 1); //用户所对应的地址集合
        return userAddresses.length - 1;
    }
    function updateUser(string _img) public {
//        require(isExitUserAddress());
        userStruct[msg.sender].img = _img;
    }
    //获取用户个人信息
    function findUser() public constant returns (address, string, uint, uint,string) {
//        require(isExitUserAddress());
        return (
        userStruct[msg.sender].userAddress,
        userStruct[msg.sender].username,
        userStruct[msg.sender].time,
        userStruct[msg.sender].index,
        userStruct[msg.sender].img
        );
    }
    function getPredict() public view returns(uint[5]){
        return (
            userStruct[msg.sender].predict
    );
    }
//    function verify( string hash, uint8 v, bytes32 r, bytes32 s) pure public returns(address) {
//
//        bytes32 prefixedHash = keccak256(abi.encodePacked(prefix, hash));
//        return ecrecover(prefixedHash, v, r, s);
//    }
}
