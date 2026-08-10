locals {
  hosts = {
    "suse_main" = { host = var.suse_observability_host, secret = "suse-observability-tls" }
    "otlp_grpc" = { host = var.suse_observability_otlp_host, secret = "otlp-suse-observability-tls" }
    "otlp_http" = { host = var.suse_observability_otlp_http_host, secret = "otlp-http-suse-observability-tls" }
  }
}

resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem   = tls_private_key.ca.private_key_pem
  is_ca_certificate = true
  subject {
    common_name = "${var.suse_observability_host}-ca"
  }
  validity_period_hours = 87600
  allowed_uses = [
    "cert_signing",
    "crl_signing",
    "digital_signature",
  ]
}

resource "tls_private_key" "certs" {
  for_each  = local.hosts
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "certs" {
  for_each        = local.hosts
  private_key_pem = tls_private_key.certs[each.key].private_key_pem
  subject {
    common_name = each.value.host
  }
  dns_names = [each.value.host]
}

resource "tls_locally_signed_cert" "certs" {
  for_each              = local.hosts
  cert_request_pem      = tls_cert_request.certs[each.key].cert_request_pem
  ca_private_key_pem    = tls_private_key.ca.private_key_pem
  ca_cert_pem           = tls_self_signed_cert.ca.cert_pem
  validity_period_hours = 8760
  allowed_uses          = ["key_encipherment", "digital_signature", "server_auth"]
}

resource "null_resource" "suse_obs_ca_secret" {
  depends_on = [tls_locally_signed_cert.certs]
  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG=${var.kubeconfig_path}

echo "Waiting for Kubernetes API..."

until kubectl get nodes >/dev/null 2>&1; do
  sleep 5
done

kubectl create namespace suse-observability --dry-run=client -o yaml | kubectl apply -f -

echo "Applying CA secret..."

cat <<CA | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: suse-observability-ca
  namespace: suse-observability
type: Opaque
data:
  cacerts.pem: $(echo '${base64encode(tls_self_signed_cert.ca.cert_pem)}')
CA
EOF
  }
}

resource "null_resource" "suse_obs_tls_secret" {
  depends_on = [null_resource.suse_obs_ca_secret]
  for_each   = local.hosts
  provisioner "local-exec" {
    command = <<EOF
export KUBECONFIG=${var.kubeconfig_path}

SECRET_NAME="${each.value.secret}"

echo "Applying TLS secret for ${each.value.host}..."

cat <<CRT | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: $SECRET_NAME
  namespace: suse-observability
type: kubernetes.io/tls
data:
  tls.crt: $(echo '${base64encode("${tls_locally_signed_cert.certs[each.key].cert_pem}${tls_self_signed_cert.ca.cert_pem}")}')
  tls.key: $(echo '${base64encode(tls_private_key.certs[each.key].private_key_pem)}')
CRT
EOF
  }
}