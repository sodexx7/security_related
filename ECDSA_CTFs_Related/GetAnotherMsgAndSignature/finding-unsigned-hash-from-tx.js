// below scripts should use ether 5.7.0
// reference: https://medium.com/@LucasJennings/a-step-by-step-guide-to-generating-raw-ethereum-transactions-c3292ad36ab4

// 0x0422e4e07619a75d86a6e9bb82ac596c4bdecd3d61a00c2f4e3a88a3ce10acb7

// Remember that txhash contains the signatures ???

// related math
// https://cryptobook.nakov.com/digital-signatures/ecdsa-sign-verify-messages

const ethers = require("ethers");
require("dotenv").config();

getPublicKeyFromTransactionID = async (transactionHash) => {
  const expandedSig = {
    r: transactionHash.r,
    s: transactionHash.s,
    v: transactionHash.v,
  };

  console.log("transactionHash", transactionHash);

  const signature = ethers.utils.joinSignature(expandedSig);
  console.log("signature", signature);

  let transactionHashData;
  switch (transactionHash.type) {
    case 0:
      transactionHashData = {
        gasPrice: transactionHash.gasPrice,
        gasLimit: transactionHash.gasLimit,
        value: transactionHash.value,
        nonce: transactionHash.nonce,
        data: transactionHash.data,
        chainId: transactionHash.chainId,
        to: transactionHash.to,
      };
      break;
    case 2:
      transactionHashData = {
        gasLimit: transactionHash.gasLimit,
        value: transactionHash.value,
        nonce: transactionHash.nonce,
        data: transactionHash.data,
        chainId: transactionHash.chainId,
        to: transactionHash.to,
        type: 2,
        maxFeePerGas: transactionHash.maxFeePerGas,
        maxPriorityFeePerGas: transactionHash.maxPriorityFeePerGas,
      };
      break;
    default:
      throw "Unsupported transactionHash type";
  }

  const rstransactionHash = await ethers.utils.resolveProperties(
    transactionHashData
  );
  console.log("transactionHashData", transactionHashData);
  console.log("rstransactionHash", rstransactionHash);
  const raw = ethers.utils.serializeTransaction(rstransactionHash); // returns RLP encoded transactionHash
  console.log("raw", raw);
  const msgHash = ethers.utils.keccak256(raw); // as specified by ECDSA
  console.log("msgHash", msgHash);
  console.log(msgHash.toString("hex")); // @ChainLight: gimme a hash of the unsigned tx

  const msgBytes = ethers.utils.arrayify(msgHash); // create binary hash
  console.log("msgBytes", msgBytes);

  // from the hash data and signature, recover the public address
  const recoveredPubKey = ethers.utils.recoverPublicKey(msgBytes, signature);
  console.log("recoveredPubKey", recoveredPubKey);
  // get point(x,y)
  let x = recoveredPubKey.slice(2, 66);
  let y = recoveredPubKey.slice(66);

  console.log("x:", x);
  console.log("y:", y);

  let address = ethers.utils.computeAddress(recoveredPubKey);
  console.log("address", address);

  return recoveredPubKey;
};

(async () => {
  const provider = new ethers.providers.JsonRpcProvider(
    process.env.provider_URI
  );
  const tx = await provider.getTransaction(
    "0x09281ab72c20092dc9b414745ef2673116e36dfe069b61d2e37ecb8815b140bf"
  );

  await getPublicKeyFromTransactionID(tx);
})();
