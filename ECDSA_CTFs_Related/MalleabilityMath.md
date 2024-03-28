## Signature malleability math problem

ECDSA signature scheme allows the public key to be recovered from the signed message together with the signature. As the asymmetrical feature, exist two points in the curve, v(27/28) fix one point.

```
r = k * G (mod N)
s = k^-1 * (h + r * privateKey) (mod N)
```

Malleability attack as below [smart-contract-security:Signature malleability](https://www.rareskills.io/post/smart-contract-security)

```
  bytes32 s2 = bytes32(uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEBAAEDCE6AF48A03BBFD25E8CD0364141) - uint256(s));

  // invert v
  uint8 v2;
  require(v == 27 || v == 28, "invalid v");
  v2 = v == 27 ? 28 : 27;

  address b = ecrecover(h, v2, r, s2);
```

- TODO, how to prove s2, v2,r is valid signature from the perpespective of math?
