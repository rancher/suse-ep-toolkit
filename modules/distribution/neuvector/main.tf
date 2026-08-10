resource "helm_release" "neuvector" {
  count            = var.neuvector_enabled ? 1 : 0
  depends_on       = [null_resource.neuvector_tls_secret]
  name             = "neuvector"
  repository       = "https://neuvector.github.io/neuvector-helm/"
  chart            = "core"
  namespace        = "cattle-neuvector-system"
  create_namespace = true
  version          = var.neuvector_hc_version
  values = [
    <<EOF
${var.neuvector_version != "" ? "tag: ${var.neuvector_version}" : ""}

global:
  cattle:
    url: "https://${var.rancher_host}"

controller:
  replicas: ${var.neuvector_controller_count}
  nodeSelector:
    node-role.kubernetes.io/control-plane: "true"
  secret:
    enabled: true
    data:
      userinitcfg.yaml: 
        always_reload: true
        users:
        -
          Fullname: admin
          Password: 
          Role: admin
  ranchersso:
    enabled: ${var.rancher_enabled}
  pvc:
    enabled: ${var.longhorn_enabled}
    storageClass: ${var.longhorn_enabled ? "longhorn" : "null"}
    accessModes:
      - ReadWriteMany
    capacity: ${var.longhorn_enabled ? "20Gi" : "null"}
  apisvc:
    type: ClusterIP
    annotations:
      traefik.ingress.kubernetes.io/service.serversscheme: https
      traefik.ingress.kubernetes.io/service.serverstransport: cattle-neuvector-system-neuvector@kubernetescrd
  federation:
    mastersvc:
      type: NodePort
      nodePort: 32045
      annotations:
        traefik.ingress.kubernetes.io/service.serversscheme: https
        traefik.ingress.kubernetes.io/service.serverstransport: cattle-neuvector-system-neuvector@kubernetescrd
    managedsvc:
      type: NodePort
      nodePort: 32046
      annotations:
        traefik.ingress.kubernetes.io/service.serversscheme: https
        traefik.ingress.kubernetes.io/service.serverstransport: cattle-neuvector-system-neuvector@kubernetescrd

cve:
  scanner:
    replicas: ${var.neuvector_scanner_count}
    nodeSelector:
      node-role.kubernetes.io/control-plane: "true"

manager:
  svc:
    type: ClusterIP
    annotations:
      traefik.ingress.kubernetes.io/service.serversscheme: https
      traefik.ingress.kubernetes.io/service.serverstransport: cattle-neuvector-system-neuvector@kubernetescrd
  ingress:
    enabled: true
    ingressClassName: traefik
    host: ${var.neuvector_host}
    tls: true
    secretName: neuvector-tls
    annotations:
      kubernetes.io/ingress.class: traefik
      traefik.ingress.kubernetes.io/router.entrypoints: websecure
      traefik.ingress.kubernetes.io/router.tls: "true"
EOF
  ]
  set = [
    {
      name  = "controller.secret.data.userinitcfg\\.yaml.users[0].Password"
      value = var.neuvector_admin_password
    }
  ]
}

resource "null_resource" "neuvector_traefik_transport" {
  count = var.neuvector_enabled ? 1 : 0
  depends_on = [
    helm_release.neuvector
  ]
  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG=${var.kubeconfig_path}

kubectl apply -f - <<CRT
apiVersion: traefik.io/v1alpha1
kind: ServersTransport
metadata:
  name: neuvector
  namespace: cattle-neuvector-system
spec:
  insecureSkipVerify: true
CRT
EOF
  }
}
