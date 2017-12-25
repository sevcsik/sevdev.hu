{ stdenv, generator ? import ../generator/release.nix }:
stdenv.mkDerivation rec {
	name = "sevdev-blog";
	version = "1";
	src = ./.;
	phases = "buildPhase";
	buildInputs = [ generator ];
	buildPhase = ''
		export LC_ALL="en_GB.UTF-8"
		for dir in `find $src -type d -maxdepth 1`; do cp -rv $dir .; done
		chmod -R u+w *
		site rebuild
		mkdir $out
		cp -r _site/* $out
	'';

	meta = {
		license = stdenv.lib.licenses.gpl3;
	};
}
