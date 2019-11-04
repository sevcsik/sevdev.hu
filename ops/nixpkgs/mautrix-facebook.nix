# based on mautrix-telegram nix expresseion
{ lib, python3, mautrix-telegram, file }:

with python3.pkgs;

buildPythonPackage rec {
  pname = "mautrix-telegram";
  version = "0.6.1";

  src = fetchPypi {
    inherit pname version;
    sha256 = "1lsi6x5yr8f9yjxsh1rmcd6wnxr6s6rpr720lg7sq629m42d9p1d";
  };

  postPatch = ''
    sed -i -e '/alembic>/d' setup.py
  '';

  propagatedBuildInputs = [
    aiohttp
    sqlalchemy
    alembic
    ruamel_yaml
    commonmark
    python-magic
    mautrix
    fbchat-asyncio
    setuptools
    file
  ];

  # `alembic` (a database migration tool) is only needed for the initial setup,
  # and not needed during the actual runtime. However `alembic` requires `mautrix-facebook`
  # in its environment to create a database schema from all models.
  #
  # Hence we need to patch away `alembic` from `mautrix-facebook` and create an `alembic`
  # which has `mautrix-telegram` in its environment.
  passthru.alembic = alembic.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      mautrix-facebook
    ];
  });

  checkInputs = [
    pytest
    pytestrunner
    pytest-mock
    pytest-asyncio
  ];

  meta = with lib; {
    homepage = https://github.com/tulir/mautrix-facebook;
    description = "A Matrix-Facebook Messenger puppeting bridge.";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ nyanloutre ma27 ];
  };
}

