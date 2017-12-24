{ mkDerivation, base, hakyll, stdenv, unordered-containers }:
mkDerivation {
  pname = "sevdev-site-generator";
  version = "1";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base hakyll unordered-containers ];
  license = stdenv.lib.licenses.gpl3;
  shellHook = ''
	cp -rv templates $out
	'';
}
