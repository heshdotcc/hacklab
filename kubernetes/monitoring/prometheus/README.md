# Prometheus module

This module provisions the [kube-prometheus-stack](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack) and the [dcgm-exporter](https://github.com/NVIDIA/dcgm-exporter/tree/main/charts/dcgm-exporter) from the NVIDIA organization:

* Feel free to tweak it as your needs, for example, the `dcgm-exporter` is not enabled by default.
* I've opted for not including Grafana nor Alertmanager to provision each one in its own module.
* The rationale beyond choosing `kube-prometheus-stack` resides in the fact that it supports [Thanos](https://github.com/thanos-io/thanos).

## Steps

```
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add gpu-helm-charts https://nvidia.github.io/dcgm-exporter/helm-charts
helm repo update
```

If you need to upgrade or know the latest version, you can run respectively:
```
helm search repo gpu-helm-charts/dcgm-exporter
```
Or:
```
helm search repo prometheus-community/prometheus
```


The Kustomize build can be created with command:
```
kustomize build --enable-helm . | kubectl apply -f -
```

And recreated by deleting the resources previous to the `apply` command:
```
kustomize build --enable-helm . | kubectl delete -f -
```

