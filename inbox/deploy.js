const HDWalletProvider = require('truffle-hdwallet-provider');
const Web3 = require('web3');
const { interface, bytecode } = require('./compile');

const provider = new HDWalletProvider(
  'brand glue chronic game click resemble vehicle absent owner zone replace mercy',
  'https://rinkeby.infura.io/v3/99f7955ac8354b62b4413af97f4407d5'
);
const web3 = new Web3(provider);

const deploy = async () => {
  const accounts = await web3.eth.getAccounts();

  console.log('Attempting to deploy from account', accounts[0]);

  const result = await new web3.eth.Contract(JSON.parse(interface))
      .deploy({ data: bytecode, arguments: [] })
      .send({ gas: '6710000', from: accounts[0] });

  console.log('Contract deployed to', result.options.address);
};
deploy();
