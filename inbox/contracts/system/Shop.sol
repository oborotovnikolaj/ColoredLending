pragma solidity >=0.5.0 <0.7.0;
import "./Ofd.sol";
import "./TargetCredit.sol";

contract Shop {

    mapping(address => bool) public targetCreditsRegistered;
    mapping(address => bool) public targetCreditsApproved;
    mapping(address => bool) public targetSmartCreditsProcessed;

    address public owner;
    address public cashBox;
    address public ofd;

    constructor (address ofdP, address cashBoxP) public {
        owner = msg.sender;
        ofd = ofdP;
        cashBox = cashBoxP;
    }

    function registerCredit() public {
        TargetCredit credit = TargetCredit(msg.sender);
        require(validateByShop(credit));
        require(!targetCreditsRegistered[msg.sender]);

        targetCreditsRegistered[msg.sender] = true;
    }

    function validateByShop(TargetCredit credit) virtual public returns(bool) {
        return true;
    }

    function approveByShopOwner(address smartCredit) public {
        require(msg.sender == owner);
        require(targetCreditsRegistered[smartCredit]);
        require(!targetCreditsApproved[smartCredit]);

        TargetCredit credit = TargetCredit(smartCredit);
        credit.getApproveFromBank();

        targetCreditsApproved[smartCredit] = true;
    }

    function processSmartCredit() public returns(address){
        require(targetCreditsRegistered[msg.sender]);
        require(targetCreditsApproved[msg.sender]);
        require(!targetSmartCreditsProcessed[msg.sender]);

        Ofd ofdContract = Ofd(ofd);
        address  smartBill = ofdContract.receivePaidSmartCredit(msg.sender);

        targetSmartCreditsProcessed[msg.sender] = true;
        return smartBill;
    }

    function getSelfAddress() public view returns(address) {
        return address(this);
    }
}