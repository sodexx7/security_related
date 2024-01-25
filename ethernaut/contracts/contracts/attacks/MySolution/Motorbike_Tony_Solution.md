
* The weakness of Motorbike contract is that the engine(implementation contract) is uninitialized. so attacker can call initialize() became the owner of the engine. Then have the right calling upgradeToAndCall which can make a malicious contract as the engine meanwhile along with executing the selfdestruct. This leads to delete the engine contract. So the Motorbike contract's implementation contract lost.
[sepolia-solve-tx](https://sepolia.etherscan.io/tx/0xa4c6f273ffe39585277a58e6b0f38216fe447d931860ef5cf729b98ea0f97789)
