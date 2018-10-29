{ config, pkgs, ... }:
{
	imports = [ ../hardware/ramnode-kvm.nix
	            ./static-nginx.nix
	          ];
	
	deployment.targetHost = "rn1.sevdev.hu";
	networking.hostName = "rn1.sevdev.hu";
}
