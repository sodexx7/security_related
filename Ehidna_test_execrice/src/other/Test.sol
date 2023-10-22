// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";


// interface DeFi {
//     ERC20 t;

//     function getShares(address user) external returns (uint256);

//     function createShares(uint256 val) external returns (uint256);

//     function depositShares(uint256 val) external;

//     function withdrawShares(uint256 val) external;

//     function transferShares(address to) external;
// }

// contract Test {
//     DeFi defi;
//     ERC20 token;

//     constructor() {
//         defi = new DeFi();
//         token = new ERC20();
//         token.mint(address(this), 100);
//     }

//     function getShares_never_reverts() public {
//         (bool b,) = defi.call(abi.encodeWithSignature("getShares(address)", address(this)));
//         assert(b);
//     }

//     function depositShares_never_reverts(uint256 val) public {
//         if (token.balanceOf(address(this)) >= val) {
//             (bool b,) = defi.call(abi.encodeWithSignature("depositShares(uint256)", val));
//             assert(b);
//         }
//     }

//     function withdrawShares_never_reverts(uint256 val) public {
//         if (defi.getShares(address(this)) >= val) {
//             (bool b,) = defi.call(abi.encodeWithSignature("withdrawShares(uint256)", val));
//             assert(b);
//         }
//     }

//     function depositShares_can_revert(uint256 val) public {
//         if (token.balanceOf(address(this)) < val) {
//             (bool b,) = defi.call(abi.encodeWithSignature("depositShares(uint256)", val));
//             assert(!b);
//         }
//     }

//     function withdrawShares_can_revert(uint256 val) public {
//         if (defi.getShares(address(this)) < val) {
//             (bool b,) = defi.call(abi.encodeWithSignature("withdrawShares(uint256)", val));
//             assert(!b);
//         }
//     }
// }