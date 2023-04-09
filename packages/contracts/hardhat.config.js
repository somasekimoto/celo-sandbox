require("@nomicfoundation/hardhat-toolbox");
require("hardhat-celo");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.18",
  defaultNetwork: "hardhat",
  networks: {
    hardhat: {},
    alfajores: {
        // can be replaced with the RPC url of your choice.
        url: "https://alfajores-forno.celo-testnet.org",
        accounts: process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    // celo: {
    //     url: "https://forno.celo.org",
    //     accounts: [
    //         "<YOUR_PRIVATE_KEY>"
    //     ],
    // }
  },
  etherscan: {
    apiKey: {
        alfajores: process.env.CELOSCAN_API_KEY,
        // celo: "<CELOSCAN_API_KEY>"
    },
  },
};

