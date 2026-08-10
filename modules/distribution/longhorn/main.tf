resource "null_resource" "longhorn_dependencies" {
  count = var.longhorn_enabled ? length(var.node_ips) : 0
  connection {
    type        = "ssh"
    user        = "opensuse"
    host        = var.node_ips[count.index]
    private_key = var.ssh_private_key
  }
  provisioner "remote-exec" {
    inline = [
      "set -euo pipefail",
      # FIX
      "export PATH=$PATH:/sbin:/usr/sbin",
      "sudo zypper -n --gpg-auto-import-keys refresh",
      # Base Longhorn deps
      "sudo zypper -n install -y open-iscsi nfs-client cryptsetup device-mapper util-linux",
      # Kernel modules (safe)
      "sudo modprobe dm_mod || true",
      "sudo modprobe dm_crypt || true",
      "sudo modprobe loop || true",
      "sudo modprobe nbd || true",
      # Enable iSCSI (openSUSE: ONLY iscsid matters)
      "sudo systemctl enable --now iscsid",
      # Verify service
      "systemctl is-active iscsid",
      # Disable multipath ONLY if exists
      "systemctl is-enabled multipathd && sudo systemctl disable multipathd || true",
      "systemctl is-active multipathd && sudo systemctl stop multipathd || true",
      # Critical check (NOW works because PATH fixed)
      "which iscsiadm",
      "iscsiadm -m session || true",
      # Sanity checks
      "lsmod | grep dm_ || true",
      "lsblk || true",
      "cat /proc/partitions || true"
    ]
  }
}

resource "null_resource" "longhorn_auth" {
  count      = var.longhorn_enabled ? 1 : 0
  depends_on = [null_resource.longhorn_dependencies]
  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG=${var.kubeconfig_path}

set -euo pipefail

until kubectl get crd middlewares.traefik.io >/dev/null 2>&1; do
  echo "Waiting for Traefik CRDs..."
  sleep 5
done

HASHED_PASSWORD=$(openssl passwd -apr1 "${var.longhorn_admin_password}")

kubectl create namespace longhorn-system --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic longhorn-auth \
  --from-literal=users="admin:$HASHED_PASSWORD" \
  -n longhorn-system \
  --dry-run=client -o yaml | kubectl apply -f -

cat <<YAML | kubectl apply -f -
apiVersion: traefik.io/v1alpha1
kind: Middleware
metadata:
  name: longhorn-auth
  namespace: longhorn-system
spec:
  basicAuth:
    secret: longhorn-auth
YAML
EOF
  }
}

resource "helm_release" "longhorn" {
  count            = var.longhorn_enabled ? 1 : 0
  depends_on       = [null_resource.longhorn_dependencies, null_resource.longhorn_auth, null_resource.longhorn_tls_secret]
  name             = "longhorn"
  repository       = "https://charts.longhorn.io"
  chart            = "longhorn"
  namespace        = "longhorn-system"
  create_namespace = true
  version          = var.longhorn_hc_version
  values = [
    <<EOF
defaultSettings:
  defaultDataPath: /var/lib/rancher/longhorn
  defaultReplicaCount: 1
  deletingConfirmationFlag: true
  storageOverProvisioningPercentage: 300

ingress:
  enabled: true
  ingressClassName: traefik
  host: ${var.longhorn_host}
  tls: true
  tlsSecret: longhorn-tls
  annotations:
    traefik.ingress.kubernetes.io/router.middlewares: longhorn-system-longhorn-auth@kubernetescrd
EOF
  ]
}
