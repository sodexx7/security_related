import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

import {Test, console2} from "forge-std/Test.sol";

contract Week22Exercise2 {
    using ECDSA for bytes32;
    using MessageHashUtils for bytes32;
    address public verifyingAddress =
        0x0000000cCC7439F4972897cCd70994123e0921bC;
    mapping(bytes => bool) public used;

    function challenge(
        string calldata message,
        bytes calldata signature
    ) public {
        // console2.logBytes(bytes(message));
        // console2.logBytes(signature);

        bytes32 signedMessageHash = keccak256(abi.encode(message))
            .toEthSignedMessageHash();
        // console2.log("address", signedMessageHash.recover(signature));
        require(
            signedMessageHash.recover(signature) == verifyingAddress,
            "signature not valid"
        );

        require(!used[signature]);
        used[signature] = true;
    }

    function getUsed(bytes calldata signature) external returns (bool) {
        return used[signature];
    }
}
