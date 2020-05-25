pragma solidity >=0.5.0 <0.7.0;

abstract contract TargetCreditInterface {

    function approveByClient(string memory paper) public virtual;

    function approveRegisterInBank() public virtual;

    function registerInShop() public virtual;

    function getApproveFromBank() public virtual;

    function askCreditSendToOfd() public virtual;

    function askCreditTerminateTargetContract(address smartBill) public virtual;

    function getBank() public virtual view returns (address);

    function getApprovedByClient() public virtual view returns (bool);

    function getRegisteredInBank() public virtual view returns (bool);

    function getRegisteredInShop() public virtual view returns (bool);

    // function getApprovedByShop() public virtual view returns (bool);

    function getAskedToPayToShop() public virtual view returns (bool);

    function getSentToOfd() public virtual view returns (bool);

    function getTerminated() public virtual view returns (bool);

    function getSummary() public virtual view returns (address, uint, uint, address, address);

    function getSelfAddress() public virtual view returns(address);

    // debug
    function getDebug1() public view  virtual returns(bool);

    function getDebug2() public view  virtual returns(address);

    function getDebug3() public view  virtual returns(address);
}

abstract contract SmartShopInterface {

    function registerCredit() public virtual;

    function validateByShop(TargetCreditInterface targetCredit) public virtual  returns (bool);

    function approveByShopOwner(address smartCredit) public virtual;

    function sendToOfd() public virtual;

    function askShopTerminateSmartCredit(address smartCredit, address smartBill) public virtual;

    function getSelfAddress() public virtual view returns(address);

    // debug

    function getDebug1_2(address smartCredit) public virtual view returns(address);

    function getDebug1_3(address smartCredit) public virtual view returns(bool);

}

abstract contract BankInterface {

    function registerCredit(address smartCredit) public virtual;

    function approvePayments() public virtual;

    // function askContractToSentToOfd(address smartContract) public virtual;

    function terminateTargetContract(address smartBill) public virtual;

    function getSelfAddress() public virtual view returns(address);


}

contract BillInterface {

    address private smartCredit;

    constructor(address smartCredit) public {
        smartCredit = smartCredit;
    }

    function getSelfAddress() public view returns(address) {
        return address(this);
    }
}

abstract contract OfdInterface {

    function receivePaidSmartCredit(address smartCredit) public virtual;

    function addShop(address smartShop) public  virtual;

    function getSelfAddress() public virtual view returns(address);

}

abstract contract ContractFactoryInterface {

    function askBankToRegisterSmartCredit(address smartCredit) public virtual;

    function addBank(address bank) public virtual;

    function getSelfAddress() public virtual view returns(address);
}

