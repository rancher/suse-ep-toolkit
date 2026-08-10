locals {
  certified_image_name = "opensuse-leap-16-0-harv-cloud-image.x86_64.vhd"
  certified_image_url  = "https://github.com/rancher/harvester-cloud/releases/download/latest/${local.certified_image_name}"
  certified_image_sum  = "b18a460739d97206032e4dc66ea0c24e3bab98463d41571b798aee84e97d7fb4f4cba9c2bf83af42ceab88dcadd42918bcfeea1bc330fb774544b246d4d1dc55"
  common_tags = {
    Name       = "${var.prefix}"
    Workload   = "harvester"
    Managed_by = "terraform"
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
      echo "Downloading certified VHD..."
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

resource "aws_s3_bucket" "images" {
  bucket = "opensuse-vhd-${var.prefix}"
}

resource "aws_s3_object" "vhd" {
  depends_on = [null_resource.download_image]
  bucket     = aws_s3_bucket.images.id
  key        = "opensuse-harv-ep-toolkit.vhd"
  source     = "${path.cwd}/${local.certified_image_name}"
}

resource "aws_iam_role" "vmimport" {
  name = "${var.prefix}-ep-toolkit-vmimport"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "vmie.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "vmimport" {
  name = "${var.prefix}-ep-toolkit-vmimport"
  role = aws_iam_role.vmimport.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetBucketLocation",
          "s3:GetObject",
          "s3:ListBucket"
        ],
        Resource = [
          aws_s3_bucket.images.arn,
          "${aws_s3_bucket.images.arn}/*"
        ]
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:ModifySnapshotAttribute",
          "ec2:CopySnapshot",
          "ec2:RegisterImage",
          "ec2:Describe*"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_ebs_snapshot_import" "opensuse_snapshot" {
  description = "Opensuse Cerfied Image for SUSE ep-toolkit"
  role_name   = aws_iam_role.vmimport.name
  disk_container {
    format = "VHD"
    user_bucket {
      s3_bucket = aws_s3_bucket.images.id
      s3_key    = aws_s3_object.vhd.key
    }
  }
  depends_on = [aws_s3_object.vhd]
}

resource "aws_ami" "opensuse_ami" {
  name                = "${var.prefix}-opensuse-ep-toolkit-ami"
  virtualization_type = "hvm"
  root_device_name    = "/dev/xvda"
  ena_support         = true
  ebs_block_device {
    device_name = "/dev/xvda"
    snapshot_id = aws_ebs_snapshot_import.opensuse_snapshot.id
    volume_size = 2
    volume_type = "gp3"
  }
  tags = local.common_tags
}

resource "null_resource" "removing_image" {
  depends_on = [aws_ami.opensuse_ami]
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      FILE="${path.cwd}/${local.certified_image_name}"
      rm -f "$FILE"
    EOT
  }
}