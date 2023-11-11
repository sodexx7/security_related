## How the protocol works
The features as the websites shows in the bleow
``` 
A new cool lending pool has launched! It’s now offering flash loans of DVT tokens. It even includes a fancy governance mechanism to control it.
```

* This pool contract supply the flashloan feature.
* For emergency situation, only governance contract can call `emergencyExit`, which transfer all token to the specified address.
* the pool contract's token is based on  ERC20Snapshot, which main feature is recording the last value no matter the user balance or totolSupply when creating a new snapshot.
* For the governance contract, which can creat action and execute the corrospending action. 
    * Only one user have enough votes(the pool's token), can create one action.
    * For the action, can specify call any smart contract's function.

## The problem

* The pool's token is based on the ERC20Snapshot and creating the action of the governance contract is based on the token balance.
* So if one has enough the pool's tokens so has the conditions to create an action of the governance contract. And for the action, because which can specify any function of one smart contract, so the attacker has more power to do malicious actions.

One difference from the [the-rewarder](https://github.com/sodexx7/security_related/blob/fa0e32c3777b12c823709e7c66ba971339534490/damn-vulnerable-defi/contracts/the-rewarder/Exploit_README.md#L34) is only the  TheRewarderPool can generate the new snapshot, but for SelfiePool, if one get the token,anyone can generate new snapshot

Currently the token's snapshot as below and snapshotId=2
```solidity
ids [1] values [2000000n] totalSupply
ids [1] values [0]      pool address  
```

When the attacker borrow the token, his snapshots as below. If directly query balance by snapshoId=2, only return 0. But now the atacker can generate new snapshotId, make snapshotId = 3. Now the query's results is current balance. This is the same as [TheRewarder‘s snapshot ](https://github.com/sodexx7/security_related/blob/fa0e32c3777b12c823709e7c66ba971339534490/damn-vulnerable-defi/contracts/the-rewarder/Exploit_README.md#L70)
```solidity
ids [2] values [0] attacker's address
```

**So the core problem is the attacker can increase the governance votes by the vulnerability of using the snapshot balance wrongly.**

## Exploit steps


* STEP 1: 
    * flashloan the token to the SelfiePoolAttacker's address, make the snapshotId =3, then create an action when receiving the token.
    * The action, which set the target as SelfiePool's address, the data is calling SelfiePool's emergencyExit() function.
    * Approve the SelfiePool can transfer SelfiePoolAttacker's token balance.

* STEP 2:
    * after 2 days, just call the corrospending action of the goverence contract: governance.executeAction(1);










