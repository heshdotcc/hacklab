# Wireguard Virtual Private Server

This directory contains Terraform configurations to set up a WireGuard VPN server on AWS.

## Prerequisites

- Terraform installed
- AWS CLI configured with appropriate credentials
- WireGuard client installed locally
- AWS Session Manager plugin installed locally

## Configuration

Create a `terraform.tfvars` file with your specific configuration:

```hcls
vpc_cidr         = "172.16.0.0/16"               # VPC network range
subnet_cidr      = "172.16.1.0/24"               # Subnet network range
vpn_cidr         = "10.8.0.0/24"                 # VPN network range
vpn_port         = 51820                         # WireGuard port
peer_public_key  = "YOUR_PUBLIC_KEY"             # Your WireGuard public key
allowed_ips      = "10.8.0.2/32, 172.16.0.0/16"  # Networks accessible through VPN
ami_id           = "ami-xxxxxxxxxx"              # AMI ID for your region
```

## Usage

1. Initialize Terraform:
```bash
terraform init
```

2. Review the planned changes:
```bash
terraform plan -var-file="terraform.tfvars"
```

3. Apply the configuration:
```bash
terraform apply -var-file="terraform.tfvars"
```

4. Connect to the instance using SSM:
```bash
aws ssm start-session --target i-xxxxxxxxxxxxxxxxx
```

## Security Considerations

- Keep your `terraform.tfvars` file secure and never commit it to version control
- Regularly rotate your WireGuard keys
- Access to the instance is managed through AWS IAM roles and policies
- No direct SSH access is configured at all
- All management access is through AWS Systems Manager

## Network Architecture

- VPC: 172.16.0.0/16 (example range)
  - Public Subnet: 172.16.1.0/24
- VPN Network: 10.8.0.0/24
  - Server: 10.8.0.1
  - Clients: 10.8.0.2-10.8.0.254
- SSM VPC Endpoints configured for secure management access

## Cleanup

To destroy the infrastructure:
```bash
terraform destroy -var-file="terraform.tfvars"
```