
# Test smart contracts by tool vertigo-rs     
    1. src/NFTEnumerableContracts
    2. src/SmartContractTrio

# Metrics

```
Number of mutations:    54
Killed:                 25 / 54
```
1. killed   25
2. Error    26
3. Lived    3 (interface judge, It seems no porblem) 

* reference file:[vertigo_check](https://github.com/sodexx7/Week2_NFT_Staking_Security/blob/c3126a408d8a4f49a710fbc96476d58fe6d406cc/vertigo_check)

# Questions
* Error: the vertigo's problem? can't correctly change the source code 

## vertigo check based on the foundry coverage

![forge-coverage](https://github.com/sodexx7/Week2_NFT_Staking_Security/blob/main/StaticAnalysisAndMutationTesting/forge-coverage.png)


* tips: there are two branch can't cover

![forge-coverage-uncoverbranch1](https://github.com/sodexx7/Week2_NFT_Staking_Security/blob/main/StaticAnalysisAndMutationTesting/uncover_branch(1).png)
- [StakingContract](https://github.com/sodexx7/Week2_NFT_Staking_Security/blob/main/coverage/src/SmartContractTrio/src/SmartContractTrio/StakingContract.sol.gcov.html)


![forge-coverage-uncoverbranch2](https://github.com/sodexx7/Week2_NFT_Staking_Security/blob/main/StaticAnalysisAndMutationTesting/uncover_branch(2).png)
- [NFT721](https://github.com/sodexx7/Week2_NFT_Staking_Security/blob/main/coverage/src/SmartContractTrio/src/SmartContractTrio/NFT721.sol.gcov.html)





