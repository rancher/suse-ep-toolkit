resource "tls_private_key" "ca" {
  count     = var.suse_ai_enabled ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  count             = var.suse_ai_enabled ? 1 : 0
  private_key_pem   = tls_private_key.ca[0].private_key_pem
  is_ca_certificate = true
  subject {
    common_name = "${var.openwebui_host}-ca"
  }
  validity_period_hours = 87600
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

resource "tls_private_key" "openwebui" {
  count     = var.suse_ai_enabled ? 1 : 0
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "openwebui" {
  count           = var.suse_ai_enabled ? 1 : 0
  private_key_pem = tls_private_key.openwebui[0].private_key_pem
  subject {
    common_name = var.openwebui_host
  }
  dns_names = [
    var.openwebui_host
  ]
}

resource "tls_locally_signed_cert" "openwebui" {
  count                 = var.suse_ai_enabled ? 1 : 0
  cert_request_pem      = tls_cert_request.openwebui[0].cert_request_pem
  ca_private_key_pem    = tls_private_key.ca[0].private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca[0].cert_pem
  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "null_resource" "openwebui_tls_secret" {
  count = var.suse_ai_enabled ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG=${var.kubeconfig_path}

kubectl create namespace suse-ai --dry-run=client -o yaml | kubectl apply -f -

cat <<CRT | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: suse-ai-tls
  namespace: suse-ai
type: kubernetes.io/tls
data:
  tls.crt: $(echo '${base64encode("${tls_locally_signed_cert.openwebui[0].cert_pem}${tls_self_signed_cert.ca[0].cert_pem}")}')
  tls.key: $(echo '${base64encode(tls_private_key.openwebui[0].private_key_pem)}')
CRT
EOF
  }
}
