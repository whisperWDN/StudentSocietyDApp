import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";

const config: HardhatUserConfig = {
  solidity: "0.8.9",
  networks: {
    ganache: {
      // rpc url, change it according to your ganache configuration
      url: 'http://localhost:8545',
      // the private key of signers, change it according to your ganache user
      accounts: [
        '0x5bb362be3afc2d8e47b6e15406320bd58ff8994677ca2932c6af35a6a3b10bf1',
        '0xecc9c45a019a258ffabe48480cf83f0ce0d381cde552f6c080a17a79efb0c5ca',
        '0xc7f0ba6a0302e1ddd0105ca9fa087e6847462aae681eb5b400d2a304ae88bb5a',
        '0x8592ed7b2154c7efab5bdd9f4f97ad26b7e43f50461d065d49973126cd5419d9',
      ]
    },
  },
};

export default config;
