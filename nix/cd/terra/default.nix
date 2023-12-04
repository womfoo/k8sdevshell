{ inputs, cell }:
let
  kubernetes = {
    config_context = "default";
    config_path = "/etc/rancher/k3s/k3s.yaml";
  };
  file = f: "\${file(\"${f}\")}";
  var = v: "\${${v}}";
in {
  helm_charts = {
    # meta.description = "all charts to bootstrap k8s"; # breaks std
    terraform.required_providers.kubectl.source = "alekc/kubectl";
    provider = {
      kubectl = { inherit (kubernetes) config_context config_path; };
      inherit kubernetes;
      helm = { inherit kubernetes; };
    };
    data = {
    # https://registry.terraform.io/providers/alekc/kubectl/latest/docs/data-sources/kubectl_file_documents
      kubectl_file_documents.argoyamls.content = file inputs.argo;
    };
    resource = {
      kubectl_manifest.argoyamls = {
        for_each  = var "data.kubectl_file_documents.argoyamls.manifests"; # FIXME: make {config: ...} work
        yaml_body = var "each.value";
        override_namespace = "argocd";
        depends_on = [
          "kubernetes_namespace.argocd"
        ];
      };
      kubernetes_namespace.argocd.metadata.name = "argocd";
      helm_release.external-secrets = {
        chart = "external-secrets";
        create_namespace = true;
        name = "external-secrets";
        namespace = "external-secrets";
        repository = "https://charts.external-secrets.io";
        set.name = "installCRDs";
        set.value = "true";
        values = [];
        version = "0.9.9";
      };
    };
  };
}
