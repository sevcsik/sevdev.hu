--------------------------------------------------
title: Front-end CD with NixOps and HTTPD (part 1)
--------------------------------------------------

When working in large, distributed teams, it's often easier to just pass a URL to each other where a working deployment
of an application can be tested for a given branch. It's not just convenient but also helps to avoid the "works on my
machine" kind of errors.

If automated end-to-end testing is involved, a continuously deployed development environment is no longer just for
convenience, but a necessity. Automated tests running in the CI environment must have a working instance of the
software for any given branch in order to be executed.

In this post, I will walk you through how to set up the front-end code's continuous delivery with NixOps and Apache
HTTPD.

<!-- TEASER -->

You can find the concrete implementation for my blog in this [git commit][commit].

# Overview

Our goal: Every time when a new commit is pushed to a branch, we want to view our application on that branch at
`<branch-name>.sandbox.example.com`. 

For the purpose of this post, we will only care about the front-end code (statically served resources), excluding
the back-end. Also, for the sake of simplicity, we'll serve the development environments on HTTP.

Our setup will look like the following:

 - We have a single Apache HTTPD instance on `sandbox.example.com`.
 - Each branch will have a `VirtualHost` for `<branch-name>.sandbox.example.com`.
 - On every commit, we'll upload the front-end content to the given `VirtualHost`'s `DocumentRoot`.

# Setting up the infrastructure

## Server

We need to set up a simple NixOS box with the default configuration. You can check [my earlier blog post][nixops-static]
about how to set up a NixOS box and NixOps. We don't need to deploy any services to it right now; we'll define them
later.

I'll use the IP address of [`203.0.113.1`][example-ip] as the node's public IP.

## DNS

First of all, we need every subdomain to be mapped to the same server as `sandbox.example.com`. Assuming that you are
the administrator of `example.com`, you can set up a catch-all A/AAAA record pointing to your NixOS instance.

I'll use [Linode's DNS manager][linode-dns] for the examples, but it should work for other DNS providers as well.
If you're not in a position to edit the zone file for your domain (e.g. on a centrally managed corporate network), you
can set up a different port for each virtual host instead.

Since we'll manage two levels of domains, we cannot use `example.com`'s zone. Instead, we create a new zone file for
`sandbox.example.com`, by going to *DNS Manager* / *Add a Zone* / *Add a Master Zone* with the domain
`sandbox.example.com`.

Then we open our newly created zone file and add the following A records (and their AAAA counterpart if your hosting
provider supports IPv6):

 - hostname: `sandbox.example.com`; IP address: `203.0.113.1`
 - hostname: `*.sandbox.example.com`; IP address: `203.0.113.1`

When done, your zone file should look like this:

<pre class="sourceCode">
; sandbox.example.com [???]
$TTL 86400
@	IN	SOA	ns1.linode.com. username.example.com. 2018102880 14400 14400 1209600 86400
@		NS	ns1.linode.com.
@		NS	ns2.linode.com.
@		NS	ns3.linode.com.
@		NS	ns4.linode.com.
@		NS	ns5.linode.com.
@			A	203.0.113.1
*			A	203.0.113.1
</pre>

Once you save the changes, it will take a few minutes until the zone get's updated. We can check if it worked with
`dig`:

<pre class="sourceCode">
$ dig +nocomments foobar.sandbox.example.com
; <<>> DiG 9.12.1-P2 <<>> +nocomments foobar.sandbox.example.com
;; global options: +cmd
;foobar.sandbox.example.com.          IN      A
foobar.sandbox.example.com.   51535   IN      A       203.0.113.1
;; Query time: 28 msec
;; SERVER: 208.67.222.222#53(208.67.222.222)
;; WHEN: Mon Oct 29 12:12:57 CET 2018
;; MSG SIZE  rcvd: 65
</pre>

# Configuring the server with NixOps

*Note: if you don't want to use NixOS / NixOps, feel free to skip this section. The setup should work with any Apache
HTTPD setup, given the virtual hosts are loaded from a directory, the `www-deploy` user and the SSH keys are in place.*

I will use the following directory structure for organising the NixOps configuration files. This is not absolutely
necessary, especially for a project this size, but it can come handy if the configuration gets bigger as the environment
grows.

