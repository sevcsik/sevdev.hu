--------------------------------------------------
title: Front-end CD with NixOps and HTTPD (part 2)
--------------------------------------------------

*This post is the continuation of my previous [post][prev-post].*

In the previous post about continuous deployment, we set up Apache HTTPD with NixOps to host a version of your front-end
webapp on a different subdomain. Besides that, we also wrote a shell script that gathers the necessary metadata from
Git, create a virtual host config, and deploy it to HTTPD.

The next step is to set up a simple CI environment (Jenkins) in a way that it deploys the branches on every new commit.

<!-- TEASER -->

# Setting up Jenkins

It's quite easy to run Jenkins, we just need to enable the Jenkins service on our machine and open the port it will
listen on.

We also need to have git installed so we can invoke it from our deploy script.

<pre class="sourceCode">
# ops/sandbox/jenkins.nix
let pkgs = import <nixpkgs> {};
in
{
	environment.systemPackages = with pkgs; [ git ];
	networking.firewall.allowedTCPPorts = [ 8080 ];
	services.jenkins.enable = true;
}
</pre>

You can check the [available options for Jenkins][jenkins-options] for more options, but it should work with just these
two lines. After deploy, just open `http://sandbox.example.com:8080` and follow the Jenkins setup.

# Creating the job

Now we can create a Jenkins job. In this tutorial, we'll use the [Jenkins Github Plugin][github-plugin] just to make
things easy (it will set up the necessary repository hooks automatically). Just configure it with your credentials
based on the documentation.

We create a "freestyle" project 

[github-plugin]: https://wiki.jenkins.io/display/JENKINS/Github+Plugin

