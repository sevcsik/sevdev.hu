------------------------------------------------------------------
title: Discoveing Nix: Provisioning a static webserver with NixOps
------------------------------------------------------------------

Few weeks ago I decided to pick up Nix. It's a lovely concept: describe environments / Linux systems in an immutable, functional manner.

Although Docker solves the immutability part, the idea never really resonated with me: I find it a crude, but effective solution to put an immutable layer over our mutable OSs.

Nix has a different approach: instead of making our existing systems immutable, it tackles the problem on a lower level: it aims to make the environment immutable from the ground up with a package manager called Nix, and an OS built around it called NixOS. And with NixOps, you can manage instances running NixOS.

In this article I will put together a simple static fileserver running Nginx using NixOps.

<!-- TEASER -->

For this tutorial, I will manually install NixOS on a cheap [RamNode][ramnode-product-page] VPS. I like the manual installation while I'm learning, because I can learn a lot more of how the system works.

In real life, it's easier to go with a cloud provider supported by NixOps, such as Azure, EC2 or GCE, or a local VirtualBox installation. NixOps can provision machines to these providers automatically, so if you feel like it just skip the next section and look at the [relevant section of the manual][nixos-manual-ec2] instead.

## Installing a minimal NixOS

Installing NixOS is pretty straightforward. First, we need to prepare your filesystems as usual with fdisk and mkfs. I prefer to add labels to my filesystems as I can have a more meaningful (and less volatile) `fstab`, but it's not necessary.

After we prepared the disk, we mount the root partition and enable swap if needed.

```bash
# parted -s /dev/sda mklabel msdos
# parted -s -a opt /dev/sda mkpart primary 32kB 10%
# parted -s -a opt /dev/sda mkpart primary 10% 100%
# mkswap /dev/sda1 -L swap
# mkfs.ext4 /dev/sda2 -L root
# mount /dev/disk/by-label/root /mnt
# swapon /dev/disk/by-label/swap
```

After our mounts are set up, we create our target system's configuration. The `nixos-generate-config` utility uses the installation environment's state -- such as loaded kernel modules, network, mounts -- to generate a starter Nix expression.

```bash
# nixos-generate-config --root /mnt
```

This generates two files: `/mnt/etc/nixos/configuration.nix` and `hardware-configuration.nix`. The latter one is imported by the former. As the name suggests, the latter one contains hardware-specific details such as mounts and kernel modules. It makes sense to keep it in a separate file, because it can be regenerated every time the hardware changes - which is a real use case on bare metal. However, we'll manage this configuration with NixOps later, so it's ok to edit it.

To make our system bootable, we need to add enable GRUB in the configuration. We add the following to 
`hardware-configuration.nix`:

```nix
boot.loader.grub.enable = true;
boot.loader.grub.version = 2;
boot.loader.grub.device = "/dev/sda";
```

We can also change the by-UUID devices to by-label while we're at it, to make our configuration more portable.

We'll need to enable password login for root, so NixOps can log in to deploy. This is only needed for the first deployment, until the SSH-keys are properly set up. Just add the following to to `configuration.nix `:

```bash
networking.firewall.allowedTCPPorts = [ 22 ];
services.openssh.enable = true;
services.openssh.permitRootLogin = "yes";
```

We can delete the rest of the config file, the only thing which has to stay is the part that imports the hardware config.

That was it, we can continue the installation with the `nixos-install --root /mnt`  command. If everything works out fine, it will ask for a root password, and then we can reboot the machine.

## Updating to the latest version

Unfortunately 

## Provisioning our node with NixOps

On another machine (our workstation, probably), we need to install NixOps via Nix. Nix is likely available via your distribution's package manager or — if that's your thing — there's a handy installer on the [project website][nix-installation]. If we add the Nix bin directory to our `$PATH` as suggested by the installer (if using a package this might be done automatically), the installed Nix packages will be available globally. If not, then can be accessed via `nix-shell`, which makes it quite convenient to manage different development environments.

After we have Nix up and running, we install NixOps in our environment.

```bash
$ nix-env --install nixops 
```

Now that our node is set up, let's pull our generated config file to have something to begin with (I'll refer to our target host as `target.example.com`), and rename them to something meaningful:

```bash
$ scp -r root@target.example.com:/etc/nixos/hardware-configuration.nix ramnode-kvm.nix
```

With this naming we can have a separate hardware-specific expression for each type of machine (like RamNode or VirtualBox) and switch it below our higher-level configuration easily.

We need a top-level expression which defines the network and puts the pieces together. We also define the technical details of deployment here. Since we already installed NixOS manually, we just have to provide a host for NixOps.

