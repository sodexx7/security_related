## Check summary


# slither check analyaze
1. [week1_ERC1363_Tokens_and_Bonding_Curves](https://github.com/sodexx7/week1_ERC1363_Tokens_and_Bonding_Curves/blob/main/StaticAnalysisAndMutationTesting/trueandFalsePositives.md)

2. [Week2_NFT_Staking_Security](https://github.com/sodexx7/Week2_NFT_Staking_Security/blob/main/StaticAnalysisAndMutationTesting/trueAndFalsePositives.md)

# MythX check results

1. [Check project:BondingCurve](https://github.com/sodexx7/week1_ERC1363_Tokens_and_Bonding_Curves/blob/285d7f10b5fbfd8689e8428383d85c187d8f8a06/StaticAnalysisAndMutationTesting/BondingCurve.pdf)

2. [check stakingContract](https://github.com/sodexx7/Week2_NFT_Staking_Security/blob/c3126a408d8a4f49a710fbc96476d58fe6d406cc/StaticAnalysisAndMutationTesting/stakingContractCheckByMythx.pdf)

The mythx's results almost involved explicitly setting the visibility of state variables, except some results I think is doesn't matter.


## Reference
### security tools
1. **Slither**

> Slither is a Solidity & Vyper static analysis framework written in Python3. It runs a suite of vulnerability detectors, prints visual information about contract details, and provides an API to easily write custom analyses. Slither enables developers to find vulnerabilities, enhance their code comprehension, and quickly prototype custom analyses.

* The deepest impression for me is detectors of repo, based on which to find the vulnerability. And some detector can't accurately judge  the vulnerability if the smart contract's logic seems more complex. such as my stakingContract withDrawNFT.

* [The tested slither command](security-check-test(slither)/README.md)
* [slither-office](https://github.com/crytic/slither)
* [trailofbits-eth-security-toolbox](https://github.com/trailofbits/eth-security-toolbox)
* [slither-basic-usage](https://github.com/t4sk/hello-smart-contract-security-tools#slither)

2. **Mythx**

* Mythx is under the ConsenSys, and used the dectors based on the [swc-x](https://swcregistry.io/), for my check, don't find some big problem, perhaps because my contracts is checked by slither or my my contract's codebase is relatively samll. Another questions is i ofen encounter the network problem while using it.
* [MYTHX](https://mythx.io/)

3. **vertigo-rs(Mutation Tool)**
* It suports foundry framework, and the test coverage should cover 100% before using mutation. which help me find the ignored corner case, but the running often need more time.
* [vertigo-rs](https://github.com/RareSkills/vertigo-rs)
* [solidity-mutation-testing](https://www.rareskills.io/post/solidity-mutation-testing)
* [Mutation_testing](https://en.wikipedia.org/wiki/Mutation_testing)


