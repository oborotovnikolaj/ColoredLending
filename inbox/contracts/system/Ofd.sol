pragma solidity >=0.5.0 <0.7.0;

import "./TargetCredit.sol";
import "./Fns.sol";
import "./Bill.sol";

contract Ofd {

    address public owner;
    address public fns;

    mapping(address => bool) public shops;
    mapping(address => address) public targetCreditsReceived;
    mapping(address => bool) public targetSmartCreditsSentToFns;
    address[] targetCreditsToSendToFns;

    constructor() public{
        owner = msg.sender;
    }

    function receivePaidSmartCredit(address smartCredit) public returns(address){
        require(shops[msg.sender]);
        TargetCredit credit = TargetCredit(smartCredit);
        require(credit.getApprovedByBank());
        require(!credit.getPaid());

        Bill bill = new Bill(smartCredit, fns);
        targetCreditsReceived[smartCredit] = smartCredit;
        targetCreditsToSendToFns.push(smartCredit);
        return bill.getSelfAddress();

    }

    //    нужна еще логика по отчистке этого списка
    function sendToFns() public {
        require(msg.sender == owner);
        Fns smartFns = Fns(fns);
        smartFns.receiveSmartCredits(targetCreditsToSendToFns);
    }

    function addShop(address smartShop) public {
        shops[smartShop] = true;
    }

    function getSelfAddress() public view returns(address) {
        return address(this);
    }
}

