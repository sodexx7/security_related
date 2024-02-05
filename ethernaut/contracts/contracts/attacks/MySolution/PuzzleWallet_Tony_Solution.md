## Steps:

1. address public pendingAdmin; ==> attacker address
2. can call function addToWhitelist(address addr), As the slot position of pendingAdmin in PuzzleProxy is owner's position of PuzzleWallet

   ```
   contract PuzzleWallet {
   address public owner;
   uint256 public maxBalance;

   contract PuzzleProxy is UpgradeableProxy {
   address public pendingAdmin;
   address public admin;

   ```

3. So have the right call addToWhitelist() and add attacker address to Whitelist

4. Calling deposit function twice by using the multicall function. Beacause when using delegateCall function, the msg.value keep same, though which have checked only call deposit once, the nestmulticall(build multicall which includes deposit function) can execute depoist again. This operation leads to deposit msg.value twice literaly, but actually depost once. So the attacker can withdraw the balance including the puzzlet's balance.

   ```
   function multicall(bytes[] calldata data) external payable onlyWhitelisted {
       bool depositCalled = false;
       for (uint256 i = 0; i < data.length; i++) {
           bytes memory _data = data[i];
           bytes4 selector;
           assembly {
               selector := mload(add(_data, 32))
           }
           if (selector == this.deposit.selector) {
               require(!depositCalled, "Deposit can only be called once");
               // Protect against reusing msg.value
               depositCalled = true;
           }
           (bool success, ) = address(this).delegatecall(data[i]);
           require(success, "Error while delegating call");
       }
   }

   ```

5. As the puzzlet's balance equal zero, so can call setMaxBalance, which will change the admin of the proxy contract.

- [sepolia-solve-tx](https://sepolia.etherscan.io/tx/0x84cc4470f6220c43f66464a58b9e08f28695672980af93551cf948a3d0900566)

### questions

I build the nestmulticall(including deposit) as blew data by remix debugging. Are there some code can encode the array type?

0xac9650d80000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000200000000000000000000000000000000000000000000000000000000000000004d0e30db000000000000000000000000000000000000000000000000000000000

```
// below method build nestmulticall doesn't work
bytes memory func2 = abi.encodeWithSignature("deposit(uint256)",5);
bytes[1] memory func22 = [func2];
console.logBytes(abi.encodeWithSignature("multicall(bytes[])",func22));
```

func22 should use dynamatic type
