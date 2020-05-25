pragma solidity >=0.5.0 <0.7.0;

contract Bill {

    address public ofd;
    address public fns;
    address public credit;
    bool public isProcessedByFns;


    constructor (address creditP, address fnsP) public {
        ofd = msg.sender;
        fns = fnsP;
        credit = creditP;
        isProcessedByFns = false;
    }

    function registerCredit() public {
        require(msg.sender == fns);
        require(!isProcessedByFns);
        isProcessedByFns = true;
    }

    function getSelfAddress() public view returns (address) {
        return address(this);
    }
}

