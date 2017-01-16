---------------------------------------------------------------
title: Working with Bitcoin HD wallets II: Deriving public keys
---------------------------------------------------------------

*Continuing my [previous article about HD wallets][1].*

So we already know how to create an infinite amount of wallets using a recovery seed
or an extended private key, the well-known derivation method described in [2]
and the derivation paths of [3].

However, generating keys based on the private key puts limits on the possible use cases.
The private key allows to spend the coins sent to its own or its children addresses, so
it must be kept secret. That implies that you have to fully trust the code and the
execution you use to generate your addresses.

Or let's say you want to receive payments from your peers frequently. You can either give
them a single address, making the whole transaction history between you clearly
visible on the blockchain. Alternatively, you can generate an address each time you are
expecting a payment, and send it to them, making it impossible to receive payments passively.

But there's a way to generate addresses in an untrusted environment, let it be a remote
server or a peer's runtime: using extended public keys.

<!-- TEASER -->

# Extended public keys

Extended private keys are regular private keys, extended with a 32-byte chain code.
As each private key has a corresponding public key, extending this its public key
with the same chain code gives us - wait for it - the extended public key.

With an extended public key, it's possible to derive child public keys using the same method
as with private keys, without knowing the sensitive private key.

# Security concerns

Although extended public keys cannot be used to get access to the private keys (and funds),
they are still more sensitive than regular public keys. A leaked extended private key
makes it possible to reconstruct every possible derived public key, effectively destroying
the privacy gained from using multiple addresses in the first place.

Also, due to the [mathematical properties of the CKD function][4], given an extended public
key and one of the descendants of its corresponding private key, it is possible to
recreate the extended private key and all its other descendant private keys. Thus, having
a leaked public key can amplify the damage caused by a leaked child private key, which
would be limited to its own funds otherwise.



[1]: ./posts/2016-11-16-working-with-bitcoin-hd-wallets.html
[2]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki 
[3]: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
[4]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki#user-content-Security
