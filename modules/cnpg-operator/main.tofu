resource "helm_release" "cnpg_operator" {
  name       = "cnpg-operator"
  repository = "https://cloudnative-pg.github.io/charts"
  chart      = "cloudnative-pg"
  version    = "0.26.0"
}