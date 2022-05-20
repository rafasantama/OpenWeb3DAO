// SPDX-License-Identifier: MIT
pragma solidity >= 0.7.4;

contract Inbox{  // defino que mi contrato se va a llamar Inbox
    string public message;   // variable donde se almacena la información

    constructor (string memory initialMessage) {  // este es el método constructor donde     inicializo el contrato con un mensaje
        message = initialMessage;
    }

    function setMessage(string memory newMessage) public { // esta función permite reemplazar el mensaje almacenada en la variable message
        message = newMessage;
    }
}
