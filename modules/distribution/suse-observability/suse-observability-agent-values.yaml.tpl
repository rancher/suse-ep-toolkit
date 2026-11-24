stackstate:
  url: "${url}"
  cluster:
    name: "${cluster_name}"

nodeAgent:
  criSocketPath: "/run/k3s/containerd/containerd.sock"
  containers:
    processAgent:
      enabled: true
