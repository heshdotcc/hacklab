{
  description = ''
    A Nix flake for securely managing Kubernetes secrets for Grafana and Alertmanager, 
    enabling configuration of SMTP credentials and recipient emails for alert notifications. 
    It simplifies secret management while allowing Kubernetes resources to be handled separately.
  '';

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    env.url = "git+file:///home/he/crypt";
  };

  outputs = { self, nixpkgs, env }: {
    packages = let
      system = builtins.currentSystem;
      pkgs = import nixpkgs { inherit system; };
    in
    {
      grafanaSecret = pkgs.writeTextFile {
        name = "grafana-admin-secret.yaml";
        text = ''
          apiVersion: v1
          kind: Secret
          metadata:
            name: grafana-admin-secret
            namespace: default
          type: Opaque
          data:
            admin-password: ${pkgs.lib.base64.encode env.infra.grafana}
        '';
      };

      alertmanagerSecret = pkgs.writeTextFile {
        name = "alertmanager-email-secret.yaml";
        text = ''
          apiVersion: v1
          kind: Secret
          metadata:
            name: alertmanager-email-creds
            namespace: monitoring
          type: Opaque
          data:
            smtp_smarthost: ${pkgs.lib.base64.encode env.infra.smarthost}
            smtp_from: ${pkgs.lib.base64.encode env.infra.smtp_from}
            smtp_auth_username: ${pkgs.lib.base64.encode env.infra.smtp_auth_username}
            smtp_auth_password: ${pkgs.lib.base64.encode env.infra.smtp_auth_password}
            recipient_email: ${pkgs.lib.base64.encode env.infra.recipient_email}
        '';
      };
    };
  };
}

