{ inputs, cell, }: {

  netrc2env = inputs.nixpkgs.callPackage ./netrc2env.nix { };

}
