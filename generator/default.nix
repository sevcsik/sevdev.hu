{ mkDerivation, base, directory, filepath, hakyll, stdenv
, unordered-containers
}:
mkDerivation {
  pname = "sevdev-site-generator";
  version = "1";
  src = ./.;
  isLibrary = false;
  isExecutable = true;
  enableSeparateDataOutput = true;
  executableHaskellDepends = [
    base directory filepath hakyll unordered-containers
  ];
  license = stdenv.lib.licenses.mit;
}
