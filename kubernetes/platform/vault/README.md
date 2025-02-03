# Vault module

Get the helm chart:
```
helm repo add hashicorp https://helm.releases.hashicorp.com && helm repo update
```

Look for the latest/desired version:
```
helm search repo hashicorp/vault
```

Review the default chart values:
```
helm show values hashicorp/vault --version 0.29.1
```

Once you have the values.yaml file, apply the helm chart:
```
kustomize build --enable-helm . | kubectl apply -f -
```

Wait for the vault pod to be ready:
```
kubectl wait --for=condition=Ready pod/vault-0 -n vault
```

Initialize the vault instance and save the output:
```
kubectl exec -it vault-0 -n vault -- vault operator init
```

Unseal the vault instance at least 3 times using previous keys:
```
kubectl exec -it vault-0 -n vault -- vault operator unseal <key1>
kubectl exec -it vault-0 -n vault -- vault operator unseal <key2>
kubectl exec -it vault-0 -n vault -- vault operator unseal <key3>
```

Vault requires a transit engine for auto-unseal:
```
Vault (Single Instance)
├── Transit Engine (for auto-unseal)
└── Auto-unseal (using its own transit engine)
```

Enable transit and create the encryption key:
```
kubectl exec -it vault-0 -n vault -- vault secrets enable transit
```

Create the autounseal key
```
kubectl exec -it vault-0 -n vault -- vault write -f transit/keys/autounseal
```

Create a policy for auto-unseal:
```bash
kubectl exec -it vault-0 -n vault -- vault policy write autounseal-policy - <<EOF
path "transit/encrypt/autounseal" {
   capabilities = [ "create", "update" ]
}

path "transit/decrypt/autounseal" {
   capabilities = [ "create", "update" ]
}
EOF
```

Create token with this policy:
```
kubectl exec -it vault-0 -n vault -- vault token create -policy="autounseal-policy"
```

You should see something like this:

```
Key                  Value
----                  -----
token                hvs.<REDACTED>
token_accessor       <REDACTED>
token_duration       768h
token_renewable      true
token_policies       ["autounseal-policy" "default"]
identity_policies    []
policies             ["autounseal-policy" "default"]
```
Save the `token` from the last command and use it in the next step.

Create the transit configuration secret:
```bash
kubectl create secret generic vault-transit-config -n vault --from-file=transit.hcl=/dev/stdin <<EOF
seal "transit" {
  address = "http://vault-primary.vault.svc.cluster.local:8200"
  token = "hvs.<REDACTED>"
  disable_renewal = "false"
  key_name = "autounseal"
  mount_path = "transit/"
  tls_skip_verify = "true"
}
EOF
```

That secret will be mounted into the vault pod and used to configure the transit engine.