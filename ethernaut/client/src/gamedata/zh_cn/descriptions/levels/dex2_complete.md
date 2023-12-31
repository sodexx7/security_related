正如我们反复看到的，合约之间的交互可能是意外行为的来源。

仅仅因为一份合同声称要实施ERC20规范并不意味着它是值得信赖的。

一些代币偏离了[ERC20](https://eips.ethereum.org/EIPS/eip-20)规范，因为它们的传输方法不返回布尔值。[请参阅缺少返回值错误 - 至少130个token受到影响。](https://medium.com/coinmonks/missing-return-value-bug-at-least-130-tokens-affected-d67bf08521ca)

其他ERC20代币，尤其是那些由对手设计的代币，可能表现得更加恶意。

如果你设计一个DEX，任何人都可以在没有中央机构许可的情况下列出他们自己的代币，那么DEX的正确性可能取决于DEX合约和正在交易的代币合约的交互。
