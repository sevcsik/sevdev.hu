-------------------------
title: Publishing to IPFS
-------------------------

If you visited this site more than once in the past year, you might notice
that it started redirecting to a weird path, like this:

```
/ipns/QmPCSxsoWPRcKJpMagcSpE4kjWBZPxjHB8GZR7ZatMGfqN/index.html?
```

The reason being that the site is now hosted on [IPFS], and the path
you are seeing is the IPFS path of the site, served by the HTTP gateway
of [go-ipfs]. So, what is this, and why it is a big deal?

<!-- TEASER -->

# The Interplanetary Filesystem

IPFS is a distributed, peer-to-peer, content-addressed filesystem. It's like
the lovechild of BitTorrent and Git. With IPFS, you can publish files on the
P2P network. These files can be pulled by other nodes on the network 
automagically, aware only the hash of the content, but unaware of the
adress of the host. The network is trustless, because of the objects are
identified by their hash, it's impossible to change their content without
changing their address.

In this setup, the VPS behind sevdev.hu is just an IPFS node, with a HTTP
gateway to serve traditional web browsers.

[IPFS]: https://ipfs.io
[go-ipfs]: https://github.com/ipfs/go-ipfs

