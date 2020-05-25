pragma solidity >=0.5.0 <0.7.0;
import "./Bank.sol";
import "./Shop.sol";

contract TargetCredit {

    address public client;
    address public shop;
    uint    public category;
    uint    public money;
    string  public paper;
    address public bank;
    bool    public isApprovedByClient;
    bool    public isRegisteredInBank;
    bool    public isRegisteredInShop;
    bool    public isApprovedByBank;
    bool    public isPaid;
    bool    public isClosed;

    address public smartBill;


    constructor(address clientP, address shopP, uint categoryP, uint moneyP, string memory paperP, address bankP) public {
        // constructor(address clientP, address shopP, uint categoryP, uint moneyP, string memory paperP, address bankP, address ofdP) public {
        client = clientP;
        shop = shopP;
        category = categoryP;
        money = moneyP;
        paper = paperP;
        bank = bankP;
        // ofd = ofdP;
        isApprovedByClient = false;
        isRegisteredInBank = false;
        isRegisteredInShop = false;
        isApprovedByBank = false;
        isAskedToPay = false;
        isPaid = false;
        isClosed = false;
    }

    function approveByClient(string memory clientPaper) public {
        require(client == msg.sender);
        require( keccak256(abi.encodePacked(paper)) == keccak256(abi.encodePacked(clientPaper)));
        require(!isApprovedByClient);
        isApprovedByClient = true;
    }

    function registerInBank() public {
        require(client == msg.sender);
        require(isApprovedByClient);
        require(!isRegisteredInBank);
        Bank smartBank = new Bank(bank);
        smartBank.registerCredit();
        isRegisteredInBank = true;
    }

    function registerInShop() public {
        require(client == msg.sender);
        require(isApprovedByClient);
        require(isRegisteredInBank);
        require(!isRegisteredInShop);
        Shop shopContract = Shop(shop);
        shopContract.registerCredit();
        isRegisteredInShop = true;
    }

    function getApproveFromBank() public {
        require(msg.sender == shop);
        require(isApprovedByClient);
        require(isRegisteredInBank);
        require(isRegisteredInShop);
        require(!isApprovedByBank);
        Bank smartBank = Bank(bank);
        smartBank.approvePayments();
        isApprovedByBank = true;
    }

    function buyShopBasket() public {
        require(msg.sender == client);
        require(isApprovedByClient);
        require(isRegisteredInBank);
        require(isRegisteredInShop);
        require(isApprovedByBank);
        require(!isPaid);

        Shop shopContract = Shop(shop);
        smartBill = shopContract.processSmartCredit();
        Bank smartBank = Bank(bank);
        smartBank.closePayment();

        isPaid = true;
    }

    function close(address smartBill) public {
        require(msg.sender == bank);
        require(isRegisteredInShop);
        require(isRegisteredInBank);
        require(isApprovedByBank);
        require(isPaid);

        isClosed = true;
    }

    function getBank() public view returns (address) {
        return bank;
    }

    function getApprovedByClient() public view returns (bool) {
        return isApprovedByClient;
    }

    function getRegisteredInShop() public view returns (bool) {
        return isRegisteredInShop;
    }

    function getRegisteredInBank() public view returns (bool) {
        return isRegisteredInBank;
    }

    function getApprovedByBank() public view returns (bool) {
        return isApprovedByBank;
    }

    function getPaid() public view returns (bool) {
        return isPaid;
    }

    function getClosed() public view returns (bool)  {
        return isClosed;
    }

    function getSummary() public view returns (address, uint, uint, address, address) {
        return (
        client,
        category,
        money,
        shop,
        bank
        );
    }

    function getSelfAddress() public view returns(address) {
        return address(this);
    }
}