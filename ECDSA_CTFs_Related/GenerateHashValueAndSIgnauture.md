## Generate Another Vaild hash vaule and valid signature.

- Below code generating another valid hash valud and valid signature, but how to prove the blew math formula can guarantee these results work? [reference](https://kebabsec.xyz/posts/rareskills-alphagoatclub-ctf/)

```Python
    # public key for address 0xB1700C08Aa433b319dEF2b4bB31d6De5C8512D96
    x = int('29a272134c84cd93c1520a85007c2a0e38e80d0f312266b88089c17b61c48101', 16)
    y = int('b0257964abfb5640adc754419df69b142f773cb3687fe6a1601b3f07c71904b2', 16)
    Q = EC.Point(curve.curve, x, y)
    pubkey = ecdsa.VerifyingKey.from_public_point(Q, curve)

    a = ecdsa.util.randrange(n-1)

    # for the openzeppin ECDSA, which check the s value must bigger than below value
    must_less = 57896044618658097711785492504343953926418782139537452191302581570759080747168;

    valid_s = False
    while not valid_s:
        b = ecdsa.util.randrange(n-1)
        b_inv = inv_mod_p(b, n)

        K = (a*G) + (b*Q)
        r = K.x() % n

        s = r * b_inv % n

        if 0 < s < must_less:
            valid_s = True

    m = (((a * r) % n) * b_inv) % n
```

- How to do as [The Math behind the ECDSA Sign / Verify](https://cryptobook.nakov.com/digital-signatures/ecdsa-sign-verify-messages#the-math-behind-the-ecdsa-sign-verify) proving above math work?
