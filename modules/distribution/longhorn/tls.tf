resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true
  subject {
    common_name = "${var.longhorn_host}-ca"
  }
  validity_period_hours = 87600
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

resource "tls_private_key" "longhorn" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "longhorn" {
  private_key_pem = tls_private_key.longhorn.private_key_pem
  subject {
    common_name = var.longhorn_host
  }
  dns_names = [
    var.longhorn_host
  ]
}

resource "tls_locally_signed_cert" "longhorn" {
  cert_request_pem      = tls_cert_request.longhorn.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "null_resource" "longhorn_tls_secret" {
  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG=${var.kubeconfig_path}

echo "Waiting for Kubernetes API..."

until kubectl get nodes >/dev/null 2>&1; do
  sleep 5
done

kubectl create namespace longhorn-system --dry-run=client -o yaml | kubectl apply -f -

echo "Applying Longhorn TLS secret..."

cat <<CRT | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: longhorn-tls
  namespace: longhorn-system
type: kubernetes.io/tls
data:
  tls.crt: $(echo '${base64encode("${tls_locally_signed_cert.longhorn.cert_pem}${tls_self_signed_cert.ca.cert_pem}")}')
  tls.key: $(echo '${base64encode(tls_private_key.longhorn.private_key_pem)}')
CRT
EOF
  }
  triggers = {
    cert = tls_locally_signed_cert.longhorn.cert_pem
    ca   = tls_self_signed_cert.ca.cert_pem
  }
}
