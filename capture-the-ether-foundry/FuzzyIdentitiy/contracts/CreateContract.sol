// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;
import "./ExploitContract.sol";

contract CreateContract {
    event createAddress(address indexed newAddress);
    function createDesiredAddress(
        bytes32 salt
    ) external returns (address pair) {
        bytes memory bytecode = abi.encodePacked(
            type(ExploitContract).creationCode
        );
        assembly {
            pair := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        emit createAddress(pair);
        return pair;
    }
}
