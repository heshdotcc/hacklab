# Monitoring with Prometheus, Grafana, and Alertmanager

## About
This directory contains the Kubernetes YAML configurations to deploy Prometheus, Grafana, and Alertmanager.

It also uses Nix with flakes to fetch utils & secrets from an external input to securely encode manifests.

## Tree
```
.
├── flake.lock
├── flake.nix
├── secrets.nix
└── values
    ├── alertmanager
    │   ├── configmap.yaml
    │   ├── deployment.yaml
    │   ├── secret.yaml
    │   └── service.yaml
    ├── grafana
    │   ├── configmap.yaml
    │   ├── deployment.yaml
    │   ├── secret.yaml
    │   └── service.yaml
    └── prometheus
        ├── configmap.yaml
        ├── deployment.yaml
        └── service.yaml
```

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
