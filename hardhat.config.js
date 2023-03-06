require('dotenv').config();

require("@nomicfoundation/hardhat-toolbox");
require("hardhat-gas-reporter");
require('hardhat-contract-sizer');


/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  gasReporter: {
    currency: 'USD',
    coinmarketcap: process.env.COIN_MARKET_CAP_KEY,
    showTimeSpent: true,
    enabled: true
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
    only: []
  }
};
