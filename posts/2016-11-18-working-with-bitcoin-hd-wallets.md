======================================================
title: Working with bitcoin HD wallets: Key derivation
======================================================

If you are using Bitcoin regulary, you may have noticed that modern wallets let you
create multiple accounts with the same recovery seed and they crteate a new address
each time you create a payment request. This is important for privacy reasons
(if you were reusing the same address, your balance and your transaction
history would be publicly visible on the blockchain).

Key derivation has much more exciting applications though. You can have a paper
wallet, stored securely, and you derive all your hot wallets from it. If a hot wallet
is compromised or lost, the rest of your wallets stay safe, and you can restore the funds
from the lost wallet using the paper wallet. Or imagine a large organisation, where
there is a toplevel wallet managed by the CFO, and each department have there budgets
on their sub-wallets, having budget sub-wallets for different spending categories, and so on.

How does it work?

<!-- TEASER -->

# Public-key cryptography
As you might already know, Bitcoin is based on [public-key, AKA asymmetric cryptography][1]. 
Every bitcoin address is based on a public key. Knowing an address lets you send
transactions to that address, and see every transaction involving that address 
(giving you the "balance"). 

What you cannot do, is to create new transactions *from* that address. You need the
*private key* for that. The public key can be generated from the private key, but not
the other way around. The private key should always stay secret, as it allows the owner
to spend the money from a given address.

// TODO: BIP39

# Child key derivation (CKD)
To have a lot of addresses and to be able to spend the funds arriving to those,
we need to keep track of the private key for each address. This is how old
wallets work: they generate new keys in batches, so the users have to make
regular backups of their wallets, to keep their set of keys up to date. If the wallet
is lost and the backup is not up to date, funds received by the new addresses
which are not backed up are lost forever.

Using key derivation, this is no longer necessary: with a predefined algorithm,
one can generate child keys based on a master key, use those child keys as master
keys to generate new children, and so on. Bitcoin's algorithm of choice is defined 
in the [BIP32][2] standard.

# HD wallets
The BIP32 CKD function has three parameters: The key itself, a so-called "chain code"
and an index. The combination of the key and the chain code is called an extended key.
The index is a 32-bit integer, allowing us to derive 2<sup>32</sup> child keys.
In case you were wondering, that's a *lot* of child keys.

As I mentioned already, a child key is also an extended key, so we can use it to generate
more child keys. That gives us a tree of keys - hence the name
hierarchical deterministic wallet (HD wallet for short). The list of indexes
used in each step gives us the *derivation path* of a key, like `m/1/2/3`, where `m`
denotes the initial key (AKA the *master key*). The [BIP32 Genarator][3]

Since there are endless variations of these, the [BIP44][4] standard
specifies a set of derivation paths for HD wallets. If a user imports their private key to a
wallet application that implements BIP44 (such as Mycelium), it will automatically
keep generating addresses for the first account (`m/44'/0'/0'/*/*`), as long as it
finds transactions for them.

To be continued! In the next part, we'll discover the misteries of hardened derivation paths
and the use of extended public keys.

[1]: https://en.wikipedia.org/wiki/Public-key_cryptography
[2]: https://github.com/bitcoin/bips/blob/master/bip-0032.mediawiki
[3]: http://bip32.org/
[4]: https://github.com/bitcoin/bips/blob/master/bip-0044.mediawiki
