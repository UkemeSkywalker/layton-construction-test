# CareLedger — Terraform Infrastructure

Terraform project that provisions a VPC, EC2 instance (Nginx), and RDS (MySQL) on AWS.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│  VPC  192.168.0.0/16                                │
│                                                     │
│  ┌──────────────────┐    ┌──────────────────┐       │
│  │  Public Subnet   │    │  Public Subnet   │       │
│  │  192.168.101.0/24│    │  192.168.102.0/24│       │
│  │  us-east-1a      │    │  us-east-1b      │       │
│  │                  │    │                  │       │
│  │  ┌────────────┐  │    │                  │       │
│  │  │ EC2 (Nginx)│  │    │                  │       │
│  │  └────────────┘  │    │                  │       │
│  └───────┬──────────┘    └──────────────────┘       │
│          │ IGW                                      │
│  ┌──────────────────┐    ┌──────────────────┐       │
│  │  Private Subnet  │    │  Private Subnet  │       │
│  │  192.168.1.0/24  │    │  192.168.2.0/24  │       │
│  │  us-east-1a      │    │  us-east-1b      │       │
│  │                  │    │                  │       │
│  │  ┌────────────┐  │    │                  │       │
│  │  │ RDS (MySQL)│  │    │                  │       │
│  │  └────────────┘  │    │                  │       │
│  └──────────────────┘    └──────────────────┘       │
└─────────────────────────────────────────────────────┘
```

## Modules

| Module | Description |
|--------|-------------|
| `modules/vpc` | VPC with public/private subnets, IGW, NAT gateway, and security groups for EC2 and RDS |
| `modules/ec2` | EC2 instance on Amazon Linux 2023 running Nginx, with CloudWatch StatusCheckFailed alarm |
| `modules/rds` | MySQL 8.0 RDS instance deployed in private subnets |

## EC2 — Nginx Endpoints

| Route | Response |
|-------|----------|
| `GET /` | 200 (default Nginx page) |
| `GET /healthz` | 200 with body `ok` |

## Security Groups

| Name | Inbound | Scope |
|------|---------|-------|
| `careLedger-ec2-sg` | TCP 80 (HTTP) | 0.0.0.0/0 |
| `careLedger-rds-sg` | TCP 3306 (MySQL) | VPC CIDR only |

## Prerequisites

- Terraform >= 1.6.0
- AWS CLI configured with appropriate credentials
- SSH key pair at `~/.ssh/careLedger.pub`
- S3 bucket `heidihealth-bucket` for remote state

## Usage

```bash
# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply
```

## Variables

| Name | Description | Default |
|------|-------------|---------|
| `aws_region` | AWS region | `us-east-2` |
| `project_name` | Project name | — |
| `environment` | Deployment environment | — |

Override defaults in `terraform.tfvars`:

```hcl
aws_region   = "us-east-1"
project_name = "heidihealth_technical_interview"
environment  = "dev"
```

## CI/CD Pipeline

A GitHub Actions workflow (`.github/workflows/terraform-ci.yml`) runs Terraform plans selectively based on changed files:

| Change | Action |
|--------|--------|
| Only `CHANGELOG.md` | Pipeline skipped |
| `apps/payment-api/**` | Plan for payment-api only |
| `global/iam/**` | Plan for all applications |

Plan output is published to the GitHub Actions Job Summary.

Set the `AWS_ROLE_ARN` secret in your GitHub repo for OIDC-based AWS authentication.

## State Management

Remote state is stored in S3:

```hcl
backend "s3" {
  bucket = "heidihealth-bucket"
  key    = "assessment.tfstate"
  region = "us-east-1"
}
```
