----
title: Discoveing Nix: Provisioning a static webserver with NixOps
----

Few weeks ago I decided to pick up [Nix]. It's a lovely concept: describe environments / Linux systems in an immutable, functional manner.

Although Docker solves the immutability part, the idea never really resonated with me: I find it a crude, but effective solution to put an immutable layer over our mutable OSs.

Nix chose a different approach: instead of making our existing systems immutable, it tackles the problem on a lower level: it aims to make the environment immutable from the ground up with a package manager called Nix, and an OS built around it called NixOS. And with NixOps, you can manage instances running NixOS.

In this article I will put together a simple static fileserver running Nginx using NixOps.

<!-- TEASER -->

## Installing NixOS

Since I'm a cheapass, and I love to make things hard for myself, I'll go with a [$3 KVM VPS on RamNode][ramnode]. They are dirt cheap, accept bitcoin, and they support NixOS. Unfortunately they ship an ancient version, 14.04, so it will be a bit tricky to get it up-to-date.

Note that if using AWS or another well-known cloud provider, the manual installation is not necessary as NixOps can [provision these boxes on it's own][manual-aws]. VirtualBox is also supported.

Let's fire up our node with the NixOS ISO mounted. We can connect to it with VNC to install NixOS (RamNode provides a surprisingly usuable HTML-based VNC client as well).



[Nix]: https://nixos.org/nix/
[ramnode]: http://ramnode.com/vps.php
[manual-aws]: https://nixos.org/nixops/manual/#sec-deploying-to-ec2

