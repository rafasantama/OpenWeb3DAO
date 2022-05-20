// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

contract CertiBits{  // defino que mi contrato se va a llamar Inbox
    uint public totalCertiBits;   // variable donde se almacena la información
    address owner;
    mapping (string => address[]) public hash2addressList;
    mapping (address => mapping(string => bool)) address2hashstate;
    constructor () {  // este es el metodo constructor donde     inicializo el contrato con un mensaje
        owner = msg.sender;
    }
    
    uint IDu;
    
    function isOwner() view private returns(bool) {
        return msg.sender == owner;    
    }
    
    modifier onlyOwner {
        require(isOwner(), "Only owner can do that!");
        _;
    }
    
    struct user {
        string name;
        string id;
        string email;
        address owner;
    }
    user[] private users;
    mapping (address => uint) pubkey2IDu;
    mapping (address => bool) public address2state;
    mapping (address => uint) signatures;
    function new_user(string memory _name, string memory _id, string memory _email, address _owner) public onlyOwner{
        users.push(user(_name,_id,_email,_owner));
        pubkey2IDu[_owner]=IDu;
        IDu+=1;
        address2state[_owner]=true;
    }
    function Certify(string memory _hash) public { // esta función permite reemplazar el mensaje almacenada en la variable message
        require(address2state[msg.sender],"Address not subscribed to the contract");
        require(!address2hashstate[msg.sender][_hash],"Address already signed these hash");
        require(signatures[msg.sender]>=1,"no balance");
        signatures[msg.sender]-=1;
        address2hashstate[msg.sender][_hash]=true;
        hash2addressList[_hash].push(msg.sender);
        totalCertiBits++;
    }
    function recharge(uint _value) public payable{
        require(_value>0,"recharge value must be positive");
        require(msg.value==1000000000000000000*_value,"pay  must be 1 Celo per signature");
        signatures[msg.sender]+=_value;
    }
    function validate_address_hash(address _address, string memory _hash) public view returns(string memory name_, string memory id_,string memory email__, address owner_ ) {
        require(address2hashstate[msg.sender][_hash]&&address2hashstate[_address][_hash],"need to share hash to see personal data");
        return(users[pubkey2IDu[_address]].name,users[pubkey2IDu[_address]].id,users[pubkey2IDu[_address]].email,users[pubkey2IDu[_address]].owner);
    }
}