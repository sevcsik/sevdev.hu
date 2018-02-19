{ config, pkgs, ... }:
{
	imports = [ hardware/ramnode-kvm.nix
	            server/static-nginx.nix
	            security/admin-ssh.nix
	          ];
	
	deployment.targetHost = "rn1.sevdev.hu";
	networking.hostName = "rn1.sevdev.hu";
}
