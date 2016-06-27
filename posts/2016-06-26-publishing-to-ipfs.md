-------------------------
title: Publishing to IPFS
-------------------------

If you visited this site more than once in the past year, you might notice
that it started redirecting to a weird path, like this: `/ipns/sevdev.hu`.

The reason being that the site is now hosted on [IPFS], and the path
you are seeing is the IPFS path of the site, served by the HTTP gateway
of [go-ipfs]. So, what is this, and why it is a big deal?

<!-- TEASER -->

# The Interplanetary Filesystem

IPFS is a distributed, peer-to-peer, content-addressed filesystem. It's like
the lovechild of BitTorrent and Git. It makes it possible to make a file or
directory available on the network, where other nodes can access it
knowing only the hash of the content, but unaware of the location of the host.
This allows a transparent, infrastructure-agnostic and inherently redundant
data storage. The network is trustless, as it's impossible to change their
content without changing their address.

In this setup, the VPS behind sevdev.hu is just an IPFS node, with a HTTP
gateway to serve traditional web browsers. If the page is accessed natively
through an IPFS client, it could just be served by any other IPFS node
which holds a copy.

# Publishing files

To get started, just install [go-ipfs] and initialise your node with
`ipfs init`. This will generate a private key, and a corresponding peer ID,
which will identify your node over the peer-to-peer network. After that, the
daemon can be started by `ipfs daemon`.

Making a file available on IPFS is the easiest part. After installing
[go-ipfs] , just use `ipfs add <path>`. That doesn't transmit anything
to the network - it just calculates and stores the hash of the given
file. If any node looks for this specific hash in the future, your node
will serve it.

It's also possible to store trees, just like in Git. A tree's hash is composed
of the hash and path of the leaves, which allows us to publish a whole
directory recursively, with `ipfs add -r <path>`.

# Addressing

The `ipfs add` command outputs a friendly looking, base-58 hash, starting
with `Qm` for some reason. This file can be referenced by any node on the
network, using the path `/ipfs/<hash>`. As long as your node is up and
has a healthy connection, any node can access your content using this
path. There is a public gateway at the IPFS home page to try: 
`http://ipfs.io/ipfs/<hash>`.

Since paths are immutable, it's impossible to deliver updates to users.
That's why IPFS has a separate namespace at `/ipns/`, where mutable
names can be resolved. The concept is similar to Git branches -- they are
mutable pointers, as oppesed to commits, which are content-addressable,
immutable objects.

This namespace can use a number of name services to resolve IPFS resources.

# IPFS names

IPFS provides a built-in method to publish names on the peer-to-peer network.
Using your private key, you can publish a name, which points to an IPFS
content address. These names are stored in a DHT, and has to be republished
regularly (~12h) to stay alive.

IPFS names can be published by the `ipfs name publish <hash>` command, which
will publish the given hash under the node's peer ID. The content can be
referenced later with the path `/ipns/<peer id>`. There is also a commandline
tool, [ipns-pub] to conveniently publish to multiple names, without changing
the node configuration.

This is a self-contained, decentralised way of publishing content, but
practically it needs an always-on server with the private key on file, 
to be able to keep the name alive. According to folks on [#ipfs], this will
change in the future.

# DNS

Alternatively, the good ol' DNS can be used to resolve IPFS names. The
`dnslink=` TXT record should point to the IPFS path.

For example, here's the TXT record of the [IPFS website][IPFS]:

```
ipfs.io. 11 IN TXT "dnslink=/ipfs/QmTzQ1JRkWErjk39mryYw2WVaphAZNAREyMchXzYQ7c15n"
```

Because of that TXT record, the website can be accessed by the `/ipns/ipfs.io`
path, instead of an unfriendly peer ID.

# Using IPFS on today's web

Obviously, there is no native support for the IPFS protocol in web browsers.
This site, as well as the IPFS webite provides a HTTP gateway, that
conveniently maps IPFS paths to the document root, so they can be loaded in
a HTTP client without any modification.

This practice makes it possible to redirect every HTTP gateway to the local
node's gateway pretty easily, for example using the [IPFS station] extension.
That provides a seamless way to use  IPFS how it's meant to be used: using the
peer-to-peer network, without any knowledge of the original host.

[IPFS]: /ipns/ipfs.io
[go-ipfs]: https://github.com/ipfs/go-ipfs
[ipns-pub]: https://github.com/whyrusleeping/ipns-pub
[#ipfs]: irc://chat.freenode.net/ipfs
[IPFS Station]: https://chrome.google.com/webstore/detail/ipfs-station/kckhgoigikkadogfdiojcblegfhdnjei

