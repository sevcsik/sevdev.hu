let pkgs = import <nixpkgs> {};
in
{
	services.httpd.virtualHosts = [
		{ hostName = "jenkins.sevdev.hu";
		  extraConfig =
			''
			ProxyPass "/" "http://localhost:8080/" nocanon
			ProxyPassReverse "/" "http://localhost:8080/"
			ProxyRequests Off
			AllowEncodedSlashes NoDecode
			'';
		}
	];

	environment.systemPackages = with pkgs; [ git ];

	services.jenkins.enable = true;
}

