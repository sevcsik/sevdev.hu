{ pkgs, stdenv }:
let sources = [ "package.json" "bower.json" "package-lock.json" ];
in stdenv.mkDerivation {
	name = "sevdev-resume-node-modules";
	src = builtins.filterSource 
		(path: _: builtins.foldl' (acc: el: acc || builtins.baseNameOf path == el) false sources)
		./.;
	buildInputs = with pkgs; [ nodejs-8_x git ];
	phases = "unpackPhase buildPhase";
	buildPhase = ''
		export HOME='.'
		export GIT_SSL_CAINFO=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt
		echo npm install...
		npm install
		echo bower install...
		node_modules/bower/bin/bower install
		mkdir $out
		mv node_modules $out
		mv bower_components $out
	'';
}
