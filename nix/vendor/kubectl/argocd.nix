{ stdenv, pkgs, lib, fetchFromGitHub }:

stdenv.mkDerivation rec {
  name = "argo-cd-crds";
  version = "1.0"; # Specify a version if needed

  src = fetchFromGitHub {
    owner = "argoproj";
    repo = "argo-cd";
    rev = "v2.9.3"; # stable 2023-12-01
    hash = "0aaa2332dw4wcxn53b38rl7mbyb5bh5vl3dfhschjb100g61a979";
    # sourceRoot = "manifests/crds";
  };
}
