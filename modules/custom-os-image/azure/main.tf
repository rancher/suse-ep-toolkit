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

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.region
  tags     = local.common_tags
}

resource "azurerm_storage_account" "vhd" {
  name                            = var.prefix
  resource_group_name             = azurerm_resource_group.rg.name
  location                        = azurerm_resource_group.rg.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  allow_nested_items_to_be_public = false
  tags                            = local.common_tags
}

resource "azurerm_storage_container" "vhds" {
  name                  = "vhds"
  storage_account_id    = azurerm_storage_account.vhd.id
  container_access_type = "private"
}

resource "azurerm_storage_blob" "ep_toolkit_vhd" {
  depends_on           = [null_resource.download_image]
  name                 = "harvestercloudcertified.vhd"
  storage_container_id = azurerm_storage_container.vhds.id
  type                 = "Page"
  source               = "${path.cwd}/${local.certified_image_name}"
}

resource "null_resource" "wait_blob_accessible" {
  depends_on = [azurerm_storage_blob.ep_toolkit_vhd]
  provisioner "local-exec" {
    command = <<EOT
      BLOB_URI=${azurerm_storage_blob.ep_toolkit_vhd.url}
      ACCOUNT_KEY=$(az storage account keys list -g ${azurerm_resource_group.rg.name} -n ${azurerm_storage_account.vhd.name} --query '[0].value' -o tsv)
      for i in {1..20}; do
        az disk create --name temp-check-disk --resource-group ${azurerm_resource_group.rg.name} --source "$BLOB_URI" --location ${azurerm_resource_group.rg.location} --sku Standard_LRS > /dev/null 2>&1 && break || echo "Blob not ready, retry in 15s" && sleep 15
      done
      echo "blob ready, creating Image from Blob"
      az disk delete --name temp-check-disk -g ${azurerm_resource_group.rg.name} --yes > /dev/null 2>&1
    EOT
  }
}

resource "azurerm_image" "harvester" {
  depends_on          = [null_resource.wait_blob_accessible]
  name                = "HarvesterCloudCertifiedImage"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_disk {
    os_type      = "Linux"
    os_state     = "Generalized"
    blob_uri     = azurerm_storage_blob.ep_toolkit_vhd.url
    storage_type = "Standard_LRS"
  }
  tags = local.common_tags
}

resource "null_resource" "removing_image" {
  depends_on = [azurerm_image.harvester]
  provisioner "local-exec" {
    command = <<-EOT
      set -e
      FILE="${path.cwd}/${local.certified_image_name}"
      rm -f "$FILE"
    EOT
  }
}
