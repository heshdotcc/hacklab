```shell
helm repo add minio https://charts.min.io/
helm repo update
```

```shell
kustomize build --enable-helm . | kubectl apply -f -
```