<pre class="sourceCode">
$ tree ops/sandbox
ops/sandbox
├── network.nix        # The top-level network config
├── hardware.nix       # Harware-specific config, generated
├── security.nix       # Users, SSH setup
├── webserver.nix      # Apache HTTPD config
└── www-deploy-rsa.pub # public key for www-deploy user
</pre>

## Apache HTTPD

It's quite trivial to set up an Apache HTTPD server with NixOps as most of the configuration is generated automatically
by NixOS. We need one additional line of configuration, which will include every `VirtualHost` config file from the
`/var/www/vhosts` directory. We will deploy our `VirtualHost` definitions in this directory later.

<pre class="sourceCode">
# ops/sandbox/webserver.nix

{
	networking.firewall.allowedTCPPorts = [ 80 ];

	services.httpd =
		{ adminAddr = "sevcsik@sevdev.hu";
		  enable = true;
		  extraConfig = "IncludeOptional /var/www/vhosts/*.conf";
		};
}
</pre>

## Security

We'll need a user which can copy the virtual host definitions and the resources to the `/var/www` directory. Since our
CI will run in a non-interactive shell, and we don't like passwords stored as code, we'll use public key authentication.

Fortunately, NixOS allows us to put an SSH public key into the `authorizedKeys` file of the user. This public key can be
referenced as a file, which will be read by Nix when building the environment and will be added to the configuration.

Our user will be called `www-deploy`. Besides being able to write virtual hosts and the document roots for those
hosts, it also needs to be able to reload the HTTPD configuration, hence the sudoers rule.

Note the usage of `nixpkgs` here to get the path of `systemctl`. Since in NixOS every installation of every package has
a unique hash in their path, we cannot know build-time where the `systemctl` binary will be located. Thus, instead of
defining the absolute path of `systemctl` literally, we ask Nix to substitute the path of the `systemd` package in
the path.

<pre class="sourceCode">
# ops/sandbox/webserver.nix

let pkgs = import &lt;nixpkgs&gt; {};
in
{
	networking.firewall.allowedTCPPorts = [ 22 ];

	users.extraUsers.www-deploy =
		{ isNormalUser = true;
		  home = "/var/www";
		  openssh.authorizedKeys.keyFiles = [ ./www-deploy-rsa.pub ];
		};

	security.sudo.configFile = ''
		www-deploy ALL = (root) NOPASSWD: ${pkgs.systemd}/bin/systemctl reload httpd.service
	'';

	services.openssh.enable = true;
}
</pre>

## Hardware configuration

The hardware configuration Nix expression should be the one we generated with the NixOS installer when we set up the
NixOS box. See [my earlier blog post][nixops-static] for details.

## Network

Finally, we define a top-level network expression which combines these three configurations into one machine
configuration. For now, we will have only one machine in our network called `webserver-cd`.

<pre class="sourceCode">
# ops/sandbox/network.nix
{
	webserver-cd =
		{ deployment.targetHost = "sandbox.example.com";
		  networking.hostName = "sandbox.example.com";
		  imports = [ ./harwdare.nix
		              ./security.nix
		              ./webserver.nix
		            ];
		};

	network.description = "example.com dev env";
}
</pre>

If all done right, we can deploy this network configuration with NixOps:

<pre class="sourceCode">
$ nixops create -d devenv ops/sandbox/network.nix
$ nixops deploy -d devenv
</pre>

Since `/var/www` won't be readable by HTTPD, we have to update the permissions after creating the server using
`nixops ssh -d devenv webserver-cd`. This only has to be done for the first deployment.

# Deployment script

Now that we have a running server, we'll write a simple bash script which creates the virtual host definition and
deploys it to our server. We don't deal with building the application, we just assume that it's there in the `result`
directory when we run the script. (`nix-build` uses this directory: in case of Node.js, you'll probably have `dist`
instead, or `target` in case of Maven and friends.)

For now, we'll hard code a bunch of stuff in our script to begin with, as we will use this script manually (from the
same machine as where we deployed the server from). In a future post, we will modify this script to get its parameters
to work in a CI environment.

```bash
#!/usr/bin/env bash

# ./deploy.sh

SSH_USERNAME="www-deploy"
DEPLOY_HOSTNAME="sandbox.example.com"
SSH_ARGS=( "$SSH_USERNAME@$DEPLOY_HOSTNAME" )
PUBLIC_DOMAIN_PARENT="sandbox.example.com"
```

