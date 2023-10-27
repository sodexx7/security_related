const { ethers } = require('hardhat');
const { expect } = require('chai');
const { setBalance } = require('@nomicfoundation/hardhat-network-helpers');

describe('[Challenge] Side entrance', function () {
    let deployer, player;
    let pool;

    const ETHER_IN_POOL = 1000n * 10n ** 18n;
    const PLAYER_INITIAL_ETH_BALANCE = 1n * 10n ** 18n;

    before(async function () {
        /** SETUP SCENARIO - NO NEED TO CHANGE ANYTHING HERE */
        [deployer, player] = await ethers.getSigners();

        // Deploy pool and fund it
        pool = await (await ethers.getContractFactory('SideEntranceLenderPool', deployer)).deploy();
        await pool.deposit({ value: ETHER_IN_POOL });
        expect(await ethers.provider.getBalance(pool.address)).to.equal(ETHER_IN_POOL);

        // Player starts with limited ETH in balance
        await setBalance(player.address, PLAYER_INITIAL_ETH_BALANCE);
        expect(await ethers.provider.getBalance(player.address)).to.eq(PLAYER_INITIAL_ETH_BALANCE);

    });

    it('Execution', async function () {
        /**
         * 1. build an smart contract which inherited the IFlashLoanEtherReceiver to make it can do more actions in execute() function
         * 2. make the  smart contract can receive ETH. add `receive() external payable { }`
         * 3. The core weekness of the SideEntranceLenderPool is when people do flashloan, can call deposit to return the ETH. but balances[msg.sender]  has
         * changed. So the smart contract can withdraw all the ETH in SideEntranceLenderPool.
         * 4. Attack flow:
         *      1) exploitContract flashloan the max eth of the SideEntranceLenderPool, which was triggered by the player.
         *      2) deposit the received eth while received eth in execute() function
         *      3) exploitContract witrdraw all the eth
         *      4) transfer the eth from exploitContract to player
         */
        /** CODE YOUR SOLUTION HERE */
         let exploitContract = await (await ethers.getContractFactory('ExploitContract', deployer)).deploy(pool.address);
         await  exploitContract.connect(player).attack(ETHER_IN_POOL);
         let testBalance = await ethers.provider.getBalance(exploitContract.address);

    });

    after(async function () {
        /** SUCCESS CONDITIONS - NO NEED TO CHANGE ANYTHING HERE */

        // Player took all ETH from the pool
        expect(await ethers.provider.getBalance(pool.address)).to.be.equal(0);
        expect(await ethers.provider.getBalance(player.address)).to.be.gt(ETHER_IN_POOL);
    });
});
