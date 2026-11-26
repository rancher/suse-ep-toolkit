global:
  suseObservability:
    license: "${license}"
    baseUrl: "https://${host}"
    adminPassword: "${admin_password}"
    receiverApiKey: "${api_key}"
    sizing:
      profile: "${profile}"

stackstate:
  authentication:
    serviceToken:
      bootstrap:
        token: "${bootstrap_token}"
        roles:
          - "stackstate-admin"
        ttl: "1h"
%{if rancher_auth}
    rancher:
      clientId: "${client_id}"
      secret: "${client_secret}"
      baseUrl: "https://${rancher_host}"
  components:
    api:
      extraEnv:
        open:
          CONFIG_FORCE_stackstate_misc_sslCertificateChecking: false
    server:
      extraEnv:
        open:
          CONFIG_FORCE_stackstate_misc_sslCertificateChecking: false
%{endif}

ingress:
  enabled: true
  ingressClassName: traefik
  hosts:
    - host: ${host}
      paths:
        - /
  tls:
    - secretName: suse-observability-tls
      hosts:
        - ${host}

opentelemetry-collector:
  ingress:
    enabled: true
    ingressClassName: traefik
    annotations:
      traefik.ingress.kubernetes.io/router.entrypoints: websecure
    hosts:
      - host: ${otlp_host}
        paths:
          - path: /
            pathType: Prefix
            serviceName: suse-observability-otel-collector-grpc
            port: 4317
    tls:
      - hosts:
          - ${otlp_host}
        secretName: otlp-suse-observability-tls
    additionalIngresses:
      - name: otlp-http
        ingressClassName: traefik
        annotations:
          traefik.ingress.kubernetes.io/router.entrypoints: websecure
        hosts:
          - host: ${otlp_http_host}
            paths:
              - path: /
                pathType: Prefix
                port: 4318
        tls:
          - hosts:
              - ${otlp_http_host}
            secretName: otlp-http-suse-observability-tls
