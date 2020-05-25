pragma solidity >=0.5.0 <0.7.0;

import "./TargetCredit.sol";
import "./Bank.sol";

contract ContractFabric {

    mapping(address => bool) public banks;
    mapping(address => mapping(address => bool)) public banksToCredit;
    mapping(address => address[]) public clientsToCredit;

    function createSmartCredit() public{
    }

    function addBank(address bank) public  {
        banks[bank] = true;
    }

    function getSelfAddress() public view returns(address) {
        return address(this);
    }

}

