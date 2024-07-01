# Hacklab

Self-hosted Kubernetes CDE for ML with GPU support, including JupyterHub, Monitoring, and a codespace service.

## Directory Structure
```
.
├── jupyterhub
│   ├── flake.nix
│   ├── secrets.nix
│   └── values
│       ├── configmap.yaml
│       ├── deployment.yaml
│       └── services.yaml
├── monitoring
│   ├── flake.lock
│   ├── flake.nix
│   ├── README.md
│   ├── secrets.nix
│   └── values
│       ├── alertmanager
│       ├── grafana
│       └── prometheus
└── README.md
```
### JupyterHub
- Contains configurations for deploying JupyterHub on Kubernetes.
  - `flake.nix`: Nix flake that fetches utils & scoped secrets.
  - `secrets.nix`: Where your secrets templating definiton goes.
  - `values`: Kubernetes YAML files for JupyterHub.
    - `configmap.yaml`
    - `deployment.yaml`
    - `services.yaml`

### Monitoring
- Contains configurations for monitoring stack including Prometheus and Grafana.
  - `flake.nix`: Nix flake that fetches utils & scoped secrets.
  - `README.md`: Documentation for setting up and managing the monitoring stack.
  - `secrets.nix`: Where your secrets templating definiton goes.
  - `values`: Kubernetes YAML files for monitoring components.
    - `alertmanager`
    - `grafana`
    - `prometheus`

### Codespace
- Contains configurations for deploying Coder.com as a codespace.
  - `flake.nix`: Nix flake that fetches utils & scoped secrets.
  - `secrets.nix`: Where your secrets templating definiton goes.
  - `values`: Kubernetes YAML files for Coder.com.
    - `configmap.yaml`
    - `deployment.yaml`
    - `services.yaml`

## Getting Started

### Prerequisites

- Kubernetes cluster with GPU support
- Nix package manager

### Setup

1. **Clone the repository**:
```
  git clone https://github.com/heshdotcc/hacklab.git && cd $_
```