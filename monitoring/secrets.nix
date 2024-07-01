{ pkgs, toBase64, env }:

[
  {
    name = "secret.yaml";
    path = "values/grafana";
    content = ''
      apiVersion: v1
      kind: Secret
      metadata:
        name: grafana-admin-secret
        namespace: monitoring 
      type: Opaque
      data:
        admin-password: ${toBase64 env.infra.grafana}
    '';
  }
  {
    name = "secret.yaml";
    path = "values/alertmanager";
    content = ''
      apiVersion: v1
      kind: Secret
      metadata:
        name: alertmanager-email-secret
        namespace: monitoring
      type: Opaque
      data:
        smtp_smarthost: ${toBase64 env.infra.smtp_smarthost}
        smtp_from: ${toBase64 env.infra.smtp_from}
        smtp_auth_username: ${toBase64 env.infra.smtp_auth_username}
        smtp_auth_password: ${toBase64 env.infra.smtp_auth_password}
        recipient_email: ${toBase64 env.infra.recipient_email}
    '';
  }
]
