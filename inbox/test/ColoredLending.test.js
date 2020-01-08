const assert = require('assert');
const ganache = require('ganache-cli');
const Web3 = require('web3');
const provider = ganache.provider();
const web3 = new Web3(provider);

const {interface, bytecode} = require('../compile');

let accounts;
let coloredLending;
let owner;
//todo Не проработано взимодействие между клиент-клиент (клент-магазин нормально)
beforeEach(async () => {
    // Get a list of all accounts
    accounts = await web3.eth.getAccounts();
    web3.eth.getAccounts().then(fetchedAccounts => {
        console.log(fetchedAccounts)
    });

    // the contract
    coloredLending = await new web3.eth.Contract(JSON.parse(interface))
        .deploy({
            data: bytecode,
            arguments: []
        })
        .send({from: accounts[0], gas: '6710000'});
    // .send({from: accounts[0], gas: '10000000000'});
    // Use one of those accounts to deploy
    coloredLending.setProvider(provider);

    owner = await coloredLending.methods.owner().call();

    // coloredLending.createProposal()

});

describe('ColoredLending', () => {
    it('deploys a contract', () => {
        assert.ok(coloredLending.options.address);
    });

    it('only owner can mint, and only owner can get minted money on the address', async () => {
        await coloredLending.methods.mint(owner, 100).send({from: owner});
        let mintedMoney = await coloredLending.methods.balanceOf(owner).call();
        assert.equal(mintedMoney, 100);
        try {
            await coloredLending.methods.mint(owner, 100).send({from: accounts[1]});
            assert(false);
        } catch (e) {
            assert(e);
            try {
                await coloredLending.methods.mint(accounts[1], 100).send({from: owner});
                assert(false);
            } catch (e) {
                assert(e);
            }
        }
    });

    it('addNewMarketAccount, only owner can do it', async () => {
        await coloredLending.methods.addNewMarketAccount(accounts[1], "education").send({from: owner});
        let goodsKind = await coloredLending.methods.getGoodsKind(accounts[1]).call();
        assert.equal(goodsKind, "education");
        try {
            await coloredLending.methods.addNewMarketAccount(accounts[2], "sex, drugs and booze").send({from: accounts[2]});
            assert(false)
        } catch (e) {
            assert(e)
        }
    });


    it('loanColoredMoney, only owner can do it, owner can not lent more money, that it has ', async () => {
        await coloredLending.methods.mint(owner, 1000).send({from: owner});
        await coloredLending.methods.loanColoredMoney(accounts[1], "education", 500).send({from: owner});

        let coloredLentMoney = await coloredLending.methods.getAccountSpecialBalance(accounts[1], "education").call();
        assert.equal(coloredLentMoney, 500);
        try {
            await coloredLending.methods.loanColoredMoney(accounts[1], "education", 500).send({from: accounts[1]});
            assert(false);
        } catch (e) {
            assert(e);
            try {
                await coloredLending.methods.loanColoredMoney(accounts[1], "education", 1100).send({from: accounts[1]});
                assert(false);
            } catch (e) {
                assert(e);
            }
        }
    });

    it('transfer, sender can not transfer more money, that it has, sender can spend money only on a special category of goods', async () => {
        await coloredLending.methods.mint(owner, 1000).send({from: owner});
        await coloredLending.methods.loanColoredMoney(accounts[1], "education", 500).send({from: owner});
        await coloredLending.methods.addNewMarketAccount(accounts[2], "education").send({from: owner});
        await coloredLending.methods.addNewMarketAccount(accounts[3], "sex, drugs and booze").send({from:owner });

        await coloredLending.methods.transfer(accounts[2], 300).send({from: accounts[1], gas: '6710000'});
        let coloredLentMoneyClient = await coloredLending.methods.getAccountSpecialBalance(accounts[1], "education").call();
        let coloredLentMoneyMarket = await coloredLending.methods.getAccountSpecialBalance(accounts[2], "education").call();

        assert.equal(coloredLentMoneyClient, 200);
        assert.equal(coloredLentMoneyMarket, 300);

        await coloredLending.methods.transfer(accounts[3], 100).send({from: accounts[1]});
        coloredLentMoneyClient = await coloredLending.methods.getAccountSpecialBalance(accounts[1], "education").call();
        coloredLentMoneyMarket = await coloredLending.methods.balanceOf(accounts[3]).call();
        assert.equal(coloredLentMoneyClient, 200);
        assert.equal(coloredLentMoneyMarket, 0);

        await coloredLending.methods.transfer(accounts[2], 500).send({from: accounts[1]});
        coloredLentMoneyClient = await coloredLending.methods.getAccountSpecialBalance(accounts[1], "education").call();
        coloredLentMoneyMarket = await coloredLending.methods.getAccountSpecialBalance(accounts[2], "education").call();
        assert.equal(coloredLentMoneyClient, 200);
        assert.equal(coloredLentMoneyMarket, 300);
    });

    it('approve', async () => {
        await coloredLending.methods.addNewMarketAccount(accounts[2], "education").send({from: owner});
        await coloredLending.methods.approve(accounts[2], 300).send({from: accounts[1], gas: '6710000'});

        let allowedMoney = await coloredLending.methods.allowance(accounts[1], accounts[2]).call();
        let coloredAllowedMoney = await coloredLending.methods.getAccountSpecialAllowance(accounts[1], accounts[2], "education").call();

        assert.equal(allowedMoney, 300);
        assert.equal(coloredAllowedMoney, 300);

    });


    it('transferFrom', async () => {
        await coloredLending.methods.mint(owner, 1000).send({from: owner});
        await coloredLending.methods.loanColoredMoney(accounts[1], "education", 500).send({from: owner});
        await coloredLending.methods.addNewMarketAccount(accounts[2], "education").send({from: owner});
        await coloredLending.methods.addNewMarketAccount(accounts[3], "sex, drugs and booze").send({from:owner });
        await coloredLending.methods.approve(accounts[2], 300).send({from: accounts[1], gas: '6710000'});

        await coloredLending.methods.transferFrom(accounts[1], accounts[2], 300).send({from: accounts[1], gas: '6710000'});
        let coloredLentMoneyClient = await coloredLending.methods.getAccountSpecialBalance(accounts[1], "education").call();
        let coloredLentMoneyMarket = await coloredLending.methods.getAccountSpecialBalance(accounts[2], "education").call();
        assert.equal(coloredLentMoneyClient, 200);
        assert.equal(coloredLentMoneyMarket, 300);


        await coloredLending.methods.transferFrom(accounts[1], accounts[2], 600).send({from: accounts[1], gas: '6710000'});
        coloredLentMoneyClient = await coloredLending.methods.getAccountSpecialBalance(accounts[1], "education").call();
        coloredLentMoneyMarket = await coloredLending.methods.getAccountSpecialBalance(accounts[2], "education").call();
        assert.equal(coloredLentMoneyClient, 200);
        assert.equal(coloredLentMoneyMarket, 300);


        await coloredLending.methods.transferFrom(accounts[1], accounts[3], 300).send({from: accounts[1], gas: '6710000'});
        coloredLentMoneyClient = await coloredLending.methods.getAccountSpecialBalance(accounts[1], "education").call();
        coloredLentMoneyMarket = await coloredLending.methods.balanceOf(accounts[3]).call();
        assert.equal(coloredLentMoneyClient, 200);
        assert.equal(coloredLentMoneyMarket, 0);

    });
});
