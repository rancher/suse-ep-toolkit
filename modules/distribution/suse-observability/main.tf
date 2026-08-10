resource "null_resource" "create_suse_observability_rancher_oidc" {
  count      = var.suse_observability_rancher_auth ? 1 : 0
  depends_on = [null_resource.suse_obs_tls_secret]
  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${var.kubeconfig_path}
      kubectl patch feature oidc-provider --type merge -p '{"spec":{"value":true}}'
      until kubectl get crd oidcclients.management.cattle.io > /dev/null 2>&1 ; do echo "OIDCClient crd is not ready yet, sleeping 10s" && sleep 10s; done
      kubectl apply -f - <<EOF
      apiVersion: management.cattle.io/v3
      kind: OIDCClient
      metadata:
        name: oidc-observability
      spec:
        tokenExpirationSeconds: 600
        refreshTokenExpirationSeconds: 3600
        redirectURIs:
          - "https://${var.suse_observability_host}/loginCallback?client_name=StsOidcClient"
      EOF
    EOT
  }
}

data "external" "suse_observability_oidc_rancher" {
  count      = var.suse_observability_rancher_auth ? 1 : 0
  depends_on = [null_resource.create_suse_observability_rancher_oidc]
  program = ["bash", "-c", <<EOT
    export KUBECONFIG=${var.kubeconfig_path}
    sleep 30s
    CLIENT_ID=$(kubectl get oidcclients.management.cattle.io oidc-observability -o jsonpath='{.status.clientID}')
    CLIENT_SECRET=$(kubectl get secret $CLIENT_ID -n cattle-oidc-client-secrets -o jsonpath='{.data.client-secret-1}' | base64 -d)
    echo "{\"client_id\": \"$CLIENT_ID\", \"client_secret\": \"$CLIENT_SECRET\"}"
  EOT
  ]
}

resource "helm_release" "suse_observability" {
  count            = var.suse_observability_enabled ? 1 : 0
  depends_on       = [null_resource.suse_obs_tls_secret, data.external.suse_observability_oidc_rancher]
  name             = "suse-observability"
  repository       = "https://charts.rancher.com/server-charts/prime/suse-observability"
  chart            = "suse-observability"
  namespace        = "suse-observability"
  create_namespace = true
  timeout          = 1200
  version          = var.suse_observability_hc_version
  values = [
    templatefile("${path.module}/suse-observability-values.yaml.tpl", {
      license        = var.suse_observability_license
      host           = var.suse_observability_host
      otlp_host      = var.suse_observability_otlp_host
      otlp_http_host = var.suse_observability_otlp_http_host
      admin_password = var.suse_observability_admin_password
      profile        = var.suse_observability_profile
      rancher_auth   = var.suse_observability_rancher_auth
      client_id      = var.suse_observability_rancher_auth ? data.external.suse_observability_oidc_rancher[0].result.client_id : ""
      client_secret  = var.suse_observability_rancher_auth ? data.external.suse_observability_oidc_rancher[0].result.client_secret : ""
      rancher_host   = var.rancher_host
    })
  ]
}
