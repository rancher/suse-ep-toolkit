output "image_id" {
  description = "The self_link / ID of the custom OS image created on Google Cloud."
  value       = google_compute_image.upload_certified_image.self_link
}
