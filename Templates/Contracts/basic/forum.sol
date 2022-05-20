// SPDX-License-Identifier: MIT

pragma solidity ^0.4.22;

contract Greeter {
    string greeting;
    address owner;
    address owner_message;
    uint public total_mensajes;

    modifier onlyOwner {
        require(isOwner(), "Only owner can do that!");
        _;
    }
    
    constructor(string _greeting) public {
        greeting = _greeting;
        owner = msg.sender;
    }
    
    struct log{
        string mensaje;
        address owner;
    }
    
    log[] public mensajes;
    

    function sayHello() public view returns(string, address) {
        if (isOwner()) {
            return ("Hey daddy!",owner);
        } else {
            return (greeting, owner_message);
        }
    }

    function setGreeting(string _newGreeting) public {
        mensajes.push(log(_newGreeting,msg.sender));
        greeting= _newGreeting;
        owner_message=msg.sender;
        total_mensajes++;
    }
    
    function isOwner() view private returns(bool) {
        return msg.sender == owner;    
    }
}