{ config, pkgs, ... }:
{
	networking.firewall.allowedTCPPorts = [ 80 443 ];

	services.hydra = {
		enable = true;
		hydraURL = "https://hydra.sevdev.hu";
		notificationSender = "hydra@sevdev.hu";
		useSubstitutes = true;
	};

	services.nginx = {
		enable = true;
		virtualHosts = {
			"hydra.sevdev.hu" = {
				forceSSL = true;
				enableACME = true;
				locations."/".extraConfig = ''
					proxy_pass http://localhost:3000;
					proxy_set_header  Host              $host;
					proxy_set_header  X-Forwarded-Proto $scheme;
					proxy_set_header  X-Real-IP         $remote_addr;
					proxy_set_header  X-Forwarded-For   $proxy_add_x_forwarded_for;
				'';
			};
		};
	};
}
