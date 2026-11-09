output "longhorn_url" {
  description = "Longhorn web UI URL."
  value       = var.longhorn_enabled ? "https://longhorn.${var.ingress_ip}.sslip.io" : null
}

output "rancher_url" {
  description = "Rancher Dashboard web UI URL."
  value       = var.rancher_enabled ? "https://rancher.${var.ingress_ip}.sslip.io/dashboard" : null
}

output "observability_url" {
  description = "SUSE Observability web UI URL."
  value       = var.suse_observability_enabled ? "https://observability.${var.ingress_ip}.sslip.io" : null
}

output "neuvector_url" {
  description = "NeuVector web UI URL."
  value       = var.neuvector_enabled ? "https://neuvector.${var.ingress_ip}.sslip.io" : null
}

output "open_webui_url" {
  value = var.suse_ai_enabled ? "https://openwebui.${var.ingress_ip}.sslip.io" : null
}