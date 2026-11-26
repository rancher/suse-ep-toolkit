resource "random_password" "suse_observability_agent_key" {
  count   = var.suse_observability_enabled ? 1 : 0
  length  = 32
  special = false
}

resource "random_password" "suse_observability_bootstrap_token" {
  count   = var.suse_observability_enabled ? 1 : 0
  length  = 32
  special = false
}

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
    sensitive(templatefile("${path.module}/suse-observability-values.yaml.tpl", {
      license         = var.suse_observability_license
      host            = var.suse_observability_host
      otlp_host       = var.suse_observability_otlp_host
      otlp_http_host  = var.suse_observability_otlp_http_host
      admin_password  = var.suse_observability_admin_password
      api_key         = random_password.suse_observability_agent_key[0].result
      bootstrap_token = random_password.suse_observability_bootstrap_token[0].result
      profile         = var.suse_observability_profile
      rancher_auth    = var.suse_observability_rancher_auth
      client_id       = var.suse_observability_rancher_auth ? data.external.suse_observability_oidc_rancher[0].result.client_id : ""
      client_secret   = var.suse_observability_rancher_auth ? data.external.suse_observability_oidc_rancher[0].result.client_secret : ""
      rancher_host    = var.rancher_host
    }))
  ]
}

resource "null_resource" "provision_k8s_stackpack" {
  count      = var.suse_observability_enabled ? 1 : 0
  depends_on = [helm_release.suse_observability]

  provisioner "local-exec" {
    command = <<-EOT
      export KUBECONFIG=${var.kubeconfig_path}
      kubectl -n suse-observability rollout status deploy/suse-observability-server --timeout=300s
      kubectl -n suse-observability rollout status deploy/suse-observability-router --timeout=300s

      until kubectl -n suse-observability exec deploy/suse-observability-server -- \
        curl -s -f -o /dev/null -H "X-API-Key: ${random_password.suse_observability_bootstrap_token[0].result}" \
        "http://suse-observability-router:8080/api/stackpack/config"; do
        echo "Waiting for SUSE Observability API to be ready..."
        sleep 5
      done

      kubectl -n suse-observability exec deploy/suse-observability-server -- \
        curl -s -f -X POST "http://suse-observability-router:8080/api/stackpack/kubernetes-v2/provision" \
        -H "X-API-Key: ${random_password.suse_observability_bootstrap_token[0].result}" \
        -H "Content-Type: application/json" \
        -d '{"kubernetes_cluster_name": "${var.cluster_name}"}'
    EOT
  }
}

resource "helm_release" "suse_observability_agent" {
  count            = var.suse_observability_enabled ? 1 : 0
  depends_on       = [helm_release.suse_observability, null_resource.provision_k8s_stackpack]
  name             = "suse-observability-agent"
  repository       = "https://charts.rancher.com/server-charts/prime/suse-observability"
  chart            = "suse-observability-agent"
  namespace        = "suse-observability-agent"
  create_namespace = true
  timeout          = 600
  version          = var.suse_observability_agent_hc_version
  values = [
    templatefile("${path.module}/suse-observability-agent-values.yaml.tpl", {
      url          = "http://suse-observability-router.suse-observability.svc.cluster.local:8080/receiver/stsAgent"
      cluster_name = var.cluster_name
    })
  ]
  set_sensitive = [
    {
      name  = "stackstate.apiKey"
      value = random_password.suse_observability_agent_key[0].result
    }
  ]
}
