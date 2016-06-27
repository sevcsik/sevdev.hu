-------------------------
title: Publishing to IPFS
-------------------------

If you visited this site more than once in the past year, you might notice
that it started redirecting to a weird path, like this:

```
/ipns/QmPCSxsoWPRcKJpMagcSpE4kjWBZPxjHB8GZR7ZatMGfqN/index.html?
```

The reason being that the site is now hosted on [IPFS], and the path
you are seeing is the [IPFS] path of the site, served by the HTTP gateway
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

In this setup, the VPS behind sevdev.hu is just an [IPFS] node, with a HTTP
gateway to serve traditional web browsers. If the page is accessed natively
through an [IPFS] client, it could just be served by any other [IPFS] node
which holds a copy.

# Publishing files

To get started, just install [go-ipfs] and initialise your node with
`ipfs init`. This will generate a private key, and a corresponding peerID,
which will identify your node over the P2P network. After that, the daemon
can be started by `ipfs daemon`.

Making a file available on IPFS is the easiest part. After installing
[go-ipfs] , just use `ipfs add <path>`. That doesn't transmit anything
to the network - it just calculates and stores the hash of the given
file. Similar to Git, trees can be also stored. A tree's hash is composed
of the hash and path of the leaves, which allows us to publish a whole
directory recursively, with `ipfs add -r <path>`.

# Addressing

The `ipfs add` command outputs a very nice looking, base-58 hash, starting
with `Qm` for some reason. This file can be referenced by any node on the
network, using the path `/ipfs/<the hash>`. As long as your node is up and
has a healthy connection, any node can access this object. You can try it
by trying to load it on the ipfs.io HTTP gateway.





[IPFS]: https://ipfs.io
[go-ipfs]: https://github.com/ipfs/go-ipfs

