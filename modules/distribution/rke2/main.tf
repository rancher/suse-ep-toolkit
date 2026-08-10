locals {
  install_type = var.node_role
  disk_device  = var.volume_device
  disk_part    = length(regexall("nvme", var.volume_device)) > 0 ? "${var.volume_device}p1" : "${var.volume_device}1"
  base_config  = <<-EOF
token: ${var.rke2_token}
write-kubeconfig-mode: "0644"
ingress-controller: ${var.rke2_ingress}
EOF
  join_config  = var.server_url != null ? "server: ${var.server_url}" : ""
  final_config = trimspace(
    join("\n", compact([
      local.base_config,
      local.join_config,
      var.rke2_config
    ]))
  )
}

locals {
  user_data = <<-EOF
#cloud-config
write_files:
  - path: /etc/rancher/rke2/config.yaml
    permissions: "0600"
    content: |
      ${replace(local.final_config, "\n", "\n      ")}
runcmd:
  # Wait volume attachment
  - |
      for i in $(seq 1 60); do
        if [ -b ${local.disk_device} ]; then
          echo "Disk ${local.disk_device} found"
          break
        fi
        echo "Waiting for ${local.disk_device}..."
        sleep 2
      done
  # Ensure udev has settled
  - udevadm settle
  # Partition disk
  - |
      if ! blkid ${local.disk_part}; then
        echo "Partitioning disk..."
        parted ${local.disk_device} --script mklabel gpt
        parted ${local.disk_device} --script mkpart primary xfs 0% 100%
        for i in $(seq 1 60); do
          if [ -b ${local.disk_part} ]; then
            echo "Partition ${local.disk_part} found"
            break
          fi
          echo "Waiting for partition ${local.disk_part}..."
          sleep 2
        done
        mkfs.xfs -f ${local.disk_part}
      fi
  # Mount rancher storage
  - mkdir -p /var/lib/rancher
  - |
      UUID=$(blkid -s UUID -o value ${local.disk_part})
      grep -q "$UUID" /etc/fstab || \
      echo "UUID=$UUID /var/lib/rancher xfs defaults,noatime,nodiratime,nofail,x-systemd.device-timeout=30 0 2" >> /etc/fstab
  - systemctl daemon-reload
  - mount /var/lib/rancher
  # Verify mount
  - df -h /var/lib/rancher
  # Configuring Public IP and Private IP on RKE2 config
  - |
      PUBLIC_IP=$(curl -s http://icanhazip.com)
      PRIVATE_IP=$(ip addr show scope global | grep inet | cut -d' ' -f6 | cut -d/ -f1 | grep -v "$PUBLIC_IP" | head -n1)
      cat <<EOF_CONFIG >> /etc/rancher/rke2/config.yaml
      node-external-ip: $PUBLIC_IP
      node-ip: $PRIVATE_IP
      advertise-address: $PRIVATE_IP
      tls-san:
        - "$PUBLIC_IP"
        - "$PUBLIC_IP.sslip.io"
      EOF_CONFIG
  # Install RKE2
  - curl -sfL https://get.rke2.io | INSTALL_RKE2_VERSION=${var.rke2_version} INSTALL_RKE2_TYPE=${local.install_type} sh -
  - systemctl enable rke2-${local.install_type}
  - systemctl start rke2-${local.install_type}
  # Wait for kubeconfig to exist
  - |
      for i in $(seq 1 60); do
        if [ -f /etc/rancher/rke2/rke2.yaml ]; then
          break
        fi
        sleep 2
      done
  # Wait for Kubernetes API to respond
  - |
      for i in $(seq 1 90); do
        /var/lib/rancher/rke2/bin/kubectl \
          --kubeconfig /etc/rancher/rke2/rke2.yaml \
          get nodes >/dev/null 2>&1 && break
        sleep 2
      done
EOF
}
