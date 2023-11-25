{ inputs, cell, }:
let inherit (inputs) nixpkgs std cells;
in {
  default = std.lib.dev.mkShell {
    name = "your k8s devshell";
    packages = [
      nixpkgs.terraform-providers.helm
      nixpkgs.terraform-providers.kubectl
      nixpkgs.terraform-providers.kubernetes
    ];
    commands = [
      {
        category = "nix";
        package = std.packages.default;
      }
      {
        category = "nix";
        package = nixpkgs.nixfmt;
      }
      { package = nixpkgs.jq; }
      {
        category = "kubernetes";
        package = cells.vendor.packages.k8split;
      }
      {
        category = "kubernetes";
        package = nixpkgs.k9s;
      }
      {
        category = "terraform";
        package = nixpkgs.terraform;
      }
      {
        category = "terraform";
        package = nixpkgs.terragrunt;
      }
    ];
  };
}
