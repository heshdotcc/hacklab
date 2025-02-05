# Istio module

```
helm repo add istio https://istio-release.storage.googleapis.com/charts && helm repo update
```

Take into account that `istio-ingress` directly depends on `istio-system` resources.

Thats the reason why this module is split into two submodules:

- istio/system: contains the `istio-system` namespace and the istio core resources
- istio/ingress: contains the `istio-ingress` namespace and the istio ingress resources

Apply the `istio-system` resources first:
```
cd istio/system && kustomize build --enable-helm . | kubectl apply -f -
```

Then wait for `istio-system` resources to be ready before applying ingress values:
```
kubectl wait --for=condition=Ready pod -l app=istiod -n istio-system
```

Then apply the kustomization located in `ingress` directory.

As well `kiali-operator` also depends on `istio-system` resources, apply it in the final step.