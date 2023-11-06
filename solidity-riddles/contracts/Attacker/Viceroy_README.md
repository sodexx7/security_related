## CORE LOGICS

The core logics involved threes type contracts:
* One is OligarchyNFT, who owns this NFT have the right to approve one EOA address as viceroy
* Second is Viceroy who can approve one EOA address as a voter. 
* Third is voter who can vote a vote.
*  Besides these, only viceroy and voter can create a proposal and when a proposal's votes is bigger than 10(inclusive 10),then the the proposal can be executed.


## CORE QUESTIONS

1.Although executeProposal limit the votes as 10, and one  viceroy only have 5 Appointments. but the owner of OligarchyNFT can delete one viceroy, then add another viceroy, **so that the owner of OligarchyNFT can appoint two viceroys, each has 5 numAppointments with 5 votes to break the limits of ten. The problem is related with the business logic flaws.**

2.Alought the desgin requesting the viceroy and voter must be an EOA address `require(viceroy.code.length == 0, "only EOA");` `require(voter.code.length == 0, "only EOA");` But the attacker can generate eoa adress or using create2 to create contract, which means precomputing the address and approving it as a viceroy or voter before create the contract and create the contract when needs.


## MY SOLUTION

# Solution 1
1. There are 12 contracts will be create, whose template is FalseEOA which can voteOnProposal, createProposal,approveVoter. 
2. Before creating falseEOAViceroy_1, Firstly precompute the address than make it as a Viceroy. then create the contract(falseEOAViceroy_1),
3. Let falseEOAViceroy_1 create a proposal, executing the proposal can withdraw all the CommunityWallet's balance to the attackWallet
4. Before create 5 voter contracts, Firstly precompute these address than let the falseEOAViceroy_1 make it as a voter. Secondly, let the voter votes a vote.
5. Let the attacker Depose falseEOAViceroy_1 as a Viceroy. Generate new address as a Viceroy, repeat the 2-step, 4-step to make the votes achieved the 10 votes
6. Execute the executeProposal


# Solution 2 
* Let the attackerWallet as a viceroy, and let it approve 5 eoa address as votes to vote
* creat a proposal, executing the proposal can withdraw all the CommunityWallet's balance to the attackWallet
* Depose attackerWallet as a Viceroy and reset the attackerWallet as Viceroy again. repeat the first step to make the votes achieved the 10 votes


## QUESTIONS

1. creat2 vs create, the contract's function can be executed while using creat2 creating a contact in one transaction. Is is the same as create?
2. delete `delete viceroys[viceroy];` although delete the viceroy. if the viceroy appove the voters, inside it the data 'approvedVoter' is not deleted. I guess the problem is related with this, but there are no relationships with it.