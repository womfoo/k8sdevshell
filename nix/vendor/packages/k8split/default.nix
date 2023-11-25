{ buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  name = "k8split";

  src = fetchFromGitHub {
    repo = "k8split";
    owner = "brendanjryan";
    rev = "7469c28221ff3e9a7d3fd20581a35005ddfd6d58";
    sha256 = "sha256-0cbTjzVRSYhopFyv+JgXoXgYugKgtur+8cgirhLJS98=";
  };

  vendorHash = "sha256-L0CdTy6dIpamnnNech078NWApafoVjjjyM83Cv5lbUo=";

  meta.description =
    "A CLI for splitting multidocument yaml files into discrete documents";

}
