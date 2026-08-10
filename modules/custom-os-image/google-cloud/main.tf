locals {
  certified_image_name = "opensuse-leap-16-0-harv-cloud-image.x86_64.raw.tar.gz"
  certified_image_url  = "https://github.com/rancher/harvester-cloud/releases/download/latest/${local.certified_image_name}"
  certified_image_sum  = "a6e789a154d365361444dcf26a060391906976b718d985ecaf47b295e989ca1e5f363af86422527c2d41e78c439a04fef4708b7f6ef0a1bc06b63875a05745bc"
  common_labels = {
    name       = var.prefix
    workload   = "harvester"
    managed_by = "terraform"
  }
}

resource "null_resource" "download_image" {
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      FILE="${path.cwd}/${local.certified_image_name}"
      EXPECTED_SUM="${local.certified_image_sum}"
      if [ -f "$FILE" ]; then
        echo "File already exists, verifying SHA512..."
        ACTUAL_SUM=$(sha512sum "$FILE" | awk '{print $1}')
        if [ "$ACTUAL_SUM" = "$EXPECTED_SUM" ]; then
          echo "Checksum matches, skipping download"
          exit 0
        else
          echo "Checksum mismatch, re-downloading file"
          rm -f "$FILE"
        fi
      fi
      echo "Downloading certified image..."
      curl -L -o "$FILE" "${local.certified_image_url}"
      echo "Verifying SHA512..."
      ACTUAL_SUM=$(sha512sum "$FILE" | awk '{print $1}')
      if [ "$ACTUAL_SUM" != "$EXPECTED_SUM" ]; then
        echo "ERROR: SHA512 checksum mismatch!"
        exit 1
      fi
      echo "SHA512 checksum OK!"
    EOT
  }
}

resource "google_storage_bucket" "images_bucket" {
  name          = "${var.prefix}-certified-img-bucket"
  location      = var.region
  force_destroy = true
  labels        = local.common_labels
}

resource "google_storage_bucket_object" "certified_image" {
  depends_on = [null_resource.download_image]
  name       = "${var.prefix}-image-raw.tar.gz"
  bucket     = google_storage_bucket.images_bucket.name
  source     = "${path.cwd}/${local.certified_image_name}"
}

resource "google_compute_image" "upload_certified_image" {
  depends_on = [google_storage_bucket_object.certified_image]
  name       = "${var.prefix}-opensuse-certified-img"
  raw_disk {
    source = "https://storage.googleapis.com/${google_storage_bucket.images_bucket.name}/${google_storage_bucket_object.certified_image.name}"
  }
  labels = local.common_labels
}

resource "null_resource" "cleanup_certified_image" {
  depends_on = [google_compute_image.upload_certified_image]
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      FILE="${path.cwd}/${local.certified_image_name}"
      rm -f "$FILE"
    EOT
  }
}
