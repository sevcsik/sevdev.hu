{
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    services.nginx = {
        enable = true;
        virtualHosts = {
            "rn2.sevdev.hu" = {
                locations."/".root = "/var/www/rn2.sevdev.hu";
                forceSSL = true;
                enableACME = true;
            };
             "www.rn2.sevdev.hu" = {
                 forceSSL = true;
                 enableACME = true;
                 locations."/".extraConfig = "return 301 $scheme://rn2.sevdev.hu$request_uri;";
             };
        };
    };
    users.extraUsers.www-deploy = {
        isNormalUser = true;
        home = "/var/www/";
        openssh.authorizedKeys.keys = [ "ssh-rsa <your public key>" ];
	};
}
