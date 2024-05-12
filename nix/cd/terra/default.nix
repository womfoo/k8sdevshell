{
  inputs,
  cell,
}: let
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
      kubectl = {inherit (kubernetes) config_context config_path;};
      inherit kubernetes;
      helm = {inherit kubernetes;};
    };
    data = {
      # https://registry.terraform.io/providers/alekc/kubectl/latest/docs/data-sources/kubectl_file_documents
      kubectl_file_documents.argoyamls.content = file inputs.argo;
    };
    resource = {
      kubectl_manifest.argoyamls = {
        for_each = var "data.kubectl_file_documents.argoyamls.manifests"; # FIXME: make {config: ...} work
        yaml_body = var "each.value";
        override_namespace = "argocd";
        depends_on = [
          "kubernetes_namespace.argocd"
        ];
      };
      kubernetes_namespace.argocd.metadata.name = "argocd";

      kubectl_manifest.argorootapp = let
        name = "root";
        namespace = "argocd";
        path = "k3s";
        repository = "https://github.com/womfoo/k3s-argo-root";
        revision = "main";
      in {
        yaml_body = ''
          apiVersion: argoproj.io/v1alpha1
          kind: Application
          metadata:
            name: ${name}
            namespace: ${namespace}
            finalizers:
            - resources-finalizer.argocd.argoproj.io
            labels:
              type: app-of-apps
              team: platform-engineering
          spec:
            destination:
              server: https://kubernetes.default.svc
              namespace: argocd
            project: default
            source:
              path: ${path}
              repoURL: ${repository}
              targetRevision: ${revision}
            syncPolicy:
              automated:
                prune: true
                selfHeal: true
              syncOptions:
                - Validate=true
                - PrunePropagationPolicy=foreground
                - PruneLast=true
              retry:
                limit: 5
                backoff:
                  duration: 5s
                  factor: 2
                  maxDuration: 3m
        '';
      };
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

      helm_release.kubernetes-secret-generator = {
        chart = "kubernetes-secret-generator";
        create_namespace = true;
        name = "kubernetes-secret-generator";
        namespace = "kubernetes-secret-generator";
        repository = "https://helm.mittwald.de";
        # values = [];
        version = "3.4.0";
      };

      helm_release.apisix = {
        chart = "apisix";
        create_namespace = true;
        name = "apisix";
        namespace = "ingress-apisix";
        repository = "https://apache.github.io/apisix-helm-chart";
        values = let
          adminKey = "myadminpassword";
          viewerKey = "myviewerpassword";
          in [
          ''
            ingress-controller:
              enabled: true
            service:
              type: NodePort
            admin:
              credentials:
                admin: ${adminKey}
                viewer: ${viewerKey}
          ''
        ];
        version = "2.7.0";
      };
    };
  };
}
