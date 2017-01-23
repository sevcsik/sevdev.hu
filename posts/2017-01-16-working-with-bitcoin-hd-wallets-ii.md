-----------------------------------------------------------------
title: "Working with Bitcoin HD wallets II: Deriving public keys"
-----------------------------------------------------------------

*Continuing my [previous article about HD wallets][1].*

So we already know how to create an huge amount of wallets using a recovery seed or an extended private key, the well-known derivation method described in [BIP32][2] and the derivation paths of [BIP44][3].

However, generating keys based on the private key puts limits on the possible use cases. The private key allows to spend the coins sent to its own or its descendants' addresses, so it must be kept secret. That implies that you have to fully trust the code and the runtime you use to generate your addresses.

There's a way to generate addresses in an untrusted environment though: using extended public keys.

<!-- TEASER -->

# Extended public keys

Extended private keys are regular private keys, extended with a 32-byte chain code. As each private key has a corresponding public key, so extending this its public key with the same chain code gives us - wait for it - the extended public key.

With an extended public key, it's possible to derive child public keys using the same method, without knowing the sensitive private key.

# Security concerns

Although extended public keys cannot be used to get access to the private keys (and funds), they are still more sensitive than regular public keys. A leaked extended public key makes it possible to reconstruct every possible derived public key, destroying the privacy gained from using key derivation in the first place.

Also, due to the [mathematical properties of the CKD function][4], given an extended public key and one of the descendants of its corresponding private key, it is possible to recreate the extended private key and all its other descendant private keys. Thus, having a leaked public key can amplify the damage caused by a leaked child private key, which would be limited to its own funds otherwise.

# Hardened derivation

To mitigate this issue, there is a special case of key derivation, called hardened derivation. A quick reminder: the derivation function has two inputs, the extended key and the index, which is a 32-bit integer. We can split this 32-bit space into two halves, above and below 2<sup>31</sup>. You can derive private keys at both halves, but only the lower half can be used to derive public keys, achieved by mixing the [parent private key into the formula][6] if the index is higher than 2<sup>31</sup>.

Private keys derived with an index of the upper half are called *hardened keys*, and in the derivation path (the string of indexes which is used for derivation) are denoted with the [prime symbol][5] (`'`), relative to 2<sup>31</sup>. 

To learn more about the cryptographic background of hardened keys and their usefulness, check out the [Developer Guide on bitcoin.org][6].

# Hardened keys in HD wallets

Wallet software implementing [BIP44][3] are using the following derivation scheme:

```
m / 44' / coin_type' / account' / change / address_index
```

The first three levels are hardened, meaning it's not possible to derive the different accounts' public keys from the master public key. Using the accounts' extended public keys though, it is possible to generate every address under that account, making it possible to generate "read-only" addresses without risking the accounts' funds. If one account's extended private key or one of its child private keys are exposed, that damage will be limited to that account but the other accounts are kept safe.

In the next article, we'll see a real-life scenario of how key derivation and extended public keys can make a life easier for an enterprise running on Bitcoin.

[1]: ./posts/2016-11-16-working-with-bitcoin-hd-wallets.html
[2]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki 
[3]: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
[4]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#user-content-Security
[5]: https://en.wikipedia.org/wiki/Prime_%28symbol%29
[6]: https://bitcoin.org/en/developer-guide#hardened-keys
