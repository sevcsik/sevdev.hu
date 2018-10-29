{
	networking.firewall.allowedTCPPorts = [ 80 443 ];

	services.httpd = { adminAddr = "sevcsik@sevdev.hu";
	                   enable = true;
	                   extraConfig = "IncludeOptional /var/www/vhosts/*.conf";
	                 };

	services.httpd.virtualHosts = [
		{ hostName = "jenkins.sevdev.hu";
		  extraConfig =
			''
			ProxyPass "/" "http://localhost:8080/"
			ProxyPassReverse "/" "http://localhost:8080/"
			'';
		}
	];

	services.jenkins.enable = true;
}
