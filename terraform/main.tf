terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

resource "kubernetes_namespace" "ns" {
  metadata {
    name = "devops-challenge"
  }
}

resource "kubernetes_resource_quota" "rq" {
  metadata {
    name      = "memory-limit"
    namespace = kubernetes_namespace.ns.metadata[0].name
  }
  spec {
    hard = {
      "limits.memory" = "512Mi"
    }
  }
}