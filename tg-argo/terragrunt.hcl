generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
provider "kubernetes" {
  config_path    = "/etc/rancher/k3s/k3s.yaml"
  config_context = "default"
}

provider "kubectl" {
  config_path    = "/etc/rancher/k3s/k3s.yaml"
  config_context = "default"
}

provider "helm" {
  kubernetes {
    config_path    = "/etc/rancher/k3s/k3s.yaml"
    config_context = "default"
  }
}
EOF
}

terraform {
  source = "/home/kranium/tf/argocd"
}

locals {
}

inputs = {
  enabled      = true
  cluster-name = "dummy"
  namespace    = "argocd"
  root_apps = {
    root = {
      name       = "root"
      auto_sync  = true
      path       = "k3s"
      repository = "https://local.kranium.au/argo"
      revision   = "main"
    }
  }
}
