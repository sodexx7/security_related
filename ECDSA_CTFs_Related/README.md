## ECDSA_CTFs

1.  What pieces of information go in to an [EIP-712](https://eips.ethereum.org/EIPS/eip-712) delimiter, and what could go wrong if those were omitted?

    [Answer](./EIP712_Related.md)

2.  DoubleTake

    - [DoubleTake Contract](https://github.com/sodexx7/security_related/blob/main/solidity-riddles/contracts/DoubleTake.sol)
    - [exploit code](https://github.com/sodexx7/security_related/blob/068a47911c341dc500eada76056c5451d453252f/solidity-riddles/test/DoubleTake.js#L35)

    - npx hardhat test test/DoubleTake.js

3.  Week22Exercise2

    - [Week22Exercise2](./src/Week22Exercise2.sol)
    - the valid signature can be find in https://optimistic.etherscan.io/address/0x0000000ccc7439f4972897ccd70994123e0921bc,
    - forge test --match-contract Week22Exercise2Test

4.  Week22Exercise3

    - The workflow of approve one user can get the airdrop as below two steps:

      1. the contract's owner sign airdrop msg, which consits of amount, user address, nonce(can be queried). then send the airdrop msg with the signature(v,r,s) to the user or other parties want to pay the gas executing the tx.
      2. the user or other parties call the claimAirdrop funciton inputting the corresponding's params

    - Problem

      1. As above steps show, when the contract's owner sign the airdrop msg and send the signature the user.
      2. Then the contract's owner was transferred to another user. meanwhile the user didn't call claim the airdrop
      3. **Then when the user want to claim the airdrop, never can get the airdrop because as the code shows, the owner was the original owner, not the current owner**.

      ```solidity
      require(recovered == owner(), "invalid signature");
      ```

    - Solution

      - should add the owner address.

      ```solidity
      function claimAirdrop(
         address owner. // add owner address
         uint256 amount,
         address to,
         uint8 v,
         bytes32 r,
         bytes32 s
      ) public {
      ```

    **Add medium severity weakness**

    - if owner call renounceOwnership(), the address's owner will become address(0), then any unvalid signature along with hash can claim the airdrop. Because
      ecrecover(hash\_, v, r, s) will return address(0) if input unvalid signature,.

    ```
      address recovered = ecrecover(hash_, v, r, s);
    ```

5.  [Week22Exercise4](src/Week22Exercise4.sol)

    - As below funciton directly using hash\* instead of hasing the message onchain, one way can generate another valid hash and signature can pass below chek.

      ```Solidity
          function matchAddressSigner(
          bytes32 hash_,
          bytes memory signature
          ) private view returns (bool) {
             return signer == hash_.recover(signature);
          }
      ```

    * The steps generating another valid msg and signature

      1. As the signer address is `address signer = 0xB1700C08Aa433b319dEF2b4bB31d6De5C8512D96;`, get the address's corresponding's public key form on-chain. Blew scripts can get the public key through one history [tx](https://polygonscan.com/tx/0x09281ab72c20092dc9b414745ef2673116e36dfe069b61d2e37ecb8815b140bf) of the address.

      - node GetAnotherMsgAndSignature/finding-unsigned-hash-from-tx.js

        - which reference https://gist.github.com/junomonster/d0c8b6820f00caf81e421ab741b3bbe8

      2. Through public key, can generate the valid msg and signature. one point should notice is the s value should less than '57896044618658097711785492504343953926418782139537452191302581570759080747168', as openzepplin have check signature malleability.

      - python GetAnotherMsgAndSignature/Craftingthesignature.py

        - which reference https://kebabsec.xyz/posts/rareskills-alphagoatclub-ctf/

      * For me: the generate public key is '0x0429a272134c84cd93c1520a85007c2a0e38e80d0f312266b88089c17b61c48101b0257964abfb5640adc754419df69b142f773cb3687fe6a1601b3f07c71904b2' remove prefix '04',get

        - x = 29a272134c84cd93c1520a85007c2a0e38e80d0f312266b88089c17b61c48101
        - y = b0257964abfb5640adc754419df69b142f773cb3687fe6a1601b3f07c71904b2.

        * then get the r,s and message, just try v =27 or v= 28 get the valid signature.

- forge test --match-contract Week22Exercise4Test

### Others

1. [Why should do on-chain hash](OnChainHash.md)

2. TODO, [the math generating another valid hashValue and signature by public-key](GenerateHashValueAndSIgnauture.md)

3. TODO, [the math of malleability](MalleabilityMath.md)
