pragma solidity >=0.5.0 <0.7.0;
import "./TargetCredit.sol";

contract Bank {

    address public owner;
    address public contractFabric;

    mapping(address => bool) public targetSmartCreditsRegistered;
    mapping(address => bool) public targetSmartCreditsApproved;
    mapping(address => bool) public targetSmartCreditsPaid;
    mapping(address => bool) public targetSmartCreditsClosed;

    constructor (address contractFabricP) public {
        owner = msg.sender;
        contractFabric = contractFabricP;
    }

    function registerCredit() public {
        TargetCredit credit = TargetCredit(msg.sender);
        require(credit.getBank() == address(this));
        require(!targetSmartCreditsRegistered[msg.sender]);
        targetSmartCreditsRegistered[msg.sender] = true;
    }


    function approvePayments() public {
        require(targetSmartCreditsRegistered[msg.sender]);
        TargetCredit credit = TargetCredit(msg.sender);
        require(credit.getBank() == address(this));
        require(!targetSmartCreditsApproved[msg.sender]);

        targetSmartCreditsApproved[msg.sender] = true;
    }

    function closePayment() public {
        require(targetSmartCreditsRegistered[msg.sender]);
        TargetCredit credit = TargetCredit(msg.sender);
        require(credit.getBank() == getSelfAddress());
        require(targetSmartCreditsApproved[msg.sender]);
        require(!targetSmartCreditsPaid[msg.sender]);

        targetSmartCreditsPaid[msg.sender] = true;
    }

    function closeCredit(address smartCredit) public {
        require(msg.sender == owner);
        require(targetSmartCreditsRegistered[msg.sender]);
        TargetCredit credit = TargetCredit(msg.sender);
        require(credit.getBank() == getSelfAddress());
        require(targetSmartCreditsApproved[msg.sender]);
        require(targetSmartCreditsPaid[msg.sender]);
        require(!targetSmartCreditsClosed[msg.sender]);

        targetSmartCreditsClosed[msg.sender] = true;
        credit.close(smartCredit);
    }

    function getSelfAddress() public view returns(address) {
        return address(this);
    }

}

