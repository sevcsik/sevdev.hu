{ mkDerivation, base, hakyll, stdenv, unordered-containers }:
mkDerivation {
  pname = "sevdev-hakyll";
  version = "0.0.0.0";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  executableHaskellDepends = [ base hakyll unordered-containers ];
  license = stdenv.lib.licenses.mit;
}
