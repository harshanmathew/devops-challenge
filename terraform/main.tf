resource "kubernetes_namespace" "devops_challenge" {
  metadata {
    name = "devops-challenge"
  }
}

resource "kubernetes_resource_quota" "mem_limit" {
  metadata {
    name      = "mem-limit"
    namespace = kubernetes_namespace.devops_challenge.metadata[0].name
  }

  spec {
    hard = {
      "requests.memory" = "512Mi"
      "limits.memory"   = "512Mi"
    }
  }
}
