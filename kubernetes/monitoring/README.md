# Monitoring with Prometheus, Grafana, and Alertmanager
![image](https://github.com/heshdotcc/hacklab/assets/4110061/2fbfb000-1bf2-4071-973f-5a1d0642f552)
<p align="center"><em>Granfa dashboard reporting <a href="https://github.com/NVIDIA/dcgm-exporter">NVIDIA Data Center GPU Manager (DCGM)</a> & <a href="https://github.com/kubernetes/kube-state-metrics">Kube State</a> exporters metrics</em></p>

## About
This directory contains the Kubernetes YAML configurations to deploy Prometheus, Grafana, and Alertmanager.

It also uses Nix with flakes to fetch utils & secrets from an external input to securely encode manifests.

**Note: Secret management is beign moved into `kubernetes/security` and replaced by [Sealed Secrets](https://github.com/bitnami-labs/sealed-secrets) and [External Secrets](https://github.com/external-secrets/external-secrets).**

## Tree
```
.
├── alertmanager
├── alloy
├── grafana
├── loki
├── migrate
├── prometheus
└── tempo
```
This structure organizes the configuration files into directories for each component, making it easier to navigate and manage the setup.

## Components

**Note: This section is being upgraded to its next version.**

### Alertmanager

Handles alerts sent by Prometheus. Configurations are in the `values/alertmanager` directory.

### Grafana

Provides a web interface for visualizing metrics. Configurations are in the `values/grafana` directory.

### Prometheus

The central monitoring tool that scrapes metrics from various sources. Configurations are in the `values/prometheus` directory.

### Exporters

- **Node Exporter**: Collects hardware and OS metrics. Configurations are in `values/prometheus/node-exporter`.
- **DCGM Exporter**: Collects GPU metrics. Configurations are in `values/prometheus/dcgm-exporter`.
- **Kube-State-Metrics**: Exposes Kubernetes cluster state metrics. Configurations are in `values/prometheus/kube-state-metrics`.



## Guide
### Secrets management
To leverage Nix, you will need to provide an external `env` flake input alike:
```nix
{
  outputs = { ... }: {
    infra = {
      grafana = "<REDACTED>";
      recipient_email = "<REDACTED>";
      smtp_auth_username = "<REDACTED>";
      smtp_auth_password = "<REDACTED>";
      smtp_from = "<REDACTED>";
      smtp_smarthost = "<REDACTED>";
    };
  };
}
```
Once your own flake is defined specify the manifest templates in `secrets.nix` file and execute `nix develop` command.

### Namespace Setup

Create the `monitoring` namespace:
```
kubectl create namespace monitoring
```
Ensure the namespace exists before proceeding.

### Prometheus
```
kubectl apply -R -f values/prometheus/
```
Prometheus is configured to scrape metrics from:
* Prometheus itself
* Node Exporter
* Kube State Metrics
* NVIDIA DCGM Exporter
  
View Prometheus values as a whole with `cat values/prometheus/*` command.

### Apply Alertmanager
```
kubectl apply -R -f values/alertmanager/
```

It's configured to send email alerts. Make sure the `alertmanager-email-secret` contains the correct email configuration.

### Grafana
```
kubectl apply -R -f values/grafana/
```
It's set up with a default Prometheus data source. Ensure the `grafana-admin-secret` contains the correct admin password.

### SSH & Port Forwarding
To access Grafana or Prometheus locally:
```
ssh -L 3000:localhost:3000 -L 9090:localhost:9090 -p <SSH_PORT> <USER>@<HOST>
```
Replace `<SSH_PORT>`, `<USER>`, and `<HOST>` with your actual SSH port, username, and server hostname.

### Useful Tips

- Ensure your kube-state-metrics service account has the necessary permissions.
    - Refer to the clusterrole.yaml and clusterrolebinding.yaml files in values/prometheus/kube-state-metrics.
- Network policies might affect service connectivity.
    - Verify the network policy configurations:
        - `values/grafana/network-policy.yaml`
        - `values/prometheus/node-exporter/network-policy.yaml`

## Troubleshooting

Before diving into specific troubleshooting steps, ensure the following:

- **Double-check NVIDIA installation** Verify that NVIDIA drivers are properly installed.
    - For NixOS users, refer to [heshdotcc/dotfiles](https://github.com/heshdotcc/dotfiles) for more guidance.
- **Ensure CUDA version consistency** The CUDA version reported by `nvidia-smi` matches the version tag you use for your test pods.
    - Example: The following YAML works with CUDA Version 12.5.
```YAML
kind: Pod
metadata:
  name: test-pod-gpu
spec:
  restartPolicy: OnFailure
  runtimeClassName: nvidia
  containers:
    - name: cuda-shell
      image: nvidia/cuda:12.4.0-base-ubuntu22.04
      command: ["/bin/sh", "-c", "while true; do sleep 30; done"]
      resources:
        limits:
          nvidia.com/gpu: 1
      env:
        - name: NVIDIA_VISIBLE_DEVICES
          value: all
        - name: NVIDIA_DRIVER_CAPABILITIES
          value: all
```

Make use of networking tools to scan ports and verify connectivity, run for example `nix-shell -p lsof nmap` and then:

`sudo nmap -p 6443,10250,8080,9100,9400 10.0.2.10` or `sudo lsof -i -P -n | grep -E '6443|10250|8080|9100|9400'`


### Common Commands

- Check logs for `kube-state-metrics`:
```sh
kubectl logs -n monitoring -l app=kube-state-metrics
```

- Check logs for `nvidia-dcgm-exporter`:
```sh
kubectl logs -n monitoring -l app=dcgm-exporter
```

- Test connectivity to Prometheus from Grafana pod:
```
kubectl exec -it -n monitoring <grafana-pod> -- curl -v http://prometheus-server.monitoring.svc.cluster.local:9090
```
