{
  description = "devshell for k3s on nixos";

  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

  inputs.std = {
    url = "github:divnix/std";
    # url = "git+file:///home/kranium/git/github.com/divnix/std";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.devshell.follows = "devshell";
    inputs.nixago.follows = "nixago";
  };

  inputs.devshell = {
    url = "github:numtide/devshell";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixago = {
    url = "github:nix-community/nixago";
    inputs.nixpkgs.follows = "nixpkgs";
    inputs.nixago-exts.follows = "";
  };

  inputs.terranix = {
    url = "github:terranix/terranix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  # FIXME: ff components fail when deploying namespace variant
  # argocd-server
  # argocd-applicationset-controller
  # argocd-application-controller
  # inputs.argo.url = "https://raw.githubusercontent.com/argoproj/argo-cd/v2.11.0/manifests/namespace-install.yaml";
  inputs.argo.url = "https://raw.githubusercontent.com/argoproj/argo-cd/v2.11.0/manifests/install.yaml";
  inputs.argo.flake = false;

  outputs = {
    std,
    self,
    ...
  } @ inputs:
    std.growOn {
      inherit inputs;
      cellsFrom = ./nix;
      cellBlocks = with std.blockTypes; [
        (devshells "devshells")
        (installables "packages")
        (kubectl "kubectl")
        (terra "terra" "ssh:kranium@git.gikos.net:/srv/git/k3s-tf-state")
        # (terra "terra" "https://github.com/womfoo/k8sdevshell-state")
      ];
      nixpkgsConfig = {allowUnfree = true;};
    } {
      devShells = inputs.std.harvest inputs.self ["automation" "devshells"];
    };
}
