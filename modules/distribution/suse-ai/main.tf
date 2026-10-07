resource "null_resource" "gpu_operator" {
  depends_on = [null_resource.openwebui_tls_secret]
  count      = (var.suse_ai_enabled && var.suse_ai_gpu) ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG=${var.kubeconfig_path}
set -euo pipefail
kubectl apply -f - <<EOT
apiVersion: helm.cattle.io/v1
kind: HelmChart
metadata:
  name: gpu-operator
  namespace: kube-system
spec:
  chart: gpu-operator
  createNamespace: true
  failurePolicy: reinstall
  repo: https://helm.ngc.nvidia.com/nvidia
  targetNamespace: gpu-operator
  valuesContent: |-
    toolkit:
      env:
      - name: CONTAINERD_SOCKET
        value: /run/k3s/containerd/containerd.sock
    validator:
      plugin: {}
EOT
EOF
  }
}

resource "null_resource" "appco_credentials_and_longhorn_storageclass" {
  count      = var.suse_ai_enabled ? 1 : 0
  depends_on = [null_resource.gpu_operator]
  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG=${var.kubeconfig_path}
set -euo pipefail
while ! kubectl get nodes >/dev/null 2>&1; do
  echo "Waiting for Kubernetes API to be ready before proceeding with next steps"
done
echo "creating Application Collection Secret"
kubectl create secret docker-registry application-collection --docker-server=dp.apps.rancher.io --docker-username=${var.app_collection_username} --docker-password=${var.app_collection_password} -n suse-ai
kubectl apply -f - <<EOT
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: longhorn-xfs
provisioner: driver.longhorn.io
allowVolumeExpansion: true
reclaimPolicy: Delete
volumeBindingMode: Immediate
parameters:
  numberOfReplicas: "1"
  staleReplicaTimeout: "30"
  fromBackup: ""
  fsType: "xfs"
  dataLocality: "disabled"
  unmapMarkSnapChainRemoved: "ignored"
EOT
EOF
  }
}

resource "helm_release" "milvus" {
  count            = var.suse_ai_enabled ? 1 : 0
  depends_on       = [null_resource.appco_credentials_and_longhorn_storageclass]
  name             = "milvus"
  repository       = "oci://dp.apps.rancher.io/charts"
  chart            = "milvus"
  namespace        = "suse-ai"
  create_namespace = true
  timeout          = 1200
  version          = var.milvus_hc_version
  values = [
    <<EOF
global:
  imagePullSecrets:
  - application-collection

cluster:
  enabled: true
standalone:
  persistence:
    persistentVolumeClaim:
      storageClassName: "longhorn"
etcd:
  replicaCount: 1
  persistence:
    storageClassName: "longhorn"
minio:
  mode: distributed
  replicas: 4
  rootUser: "admin"
  rootPassword: "adminminio"
  persistence:
    storageClass: "longhorn"
    size: 5Gi
kafka:
  enabled: true
  persistence:
    storageClassName: longhorn-xfs
  cluster:
    nodeCount:
      controller: 1
      broker: 1
EOF
  ]
}

resource "helm_release" "ollama" {
  count            = var.suse_ai_enabled ? 1 : 0
  depends_on       = [null_resource.appco_credentials_and_longhorn_storageclass]
  name             = "ollama"
  repository       = "oci://dp.apps.rancher.io/charts"
  chart            = "ollama"
  namespace        = "suse-ai"
  create_namespace = true
  timeout          = 1200
  version          = var.ollama_hc_version
  values = [
    <<EOF
global:
  imagePullSecrets:
  - application-collection
ingress:
  enabled: false
defaultModel: "gemma:2b"
ollama:
  models:
    pull:
      - "gemma:2b"
      - "llama3.1"
  gpu:
    enabled: ${var.suse_ai_gpu}
    type: 'nvidia'
    number: 1
persistentVolume:
  enabled: true
  storageClass: longhorn
  size: 20Gi
extraEnv:
  - name: OLLAMA_DEBUG
    value: "1"
EOF
  ]
}

resource "helm_release" "open_webui" {
  count            = var.suse_ai_enabled ? 1 : 0
  depends_on       = [null_resource.appco_credentials_and_longhorn_storageclass]
  name             = "open-webui"
  repository       = "oci://dp.apps.rancher.io/charts"
  chart            = "open-webui"
  namespace        = "suse-ai"
  create_namespace = true
  timeout          = 1200
  version          = var.openwebui_hc_version
  values = [
    <<EOF
global:
  imagePullSecrets:
  - application-collection
  tls:
    source: secret
ollamaUrls:
- http://ollama.suse-ai.svc.cluster.local:11434
persistence:
  enabled: true
  storageClass: longhorn
  size: 20Gi
ollama:
  enabled: false
pipelines:
  enabled: true
  persistence:
    storageClass: longhorn
    size: 20Gi
ingress:
  enabled: true
  class: "traefik"
  host: ${var.openwebui_host}
  tls: true
  existingSecret: suse-ai-tls
extraEnvVars:
- name: DEFAULT_MODELS
  value: "gemma:2b"
- name: DEFAULT_USER_ROLE
  value: "user"
- name: WEBUI_NAME
  value: "SUSE AI"
- name: VECTOR_DB
  value: "milvus"
- name: MILVUS_URI
  value: http://milvus.suse-ai.svc.cluster.local:19530
EOF
  ]
}