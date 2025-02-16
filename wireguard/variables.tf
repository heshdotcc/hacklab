variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "subnet_cidr" {
  description = "CIDR block for the subnet"
  type        = string
  default     = "172.16.1.0/24"
}

variable "vpn_cidr" {
  description = "CIDR block for the VPN"
  type        = string
  default     = "10.8.0.0/24"
}

variable "vpn_port" {
  description = "Port for WireGuard VPN"
  type        = number
  default     = 51820
}

variable "peer_public_key" {
  description = "Public key for WireGuard peer"
  type        = string
  default     = "i/YOUR-WIREGUARD-BASE64-PUBLIC-KEY="
  sensitive   = true
}

variable "allowed_ips" {
  description = "Allowed IPs for WireGuard"
  type        = string
  default     = "10.8.0.2/32, 172.16.0.0/16"
}

variable "ami_id" {
  description = "AMI ID for the WireGuard instance"
  type        = string
}

variable "instance_profile_name" {
  description = "Name of the IAM instance profile for SSM"
  type        = string
  default     = "wireguard-ssm-profile"
}

variable "iam_role_name" {
  description = "Name of the IAM role for SSM"
  type        = string
  default     = "wireguard-ssm-role"
}
