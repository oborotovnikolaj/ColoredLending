pragma solidity ^0.4.18;


contract ColoredLending {

    address public owner;

    function ColoredLending() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    string public constant name = "Colored Oboro Token";

    string public constant symbol = "COT";

    uint32 public constant decimals = 18;

    uint public totalSupply = 0;

    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;

    mapping(address => mapping(string => uint))  balancesSpecial;

    mapping(address => mapping(address => mapping(string => uint))) balancesSpecialAllowed;

    mapping(address => string) specialGoodsMarketAddresses;

    function mint(address _to, uint _value) public onlyOwner {
        assert(totalSupply + _value >= totalSupply && balances[_to] + _value >= balances[_to]);
        require(msg.sender == _to);
        balances[_to] += _value;
        totalSupply += _value;
    }

    function balanceOf(address _owner) public constant returns (uint balance) {
        return balances[_owner];
    }

    function transfer(address _to, uint _value) public returns (bool success) {
        if (balancesSpecial[msg.sender][specialGoodsMarketAddresses[_to]] >= _value || owner == msg.sender) {
            if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {
                balances[msg.sender] -= _value;
                balances[_to] += _value;

                if (owner != msg.sender) {
                    balancesSpecial[msg.sender][specialGoodsMarketAddresses[_to]] -= _value;
                }
                balancesSpecial[_to][specialGoodsMarketAddresses[_to]] += _value;

                Transfer(msg.sender, _to, _value);
                return true;
            }
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint _value) public returns (bool success) {
        if (balancesSpecial[_from][specialGoodsMarketAddresses[_to]] >= _value || owner == msg.sender) {
            if (allowed[_from][_to] >= _value && balances[_from] >= _value && balances[_to] + _value >= balances[_to]) {
                allowed[_from][_to] -= _value;
                balances[_from] -= _value;
                balances[_to] += _value;

                if (owner != msg.sender) {
                    balancesSpecial[_from][specialGoodsMarketAddresses[_to]] -= _value;
                    balancesSpecialAllowed[_from][_to][specialGoodsMarketAddresses[_to]] -= _value;
                }
                balancesSpecial[_to][specialGoodsMarketAddresses[_to]] += _value;

                Transfer(_from, _to, _value);
                return true;
            }
        }
        return false;
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        balancesSpecialAllowed[msg.sender][_spender][specialGoodsMarketAddresses[_spender]] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public constant returns (uint remaining) {
        return allowed[_owner][_spender];
    }

    function addNewMarketAccount(address _newMarket, string _goodKind) public onlyOwner {
        specialGoodsMarketAddresses[_newMarket] = _goodKind;
    }

    function loanColoredMoney(address _to, string _goodKind, uint _value) public onlyOwner {
        require(balances[owner] >= _value && balances[_to] + _value >= balances[_to]);
        //        if(balances[owner] >= _value && balances[_to] + _value >= balances[_to]) {
        balances[owner] -= _value;
        balances[_to] += _value;
        balancesSpecial[_to][_goodKind] += _value;
        //        }
    }


    function getAccountSpecialBalance(address _accountAddress, string _goodKind) public constant returns (uint balance) {
        return balancesSpecial[_accountAddress][_goodKind];
    }

    function getGoodsKind(address _marketAddress) public constant returns (string goodsKind) {
        return specialGoodsMarketAddresses[_marketAddress];
    }

    function getAccountSpecialAllowance(address _owner, address _spender, string _goodKind) public constant returns (uint balance) {
        return balancesSpecialAllowed[_owner][_spender][_goodKind];
    }

    event Transfer(address indexed _from, address indexed _to, uint _value);

    event Approval(address indexed _owner, address indexed _spender, uint _value);

}
