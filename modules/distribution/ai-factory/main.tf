resource "helm_release" "ai_factory" {
  count            = var.ai_factory_enabled ? 1 : 0
  name             = "aif-operator"
  namespace        = "aif-operator"
  repository       = "oci://ghcr.io/suse/chart"
  chart            = "aif-operator"
  create_namespace = true
  timeout          = 1200
  version          = var.ai_factory_hc_version
  values = [
    yamlencode({
      credentials = merge(
        var.app_collection_password != null && var.app_collection_password != "" ? {
          applicationCollection = {
            username = var.app_collection_username
            password = var.app_collection_password
          }
        } : {},
        var.nvidia_password != null && var.nvidia_password != "" ? {
          nvidia = {
            username = "$oauthtoken"
            password = var.nvidia_password
          }
        } : {},
        var.suse_registry_password != null && var.suse_registry_password != "" ? {
          suseRegistry = {
            username = "regcode"
            password = var.suse_registry_password
          }
        } : {}
      )
    })
  ]
}
