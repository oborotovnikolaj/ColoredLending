pragma solidity >=0.5.0 <0.7.0;

contract Fns {

    address public owner;

    mapping(address => bool) public registeredOfd;
    mapping(address => bool) public creditRegistered;

    constructor () public {
        owner = msg.sender;
    }

    function registerOfd(address ofd) public {
        require(msg.sender == owner);
        registeredOfd[ofd] = true;
    }

    function receiveSmartCredits(address[] memory credits) public {
        require(registeredOfd[msg.sender]);
        //        uint index;
        //        for (index; index < credits.length; index++) {
        //            creditRegistered[]
        //        }
        //        }
    }

    function getSelfAddress() public view returns(address) {
        return address(this);
    }

}

