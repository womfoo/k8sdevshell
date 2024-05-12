{
  inputs,
  cell,
}: {
  netrc2githubenv = inputs.nixpkgs.callPackage ./netrc2githubenv.nix {};
}
