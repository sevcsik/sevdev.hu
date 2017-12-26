{ pkgs, stdenv }:

let
	dependencies = pkgs.callPackage ./dependencies.nix { };
	ignores = [ "node_modules" "bower_components" "dist" "result" ];
in
stdenv.mkDerivation rec {
	name = "sevdev-resume";
	version = "1";
	src = builtins.filterSource
		(path: _: builtins.foldl' (acc: el: acc && builtins.baseNameOf path != el) true ignores)
		./.;
	phases = "unpackPhase buildPhase";
	buildInputs = [ pkgs.nodejs-8_x ];
	buildPhase = ''
		ln -s ${dependencies}/node_modules .
		ln -s ${dependencies}/bower_components .
		node_modules/.bin/gulp
		mkdir $out
		mv dist/* $out
	'';

	meta = {
		license = stdenv.lib.licenses.mit;
	};
}
