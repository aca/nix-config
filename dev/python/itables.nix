# itables.nix
{
  lib,
  buildPythonPackage,
  hatchling,
  hatch-jupyter-builder,
  python,
  fetchPypi,
  setuptools,
  wheel,
}:
buildPythonPackage rec {
  pname = "itables";
  version = "2.4.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-S5HASUVfqTny+Vu15MYSSrEffCaJuL7UhDOc3eudVWI=";
  };

  # do not run tests
  doCheck = false;

  build-system = [
    hatchling
  ];

  dependencies = with python.pkgs; [
    hatch-jupyter-builder
    pyyaml
    dash
  ];

  nativeBuildInputs = with python.pkgs; [
    hatch-vcs
    pkgs.nodejs
    hatchling
  ];

  # Force legacy setup.py mode to avoid pyproject.toml issues
  # specific to buildPythonPackage, see its reference
  pyproject = true;
}