## Deploying the virtual host config

First, we generate the virtual host config file, which we'll deploy to the server's `/var/www/vhosts` directory using
our `www-deploy-rsa` private key generated on our client.

We set the domain name the server should listen on (`ServerName`) to the branch name converted to a
domain-friendly format (slashes and underscores replaced with dashes) and prepend it to our upper-level domain name.

Example:

The branch `feature/easter_egg` will be deployed to `feature-easter-egg.sandbox.example.com`.
The files will reside in `/var/www/feature-easter-egg.sandbox.example.com` in this case (`DocumentRoot`).

To aid the developer in identifying which commit do they see, we add an `X-Commit-Info` HTTP response header which
contains the short commit hash and the first line of the commit message.

```bash
# ./deploy.sh continued

CURRENT_BRANCH=`git rev-parse --abbrev-ref HEAD | sed -e "s/[-_\\/]/-/g"`
COMMIT_INFO=`git show -s --oneline`
TARGET_HOSTNAME=$CURRENT_BRANCH.$PUBLIC_DOMAIN_PARENT

echo Deploying VirtualHost for $TARGET_HOSTNAME on $SSH_USERNAME@$DEPLOY_HOSTNAME
ssh "${SSH_ARGS[@]}" "mkdir -p /var/www/vhosts"
ssh "${SSH_ARGS[@]}" "cat > /var/www/vhosts/$TARGET_HOSTNAME.conf" <<-EOF
	<VirtualHost *>
		DocumentRoot "/var/www/$TARGET_HOSTNAME/public"
		ServerName $TARGET_HOSTNAME
		ErrorLog "/var/www/$TARGET_HOSTNAME/logs/error.log"
		TransferLog "/var/www/$TARGET_HOSTNAME/logs/access.log"
		Header set X-Commit-Info "$COMMIT_INFO"
		<Directory /var/www/$TARGET_HOSTNAME/public>
			Require all granted
		</Directory>
	</VirtualHost>
EOF
```

## Deploying the front-end resources

We delete any preexisting deployment first before we deploy our resources. This way when a file is deleted, the old
file doesn't keep hanging around with the new ones in case of a new deployment.

After that, we can just simply SCP our `result` directory to the virtual host's document root (`public`). We need to
make sure to make all the files writable by the `www-deploy` user, otherwise, we would not be able to delete them on the
next deployment.

```bash
# ./deploy.sh continued

echo Deleting existing deployment
ssh "${SSH_ARGS[@]}" "rm -rv /var/www/$TARGET_HOSTNAME"

echo Deploying files to $TARGET_HOSTNAME
ssh "${SSH_ARGS[@]}" "mkdir -p /var/www/$TARGET_HOSTNAME/logs"
scp -rpi $SSH_PRIVKEY result $SSH_USERNAME@$DEPLOY_HOSTNAME:/var/www/$TARGET_HOSTNAME/public
ssh "${SSH_ARGS[@]}" "chmod -R u+w /var/www/$TARGET_HOSTNAME"
```

## Reloading the configuration

After everything's set up, we have to restart HTTPD. The `systemctl reload` command is the equivalent of
`apachectl graceful` - it will reload the config file only when the existing connections are closed (for some reason,
`apachectl` doesn't work on NixOS).

If we have any errors, this command will fail and we can examine the logs in an SSH session
(`nixops ssh -d devenv webserver-cd`). If we don't have any console output, it succeeded. We should be able to open
`http://<branch-name>.sandbox.example.com` and see our newly deployed web application.

```bash
# ./deploy.sh continued

echo Restarting httpd
ssh "${SSH_ARGS[@]}" "sudo systemctl reload httpd.service"
```

# What's next

Of course, this does not qualify as continuous deployment. Maybe "automated deployment" if we're being nice. In the
second part of this blog post, I will cover how to set up Jenkins to run this deploy script on every commit, thus
having a deployed version of every branch all the time.

[commit]: https://github.com/sevcsik/sevdev-hakyll/commit/01db6f9f3ff25452316e49b345dfdf7fe69775d6
[nixops-static]: https://sevdev.hu/posts/2017-12-26-discovering-nix-deploying-a-simple-nginx-with-nixops.html
[example-ip]: https://tools.ietf.org/html/rfc5737
[linode-dns]: https://www.linode.com/docs/platform/manager/dns-manager/
