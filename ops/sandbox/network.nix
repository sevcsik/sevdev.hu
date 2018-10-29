{
	webserver-cd = { deployment.targetHost = "rn2.sevdev.hu";
	                 networking.hostName = "rn2.sevdev.hu";
	                 imports = [ ./ramnode-kvm.nix
	                             ./security.nix
	                             ./webserver.nix
	                           ];
	               };

	network.description = "sevdev dev env";
}
