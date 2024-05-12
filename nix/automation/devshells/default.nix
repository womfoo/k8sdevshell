{
  inputs,
  cell,
}: let
  inherit (inputs) nixpkgs std cells;
  inherit (std.lib.dev) mkShell mkNixago;
in {
  default = mkShell {
    name = "your k8s devshell";
    nixago = with std.data.configs; [
      (mkNixago treefmt)
      (mkNixago lefthook)
    ];
    packages = [
      nixpkgs.terraform-providers.helm
      nixpkgs.terraform-providers.kubectl
      nixpkgs.terraform-providers.kubernetes
      cells.cd.packages.netrc2githubenv
      (nixpkgs.pkgs.writeShellScriptBin "nuke-k3s-resources-from-orbit" ''
         kubectl delete -n argocd -f ${inputs.argo}
         kubectl delete namespace argocd
         helm uninstall external-secrets --namespace external-secrets
         helm uninstall kubernetes-secret-generator --namespace kubernetes-secret-generator
         helm uninstall apisix --namespace ingress-apisix
      '')
    ];
    commands = [
      {
        category = "nix";
        package = std.packages.default;
      }
      {package = nixpkgs.jq;}
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
        package = nixpkgs.hcl2json;
      }
    ];
  };
}
