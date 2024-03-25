## What pieces of information go in to an [EIP-712](https://eips.ethereum.org/EIPS/eip-712) delimiter, and what could go wrong if those were omitted?

- **Inculdes main two components(domainSeparator and message (typed structured data))**

  - `encode(domainSeparator : 𝔹²⁵⁶, message : 𝕊) = "\x19\x01" ‖ domainSeparator ‖ hashStruct(message)`

- **The workflow getting the ultimate hash result**

  1.  Firstly should encode message, which corrospending's the typed structured data, such as for the erc20 permit function

      ```
      bytes32 private constant PERMIT_TYPEHASH =
      keccak256(
          "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
      );
      bytes32 structHash = keccak256(
                  abi.encode(
                      PERMIT_TYPEHASH,
                      owner,
                      spender,
                      value,
                      _useNonce(owner),
                      deadline
                  )
              );

      ```

  2.  Add the domain data,the mechniasm same as permit

      ```
      bytes32 private constant TYPE_HASH =
              keccak256(
                  "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
      );

      function _buildDomainSeparator() private view returns (bytes32) {
          return
              keccak256(
                  abi.encode(
                      TYPE_HASH,
                      _hashedName,
                      _hashedVersion,
                      block.chainid,
                      address(this)
                  )
              );
      }
      ```

  3.  Then combine the structHash, domainSeparator, hashing the result along with add prefix "\x19\x01", get the ultimate result. "\x19\x01" shows the signed data is not tx, [eip-191](https://eips.ethereum.org/EIPS/eip-191)

  ```
      function toTypedDataHash(bytes32 domainSeparator, bytes32 structHash) internal pure returns (bytes32 digest) {
      /// @solidity memory-safe-assembly
      assembly {
      let ptr := mload(0x40)
      mstore(ptr, hex"19_01")
      mstore(add(ptr, 0x02), domainSeparator)
      mstore(add(ptr, 0x22), structHash)
      digest := keccak256(ptr, 0x42)
      }
  }
  ```

- ### The possible results if missing some info

  1.  For the eip712Domain, the fileds includes string name,string version,uint256 chainId,address verifyingContract,bytes32 salt

      - From the security perpespectives, if chainId was omitted, attacker can do do relay attack in another chain,
      - if verifyingContract was omitted, the malicious contract can execute the operation.
      - name, version which show the dapp or protocol's basic info, It's conventincly for user and developers and can be upgraded.
      - salt, was not added in current openzepplin implememntation

  2.  For the user defined data, which was defined by developer when desgin the business logic. but expecet some business logic data, some security problem should also take account.

      - such as the openzepplin permit type desgin `bytes32 private constant PERMIT_TYPEHASH =keccak256("Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)");` expect the necessary business data(owner,spender,value),should also add nonce, which prevent attacker can use same signature more than once, deadline, keeping the signature is valid only under before the deadline. [eip-2612](https://eips.ethereum.org/EIPS/eip-2612) has explain more details.

  3.  Lastly, should add \x19\x01, if omit,can't distinguish between it and normal tx.[eip-191](https://eips.ethereum.org/EIPS/eip-191)
