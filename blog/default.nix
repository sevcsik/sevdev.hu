{ stdenv, generator ? import ../generator/release.nix }:
stdenv.mkDerivation rec {
	name = "sevdev-blog";
	version = "1";
	src = ./.;
	phases = "buildPhase";
	buildInputs = [ generator ];
	buildPhase = ''
		site build
		mkdir $out
		cp -r site/* $out
	'';

	meta = {
		license = stdenv.lib.licenses.gpl3;
	};
}
