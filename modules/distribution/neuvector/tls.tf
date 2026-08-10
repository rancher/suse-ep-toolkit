resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true
  subject {
    common_name = "${var.neuvector_host}-ca"
  }
  validity_period_hours = 87600
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

resource "tls_private_key" "neuvector" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "neuvector" {
  private_key_pem = tls_private_key.neuvector.private_key_pem
  subject {
    common_name = var.neuvector_host
  }
  dns_names = [
    var.neuvector_host
  ]
}

resource "tls_locally_signed_cert" "neuvector" {
  cert_request_pem      = tls_cert_request.neuvector.cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 8760
  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth",
  ]
}

resource "null_resource" "neuvector_tls_secret" {
  count = var.neuvector_enabled ? 1 : 0
  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG=${var.kubeconfig_path}

kubectl create namespace cattle-neuvector-system --dry-run=client -o yaml | kubectl apply -f -

cat <<CRT | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: neuvector-tls
  namespace: cattle-neuvector-system
type: kubernetes.io/tls
data:
  tls.crt: $(echo '${base64encode("${tls_locally_signed_cert.neuvector.cert_pem}${tls_self_signed_cert.ca.cert_pem}")}')
  tls.key: $(echo '${base64encode(tls_private_key.neuvector.private_key_pem)}')
CRT
EOF
  }
}
