{
	networking.firewall.allowedTCPPorts = [ 80 443 ];

	services.httpd = { adminAddr = "sevcsik@sevdev.hu";
	                   enable = true;
	                   extraConfig = "IncludeOptional /var/www/vhosts/*.conf";
	                 };
}
