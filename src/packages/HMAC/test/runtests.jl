using Base.Test
using HMAC

# SHA256 HMAC tests from:
# https://git.lysator.liu.se/nettle/nettle/blob/master/testsuite/hmac-test.c
for (key,text,true_digest) in [
   (
        "",
        "",
        "b613679a0814d9ec772f95d778c35fc5ff1697c493715653c6c712144292c5ad"
    ),(
        "key",
        "The quick brown fox jumps over the lazy dog",
        "f7bc83f430538424b13298e6aa6fb143ef4d59a14946175997479dbc2d1a3cd8"
    ),(
        hex2bytes(
        "0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b0b" *
        "0b0b0b0b"),
        "Hi There",
        "b0344c61d8db38535ca8afceaf0bf12b" *
        "881dc200c9833da726e9376c2e32cff7"
    ),(
        "Jefe",
        "what do ya want for nothing?",
        "5bdcc146bf60754e6a042426089575c7" *
        "5a003f089d2739839dec58b964ec3843"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaa"),
        hex2bytes(
        "dddddddddddddddddddddddddddddddd" *
        "dddddddddddddddddddddddddddddddd" *
        "dddddddddddddddddddddddddddddddd" *
        "dddd"),
        "773ea91e36800e46854db8ebd09181a7" *
        "2959098b3ef8c122d9635514ced565fe"
    ),(
        hex2bytes(
        "0102030405060708090a0b0c0d0e0f10" *
        "111213141516171819"),
        hex2bytes(
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcdcdcdcdcdcdcdcdcdcdcdcdcdcdcd" *
        "cdcd"),
        "82558a389a443c0ea4cc819899f2083a" *
        "85f0faa3e578f8077a2e3ff46729665b"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaa"),
        "Test Using Larger Than Block-Size Key - Hash Key First",
        "60e431591ee0b67f0d8a26aacbf5b77f" *
        "8e0bc6213728c5140546040f0ee37f54"
    ),(
        hex2bytes(
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa" *
        "aaaaaa"),
        "This is a test using a larger than block-size ke" *
        "y and a larger than block-size data. The key nee" *
        "ds to be hashed before being used by the HMAC al" *
        "gorithm.",
        "9b09ffa71b942fcb27635fbcd5b0e944" *
        "bfdc63644f0713938a7f51535c3a35e2"
    )
]
    h = HMAC.HMACState(key)
    HMAC.update!(h, text)
    @test HMAC.hexdigest!(h) == true_digest
end


# Test show methods
println("Testing HMAC show methods:")
println(HMAC.HMACState(""))