```nix
{
    fileserver = {
        deployment.targetHost = "target.example.com";
        networking.hostName = "target.example.com";
        imports = [ ./ramnode-kvm.nix
                    ./ssh.nix
                    ./webserver.nix
                  ];
    };
    network.description = "example network";
}
```

If we used a supported cloud provider, we [would set it up here][nixos-manual-ec2], instead of using the separate `hardware-configuration.nix` we got from the installer.

## Defining services

Our previous nix expression points to two files we're yet to create: `ssh.nix` and `webserver.nix`. These two will describe the different services running on our server.

### OpenSSH

We already saw configuring SSH during install. The only difference is that this time, we won't allow root login with password - NixOps will set up SSH keypairs during the first deployment so we can omit it this time.

`ssh.nix`:

```
{
    networking.firewall.allowedTCPPorts = [ 22 ];
    services.openssh.enable = true;
}
```

### Nginx

Here comes the fun part! First of all, we open the ports on the firewall:

`webserver.nix`:
```
{
    networking.firewall.allowedTCPPorts = [ 80 443 ];
```

Then we enable the nginx service. Note that we're using the [attribute set syntax][nix-manual-sets] here instead of dot-separated fields. The Nix language is not just a configuration file format but a full-blown functional language. We're just scratching the surface here - be sure to check out the language itself.

We also add a virtual host to our hostname.

`webserver.nix` (continuing):
```
    services.nginx = {
        enable = true;
        virtualHosts = {
            "target.example.com" = {
                locations."/".root = "/var/www/target.example.com";
```

Having TLS wouldn't hurt. Nix comes with Let's Encrypt support out of the box, so it's ridiculously easy to set it up. The `enableACME` option will cause NixOS to start `certbot`, set up the challenge, and register it for your host (given it's mapped to a real domain). It will also take care of running it as a service to renew the certificate when needed.

The `forceSSL` option will redirect every HTTP request to their HTTPS counterpart.

`webserver.nix` (continuing):
```
                forceSSL = true;
                enableACME = true;
            };
```

We respect our elders, so we make sure `www.target.example.com` works as well. Redirects are not supported by the Nix configuration of Nginx, so we have to define it in native Nginx configuration. This is a [common pattern][nixos-opts-extraconfig]: the `extraConfig` option will append a line into the native configuration file in the correct scope.

`webserver.nix` (continuing):
```
            "www.target.example.com" = {
                forceSSL = true;
                enableACME = true;
                locations."/".extraConfig = "return 301 $scheme://target.example.com$request_uri;";
            };
        };
    };
```

Finally, we need a way to deploy our content to the webserver. Obviously we don't want to log in as root, thus we create a user who owns the document root which can be used for deployment.

This will create a user when our configuration is deployed and add the supplied public key to it's authorized keys.

`webserver.nix` (continuing):
```
    users.extraUsers.www-deploy = {
        isNormalUser = true;
        home = "/var/www/";
        openssh.authorizedKeys.keys = [ "ssh-rsa <your public key>" ];
    };
}
```

## Deployment

Now we create the network in NixOps and set up the SSH keys for deployment. It's advisable to give it a friendly name with `-d` otherwise we would have to refer to it by a UUID. We'll use `example`.

```
$ nixops create network.nix -dexample
```

*Note: this convoluted file structure is totally optional. NixOps just needs a a single Nix expression, it doesn't care how they are spread across files. We could also create a network by passing multiple filenames to `create` and it would combine them into one. This pattern is used in the [NixOps manual][nixops-manual-vbox].*

We're ready to deploy our configuration to the server. This will only work if there's a working domain (and a www domain) pointed to our target server - otherwise the ACME setup will fail, so the whole deployment. Thanks to the beauty of NixOS, if a deployment fails it's no biggie - our server will be rolled back to our previous working configuration and go on as nothing happened.

```
$ nixops deploy -dexample
```

If the deployment succeeds, our previous configuration will be taken over by the new one (no more root login wit password!). Otherwise we can enjoy our new webserver.

## What's next

Altough our OS configuration is immutable and reproducible, we're still far from the ideal. We still have to deploy our web content over SSH - which requires a manual step after the deployment and introduces a mutable state.

In a future article, I'll go one step further and package the website content itself in a Nix package so the whole deployment process can be covered with NixOps. Stay tuned!

[ramnode-product-page]: https://clientarea.ramnode.com/cart.php?gid=37
[nix-installation]: https://nixos.org/nix/download.html
[nix-manial-sets]: https://nixos.org/nixos/nix-pills/basics-of-language.html#idm140737316544992
[nixos-manual-ec2]: https://nixos.org/nixops/manual/#sec-deploying-to-ec2
[nixops-manual-vbox]: https://nixos.org/releases/nixops/latest/manual/manual.html#idm140737318606176
[nixos-opts-extraconfig]: https://nixos.org/nixos/options.html#extraconfig
