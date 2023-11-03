const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const NAME = "DeleteUser";

describe(NAME, function () {
  async function setup() {
    const [owner, attackerWallet] = await ethers.getSigners();

    const VictimFactory = await ethers.getContractFactory(NAME);
    const victimContract = await VictimFactory.deploy();
    await victimContract.deposit({ value: ethers.utils.parseEther("1") });

    return { victimContract, attackerWallet };
  }

  describe("exploit", async function () {
    let victimContract, attackerWallet;
    before(async function () {
      ({ victimContract, attackerWallet } = await loadFixture(setup));
    });

    /**
     * The problem is related with how to delete the index‘s user in the array. Assume there are 3 user, when the second user withdraw his balance,
     * But the result is only delete the third user not the second user. though, the array's length become 2.
     * 
     * So the second user can contiune withdraw based on his data. 
     * 
     */
    it("conduct your attack here", async function () {
      const DeleteUserHackFactory = await ethers.getContractFactory("DeleteUserHack");
      const deleteUserHack = await DeleteUserHackFactory.deploy();

      await deleteUserHack.connect(attackerWallet).exploit(victimContract.address,{ value: ethers.utils.parseEther("1") });

    });

    after(async function () {
      expect(
        await ethers.provider.getBalance(victimContract.address)
      ).to.be.equal(0);
      expect(
        await ethers.provider.getTransactionCount(attackerWallet.address)
      ).to.equal(1, "must exploit one transaction");
    });
  });
});
