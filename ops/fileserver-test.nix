{ config, pkgs, ... }:
{
	imports = [ hardware/ramnode-kvm.nix
	            server/static-nginx.nix
	            security/admin-ssh.nix
	          ];
	
	deployment.targetHost = "rn2.sevdev.hu";
	networking.hostName = "rn2.sevdev.hu";
}
