{ stdenv, generator ? (import ../generator/release.nix).build }:
let ignores = [ "_cache" "_site" "result" ];
in stdenv.mkDerivation rec {
	name = "sevdev-blog";
	version = "1";
	src = builtins.filterSource
		(path: _: builtins.foldl' (acc: el: acc && builtins.baseNameOf path != el) true ignores) ./.;
	phases = "unpackPhase buildPhase";
	buildInputs = [ generator ];
	buildPhase = ''
		export LANG="en_GB.UTF-8"
		export LC_ALL="en_GB.UTF-8"
		chmod -R u+w *
		site rebuild
		mkdir $out
		cp -r _site/* $out
	'';

	meta = {
		license = stdenv.lib.licenses.gpl3;
	};
}
