{ inputs, cell }:
let
  kubernetes = {
    config_context = "default";
    config_path = "/etc/rancher/k3s/k3s.yaml";
  };
in {
  helm_charts = {
    # meta.description = "all charts to bootstrap k8s"; # breaks std
    terraform.required_providers.kubectl.source = "alekc/kubectl";
    provider = {
      kubectl = { inherit (kubernetes) config_context config_path; };
      inherit kubernetes;
      helm = { inherit kubernetes; };
    };
    resource = {
      helm_release.external-secrets = {
        chart = "external-secrets";
        create_namespace = true;
        name = "external-secrets";
        namespace = "external-secrets";
        repository = "https://charts.external-secrets.io";
        set.name = "installCRDs";
        set.value = "true";
        # values = [];
        values = [
          (inputs.nixpkgs.lib.generators.toYAML { } {
            applicationSet.enabled = true;
            config.secret.argocdServerAdminPassword = "letmein";
            controller.replicaCount = 1;
            notifications.enabled = true;
            repoServer.replicaCount = 1;
          })
        ];
        version = "0.9.9";
      };
    };
  };
}
