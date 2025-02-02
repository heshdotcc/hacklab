{ pkgs, toBase64, env }:

[
  {
    name = "secret.yaml";
    path = "values/";
    content = ''
      apiVersion: v1
      kind: Secret
      metadata:
        name: jupyterhub-secret
        namespace: jupyterhub
      type: Opaque
      data:
        jupyterhub-token: ${toBase64 env.jupyterhub-token}
        jupyterhub-password: ${toBase64 env.jupyterhub-password}
    '';
  }
]
