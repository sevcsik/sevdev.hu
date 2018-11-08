let pkgs = import <nixpkgs> {};
in
{
	networking.firewall.allowedTCPPorts = [ 22 ];

	users.extraUsers.www-deploy = { isNormalUser = true;
	                                home = "/var/www";
	                                openssh.authorizedKeys.keyFiles = [ ./www-deploy-rsa-local.pub
	                                                                    ./www-deploy-rsa-ci.pub
	                                                                  ];
	                              };

	security.sudo.configFile = ''
		www-deploy ALL = (root) NOPASSWD: ${pkgs.systemd}/bin/systemctl reload httpd.service
	'';

	services.openssh.enable = true;
}
