const {
    time,
    loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const NAME = "Overmint3"

describe(NAME, function () {
    async function setup() {
        const [owner, attackerWallet] = await ethers.getSigners();

        const VictimFactory = await ethers.getContractFactory(NAME);
        const victimContract = await VictimFactory.deploy();

        return { victimContract, attackerWallet };
    }

    describe("exploit", async function () {
        let victimContract, attackerWallet;
        before(async function () {
            ({ victimContract, attackerWallet } = await loadFixture(setup));
        })

        /**
         * 1 Create 5 new contract  while the attackerContract is creating.
         * 2 During each contract's constrution, mint one NFT, then transfer the NFT to the attackerWallet
         * 
         * TODO: runtime code/ creation code  
         */
        it("conduct your attack here", async function () {
            const AttackerFactory = await ethers.getContractFactory("Overmint3Attacker");
            const attackerContract = await AttackerFactory.connect(attackerWallet).deploy(victimContract.address);
            await attackerContract.deployed();
           
        });

        after(async function () {
            expect(await victimContract.balanceOf(attackerWallet.address)).to.be.equal(5);
            expect(await ethers.provider.getTransactionCount(attackerWallet.address)).to.equal(1, "must exploit one transaction");
        });
    });
});