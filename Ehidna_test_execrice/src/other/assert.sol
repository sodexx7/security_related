// SPDX-License-Identifier: AGPL-3.0
pragma solidity 0.7.5;

// contract Incrementor {
//     uint256 private counter = 2 ** 200;

//     function inc(uint256 val) public returns (uint256) {
//         uint256 tmp = counter;
//         unchecked {
//             counter += val;
//         }
//         assert(tmp <= counter);
//         return (counter - tmp);
//     }
// }

contract Incrementor {
    event AssertionFailed(uint256);

    uint256 private counter = 2 ** 200;

    function inc(uint256 val) public returns (uint256) {
        uint256 tmp = counter;
            counter += val;
        // if (tmp > counter) {
        //     emit AssertionFailed(counter);
        // }
        assert(tmp <= counter);
        return (counter - tmp);
    }
}



// TO-clairy https://github.com/crytic/building-secure-contracts/blob/master/program-analysis/echidna/basic/assertion-checking.md#when-and-how-to-use-assertions