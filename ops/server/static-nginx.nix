{ config, pkgs, ... }:

let blog = import ../../blog/release.nix;
    resume = import ../../resume/release.nix;
in {
	networking.firewall.allowedTCPPorts = [ 80 443 ];

	services.nginx = {
		enable = true;
		virtualHosts = {
			"sevdev.hu" = {
				forceSSL = true;
				enableACME = true;
				root = "${blog}";

				locations."/resume" = {
					alias = "${resume}";
				};

				# To not break old IPFS URLs
				extraConfig = "location ~ \"^/ipns/sevdev\\.hu(.*)$\" {"
				            + "  return 301 $scheme://$host$1;"
				            + "}";
			};
			
			"www.sevdev.hu" = {
				forceSSL = true;
				enableACME = true;

				locations."/" = {
					extraConfig = "return 301 $scheme://sevdev.hu$1;";
				};
			};
		};
	};
}
