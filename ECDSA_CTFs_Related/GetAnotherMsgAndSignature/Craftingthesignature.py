import math
import ecdsa
import ecdsa.ellipticcurve as EC

def inv_mod_p(x, p):
    if 1 != math.gcd(x, p):
        raise ValueError("Arguments not prime")
    q11 = 1
    q22 = 1
    q12 = 0
    q21 = 0
    while p != 0:
        temp = p
        q = x // p
        p = x % p
        x = temp
        t21 = q21
        t22 = q22
        q21 = q11 - q*q21
        q22 = q12 - q*q22
        q11 = t21
        q12 = t22
    return q11

curve = ecdsa.SECP256k1
G = curve.generator
n = G.order()

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

message_bytes32 = format(m, '064x')
r_bytes32 = format(r, '064x')
s_bytes32 = format(s, '064x')

print("message: " + message_bytes32)
print("r: " + r_bytes32)
print("s: " + s_bytes32)

sig = ecdsa.ecdsa.Signature(r, s)
print("sig",sig)
if pubkey.pubkey.verifies(m, sig):
    print("SIGNATURE VERIFIED")
else:
    print("FAILED TO VERIFY")