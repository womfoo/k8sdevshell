{ inputs, cell, }: {
  k8split = inputs.nixpkgs.callPackage ./k8split/default.nix { };
}
