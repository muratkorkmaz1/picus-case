# Picus Case – Production-Grade AWS Architecture

A production-ready cloud-native application developed using FastAPI, DynamoDB, ECS Fargate, Lambda, Terraform, and GitHub Actions.

[![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20Lambda-orange)](https://aws.amazon.com)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA)](https://www.terraform.io/)
[![FastAPI](https://img.shields.io/badge/Framework-FastAPI-009688)](https://fastapi.tiangolo.com/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF)](https://github.com/features/actions)

## 📋 Table of Contents

- [Overview](#-overview)
- [Architecture](#-architecture)
- [Features](#-features)
- [Installation](#-installation)
- [Usage](#-usage)
- [Infrastructure](#-infrastructure)
- [CI/CD](#-cicd)
- [API Documentation](#-api-documentation)
- [Development](#-development)
- [Monitoring & Logging](#-monitoring--logging)

## 🎯 Overview

This project is a REST API application running on AWS that implements modern DevOps and SRE best practices, fully managed with **Infrastructure as Code (IaC)**.

### Core Purpose

Serving a CRUD API based on DynamoDB with microservices architecture:
- Containerized FastAPI application with **ECS Fargate**
- Serverless DELETE endpoint with **Lambda**
- Automated CI/CD with **zero-downtime deployment** support
- **Production-grade** security, networking, and monitoring

### Live Endpoint

```
https://api.picus.muratkorkmaz.dev
```

## 🏗 Architecture

### High-Level Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                         Internet                             │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │   Cloudflare DNS      │
         │  muratkorkmaz.dev     │
         └───────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │   Route53 (AWS)       │
         │ picus.muratkorkmaz.dev│
         └───────────┬───────────┘
                     │
                     ▼
         ┌───────────────────────┐
         │  Application Load     │
         │     Balancer (ALB)    │
         │   [HTTPS - Port 443]  │
         └─────┬──────────┬──────┘
               │          │
       GET/POST│          │DELETE
               │          │
               ▼          ▼
    ┌──────────────┐   ┌──────────────┐
    │ ECS Fargate  │   │   Lambda     │
    │  (FastAPI)   │   │  (Serverless)│
    └──────┬───────┘   └──────┬───────┘
           │                  │
           └────────┬─────────┘
                    │
                    ▼
         ┌──────────────────┐
         │    DynamoDB      │
         │   Table: picus   │
         └──────────────────┘
```

### Technology Stack

| Layer | Technology | Description |
|--------|-----------|----------|
| **Application** | FastAPI | High-performance Python web framework |
| **Container** | Docker | Containerization with AMD64 platform support |
| **Compute** | ECS Fargate | Serverless container orchestration |
| **Serverless** | AWS Lambda | Event-driven DELETE endpoint |
| **Database** | DynamoDB | NoSQL, fully managed, on-demand billing |
| **Load Balancer** | Application LB | HTTPS termination, health checks |
| **Networking** | VPC, NAT Gateway | Private/public subnet separation |
| **DNS** | Route53 + Cloudflare | Hybrid DNS structure |
| **IaC** | Terraform | All infrastructure managed as code |
| **CI/CD** | GitHub Actions | Automated build, test, deploy |
| **Monitoring** | CloudWatch Logs | Centralized log aggregation |

## ✨ Features

### 🚀 Application

- ✅ RESTful API design (FastAPI)
- ✅ Schemaless data storage with DynamoDB
- ✅ UUID-based record management
- ✅ Timestamp tracking (created_at)
- ✅ Health check endpoint
- ✅ Swagger UI documentation

### 🛡️ Security

- ✅ IAM role-based access control
- ✅ Containers in private subnets
- ✅ Unidirectional internet via NAT Gateway
- ✅ MFA enforcement (root user)
- ✅ HTTPS-only communication
- ✅ SSL/TLS termination at ALB

### 🔄 DevOps

- ✅ Fully automated CI/CD pipeline
- ✅ Zero-downtime deployments
- ✅ Multi-stage Docker builds
- ✅ Automated testing (pytest)
- ✅ Infrastructure drift detection
- ✅ Separate pipelines (app/lambda/infra)

### 📊 Observability

- ✅ CloudWatch Logs integration
- ✅ ALB access logs
- ✅ ECS task logs
- ✅ Lambda execution logs
- ✅ Health check monitoring

## 🚀 Installation

### Requirements

```bash
# For local development
- Python 3.13+
- Docker Desktop
- AWS CLI v2
- Terraform 1.5+
- Node.js 18+ (for Serverless)

# On AWS
- AWS Account
- IAM users (admin + programmatic)
- Domain (Route53 or Cloudflare)
- ACM certificate (for HTTPS)
```

This section explains the basic AWS account configuration performed to prepare AWS resources in a secure, manageable, and production-grade manner within the project scope.

This stage is necessary for the following tools used in subsequent steps of the project:
- **Terraform**
- **Serverless Framework**
- **AWS CLI**
- **GitHub Actions CI/CD**

### 1️⃣ AWS Account Preparation

After creating the AWS account, the first step was to **fully secure the root account**.

#### 📌 1. Securing the Root User

When an AWS account is created, the root account is the **most privileged account** within AWS. Some of the root account's privileges include:

- Modifying billing settings
- Closing or recovering the account
- High-level IAM operations
- Changing AWS Support plan

**Root account risks:**
- Risk increases if used for daily operations
- Complete account control if attackers gain access
- Difficult to recover if password is compromised

**Therefore, we secured the root account as follows:**

##### ✅ MFA (Multi-Factor Authentication) Activated

MFA added a second security layer alongside the password.

##### ✅ Removal of Root Account from Daily Use

**AWS Well-Architected Framework compliant:** Root user is never used for daily operational tasks.

---

#### 📌 2. IAM Users: Management and Programmatic Separation

After securing the root account, **IAM users for daily work** were created.

Two different IAM users were created within the project scope:

##### 🧑‍💼 `picus-admin` — Console Admin User

**Purpose:**  
A user for manual management operations through AWS Console (web interface).

**Features:**
- AWS Management Console access available
- No programmatic access (CLI/SDK)
- AdministratorAccess policy (full privileges)
- MFA required

**Daily AWS Console operations are now performed with this user.**

##### 🤖 `picus-dev` — Programmatic Access User

**Purpose:**  
Provide access to AWS resources from tools like CLI, SDK, Terraform, Serverless Framework, and GitHub Actions.

**Features:**
- **No** AWS Management Console access
- Programmatic access (Access Key) available
- AdministratorAccess policy (during development phase)
  - ⚠️ **Should be narrowed in production** (least privilege principle)
- MFA **optional** (complex with CLI/SDK)

#### AWS CLI Configuration

Configure AWS CLI with the `picus-dev` user on local machine:

```bash
aws configure --profile picus-dev
# AWS Access Key ID: AKIA... (picus-dev's key)
# AWS Secret Access Key: ******
# Default region: eu-central-1
# Default output format: json

# Test
aws sts get-caller-identity --profile picus-dev
```

**Output:**
```json
{
  "UserId": "AIDA...",
  "Account": "358712298152",
  "Arn": "arn:aws:iam::358712298152:user/picus-dev"
}
```

✅ CLI configuration successful.


#### 📌 3. Region Selection

Since AWS is a global cloud provider, you can create your resources in different geographic regions.

**Region selected for the project:**

```
Region: eu-central-1 (Frankfurt, Germany)
```

##### ❓ Why `eu-central-1`?

Region selection was based on the following criteria:

1. **Latency**

2. **Service Maturity**
   - ECS Fargate ✅
   - Lambda ✅
   - DynamoDB ✅
   - ALB ✅
   - Route53 (global) ✅
   - All modern AWS services available

3. **Availability Zone (AZ) Count**
   - `eu-central-1` → **3 AZ** (eu-central-1a, 1b, 1c)
   - Sufficient for High Availability
   - Multi-AZ deployment possible

4. **Price/Performance Balance**

5. **Compliance**

**Result:** All AWS resources were created and configured in the `eu-central-1` region.

### 2️⃣ Infrastructure Setup with Terraform

#### What is Terraform and Why Are We Using It?

**Terraform** is an **Infrastructure as Code (IaC)** tool developed by HashiCorp. Instead of manual AWS Console clicks, you can define and version your infrastructure **as code**.

**Advantages in this project:**

1. **Repeatability**
   - We can easily set up the same infrastructure in different environments (dev/staging/prod)
   - We can create the same infrastructure in minutes in a new AWS account

2. **Version Control**
   - Infrastructure changes are kept in Git
   - Who changed what, when? → Git history
   - Faulty change → rollback possible

3. **Collaboration**
   - Team members can work on the same Terraform codebase
   - Code review possible
   - Infrastructure changes can be proposed via pull requests

4. **State Management**
   - Terraform tracks the state of existing resources in AWS
   - `terraform plan` → shows what will change
   - `terraform apply` → updates only changed resources

#### Terraform Installation Steps

```bash
# 1. Clone repository
git clone <repo-url>
cd picus-case

# 2. Go to Terraform directory
cd infra/terraform

# 3. Check variables
cat terraform.tfvars

# Example content:
# environment = "dev"
# project_name = "picus-case"
# domain_name = "picus.muratkorkmaz.dev"
# certificate_arn = "arn:aws:acm:eu-central-1:358712298152:certificate/..."

# 4. Create plan (show what will change)
terraform plan -out=tfplan

# Example output:
# Plan: 42 to add, 0 to change, 0 to destroy.

# 5. Build infrastructure (be careful!)
terraform apply tfplan

# Request confirmation:
# Do you want to perform these actions?
#   Terraform will perform the actions described above.
#   Only 'yes' will be accepted to approve.
#
# Enter a value: yes

# Takes 15-20 minutes (NAT Gateway, ECS, ALB, etc.)
```

**Terraform Outputs:**

After apply completes, save important values:

```bash
# Show important values
terraform output

# Output:
# alb_dns_name = "picus-alb-1234567890.eu-central-1.elb.amazonaws.com"
# ecr_repository_url = "358712298152.dkr.ecr.eu-central-1.amazonaws.com/picus-api"
# dynamodb_table_name = "picus"
# ecs_cluster_name = "picus-cluster"
# ecs_service_name = "picus-service"

# Get a single output:
terraform output -raw alb_dns_name
```

#### Terraform Workflow Best Practices

```bash
# 1. Run plan before making changes
terraform plan

# 2. Review plan output (what will be deleted, what will be added?)
# Especially check resources marked for "destroy"

# 3. Save plan to file
terraform plan -out=tfplan

# 4. Peer review before apply (optional)
git diff

# 5. Apply the plan
terraform apply tfplan

# 6. Check state
terraform show

# 7. View a specific resource
terraform state show aws_dynamodb_table.picus
```

#### Terraform Module Structure

```
infra/terraform/
├── main.tf              # Provider, backend, general settings
├── variables.tf         # Input variables
├── outputs.tf           # Output values
├── terraform.tfvars     # Variable values
│
├── vpc.tf               # VPC, subnet, IGW, NAT, route tables
├── ecs-service.tf       # ECS cluster, task definition, service
├── alb.tf               # Application Load Balancer, listeners, target groups
├── dynamodb.tf          # DynamoDB table
├── ecr.tf               # Elastic Container Registry
├── iam.tf               # IAM roles, policies
├── route53.tf           # DNS zone, records
└── cloudwatch.tf        # Log groups
```

**Each file manages a single logical component.**

#### Example: DynamoDB Terraform Code

```hcl
# infra/terraform/dynamodb.tf
resource "aws_dynamodb_table" "picus" {
  name         = var.dynamodb_table_name  # "picus"
  billing_mode = "PAY_PER_REQUEST"        # On-demand, automatic scale

  hash_key = "id"  # Partition key

  attribute {
    name = "id"
    type = "S"     # String
  }

  # Point-in-time recovery (backup)
  point_in_time_recovery {
    enabled = true
  }

  # Encryption at rest
  server_side_encryption {
    enabled = true
  }

  tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
  }
}

# Output: Provide DynamoDB table ARN
output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.picus.arn
  description = "ARN of the DynamoDB table"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.picus.name
  description = "Name of the DynamoDB table"
}
```

**What does this code do?**
- Creates a DynamoDB table named `picus`
- Partition key: `id` (String)
- Billing: On-demand (no capacity management needed)
- Backup active
- Encryption active
- Organization with tags

**Usage in IAM policies:**
```hcl
# We will provide this ARN to the ECS task role
data "aws_dynamodb_table" "picus" {
  name = "picus"
}

# IAM policy
statement {
  effect = "Allow"
  actions = [
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:Scan",
  ]
  resources = [data.aws_dynamodb_table.picus.arn]
}
```
Delete permission not given because;
In this architecture, the DELETE /picus/{key} endpoint runs entirely through Lambda.
The FastAPI application on ECS Fargate never performs delete operations.

### 3️⃣ Application Setup (Local)

```bash
cd ../../app

# Virtual environment
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# Dependencies
pip install -r requirements.txt

# Environment variables
cp .env.example .env
# Edit .env file:
# AWS_REGION=eu-central-1
# DYNAMODB_TABLE_NAME=picus
```

### 4️⃣ Building Docker Image and Pushing to ECR

```bash
# Build for AMD64 platform (required for Apple Silicon)
docker buildx build --platform linux/amd64 -t picus-api:latest .

# ECR login
aws ecr get-login-password --region eu-central-1 \
  | docker login --username AWS --password-stdin \
    358712298152.dkr.ecr.eu-central-1.amazonaws.com

# Tag and push
docker tag picus-api:latest \
  358712298152.dkr.ecr.eu-central-1.amazonaws.com/picus-api:latest

docker push \
  358712298152.dkr.ecr.eu-central-1.amazonaws.com/picus-api:latest
```

### 5️⃣ Serverless Lambda Deployment

```bash
cd ../../serverless-delete

# Node modules
npm install

# Deploy with Serverless Framework
npx serverless deploy --stage dev --region eu-central-1

# Save Lambda ARN from output
```

### 6️⃣ DNS Configuration

#### In Cloudflare (muratkorkmaz.dev)

```bash
# Add NS records for DNS → picus.muratkorkmaz.dev:
ns-1287.awsdns-32.org
ns-1786.awsdns-31.co.uk
ns-488.awsdns-61.com
ns-566.awsdns-06.net
```

#### Verification

```bash
# Check NS records
dig NS picus.muratkorkmaz.dev

# Check A record
dig A api.picus.muratkorkmaz.dev

# HTTPS test
curl https://api.picus.muratkorkmaz.dev/picus/health
```

### 7️⃣ GitHub Actions Secrets

Repository → Settings → Secrets and variables → Actions:

```bash
AWS_ACCESS_KEY_ID=AKIA...
AWS_SECRET_ACCESS_KEY=...
AWS_REGION=eu-central-1
SERVERLESS_ACCESS_KEY=... (from Serverless Dashboard)
```

## 💻 Usage

### API Endpoints

#### Health Check

```bash
curl https://api.picus.muratkorkmaz.dev/picus/health

# Response
{
  "status": "ok",
  "message": "Picus-API alive"
}
```

#### Create New Record (POST)

```bash
curl -X POST https://api.picus.muratkorkmaz.dev/picus/put \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Murat Korkmaz",
    "role": "SRE Engineer",
    "team": "Platform"
  }'

# Response
{
  "id": "f9ba2440-e705-4ad7-9179-93c4c5617e0c"
}
```

**Data stored in DynamoDB:**
```json
{
  "id": "f9ba2440-e705-4ad7-9179-93c4c5617e0c",
  "payload": {
    "name": "Murat Korkmaz",
    "role": "SRE Engineer",
    "team": "Platform"
  },
  "created_at": "2025-01-18T14:23:45Z"
}
```

#### Get Single Record (GET)

```bash
curl https://api.picus.muratkorkmaz.dev/picus/get/f9ba2440-e705-4ad7-9179-93c4c5617e0c

# Response
{
  "id": "f9ba2440-e705-4ad7-9179-93c4c5617e0c",
  "payload": {
    "name": "Murat Korkmaz",
    "role": "SRE Engineer",
    "team": "Platform"
  },
  "created_at": "2025-01-18T14:23:45Z"
}
```

#### List All Records (GET)

```bash
curl https://api.picus.muratkorkmaz.dev/picus/list

# Response
{
  "items": [
    {
      "id": "f9ba2440-e705-4ad7-9179-93c4c5617e0c",
      "payload": { "name": "Murat Korkmaz", "role": "SRE Engineer" },
      "created_at": "2025-01-18T14:23:45Z"
    },
    {
      "id": "a1b2c3d4-5678-90ab-cdef-1234567890ab",
      "payload": { "name": "Jane Doe", "role": "DevOps" },
      "created_at": "2025-01-18T15:10:22Z"
    }
  ]
}
```

#### Delete Record (DELETE) - Lambda

```bash
curl -X DELETE https://api.picus.muratkorkmaz.dev/picus/f9ba2440-e705-4ad7-9179-93c4c5617e0c

# Response
{
  "deleted": "f9ba2440-e705-4ad7-9179-93c4c5617e0c"
}
```

### Swagger UI

```
https://api.picus.muratkorkmaz.dev/docs#/
```

Interactive API documentation and test interface.

## 🏗 Infrastructure

### Directory Structure

```
picus-case/
├── app/                          # FastAPI application
│   ├── src/
│   │   ├── main.py              # FastAPI entry point
│   │   ├── config.py            # Environment variables
│   │   ├── db.py                # DynamoDB client
│   │   ├── models.py            # Pydantic models
│   │   └── routes/
│   │       └── picus.py         # API endpoints
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
│
├── serverless-delete/            # Lambda function
│   ├── handler.py               # DELETE logic
│   ├── serverless.yml           # Serverless config
│   └── package.json
│
├── infra/
│   └── terraform/               # IaC definitions
│       ├── main.tf              # Provider, backend
│       ├── vpc.tf               # VPC, subnet, NAT
│       ├── ecs-service.tf       # ECS cluster, service
│       ├── alb.tf               # Load balancer
│       ├── dynamodb.tf          # DynamoDB table
│       ├── ecr.tf               # Container registry
│       ├── iam.tf               # IAM roles, policies
│       ├── route53.tf           # DNS
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
│
└── .github/
    └── workflows/
        ├── ci-cd.yml            # App CI/CD
        ├── lambda-ci.yml        # Lambda CI/CD
        └── infra-ci.yml         # Terraform CI
```

### Terraform Modules

#### VPC and Networking

```hcl
# 2 AZ, public/private subnet separation
# Internet Gateway + NAT Gateway
# Route tables

CIDR: 10.0.0.0/16
Public Subnets: 10.0.1.0/24, 10.0.2.0/24
Private Subnets: 10.0.3.0/24, 10.0.4.0/24
```

#### ECS Fargate

```hcl
# Cluster: picus-cluster
# Service: picus-service
# Task Definition:
#   - CPU: 256 (.25 vCPU)
#   - Memory: 512 MB
#   - Desired count: 2 (HA)
#   - Deployment: min 100%, max 200% (zero-downtime)
```

#### Application Load Balancer

```hcl
# Listeners:
#   - HTTP:80 → HTTPS redirect
#   - HTTPS:443 → Target Groups
#
# Target Groups:
#   1. ECS: GET/POST /picus/*
#   2. Lambda: DELETE /picus/*
#
# Health Check:
#   - Path: /picus/health
#   - Interval: 20s
#   - Healthy threshold: 2
```

#### DynamoDB

```hcl
resource "aws_dynamodb_table" "picus" {
  name         = "picus"
  billing_mode = "PAY_PER_REQUEST"  # On-demand (automatic scaling)
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"  # String
  }

  tags = {
    Environment = "dev"
    Project     = "picus-case"
  }
}
```

### Networking Details

#### VPC Design and Rationale

**Virtual Private Cloud (VPC)** is the **isolated virtual network** in which all resources in AWS run. Like the internet, but only under your control.

##### 🎯 Design Decisions

**1. CIDR Block Selection**

```
VPC CIDR: 10.0.0.0/16
```

**Why this block?**
- RFC 1918 private IP range (10.0.0.0/8)
- `/16` netmask = **65,536 IP addresses** (10.0.0.1 - 10.0.255.254)
- Large enough (subnets can be added in the future)
- Small enough (doesn't unnecessarily consume space)
- Low collision risk with other VPCs if peering is done

**Alternatives and why not chosen:**
- `192.168.0.0/16` → High collision risk with home/office networks
- `172.16.0.0/12` → Generally used in corporate networks
- `10.0.0.0/24` → Too small (256 IP), no room for expansion

**2. Subnet Strategy: Public vs Private**

```
Public Subnets:
  - 10.0.1.0/24  (AZ: eu-central-1a) - 256 IP
  - 10.0.2.0/24  (AZ: eu-central-1b) - 256 IP

Private Subnets:
  - 10.0.3.0/24 (AZ: eu-central-1a) - 256 IP
  - 10.0.4.0/24 (AZ: eu-central-1b) - 256 IP
```

**Public Subnet Features:**
- Direct internet access via Internet Gateway (IGW)
- Can receive public IP addresses
- Can accept traffic from the internet
- **Running here:**
  - Application Load Balancer (ALB)
  - NAT Gateway
  - Bastion hosts (optional)

**Private Subnet Features:**
- **No** direct internet access
- Unidirectional internet access via NAT Gateway
- Traffic from the internet **cannot directly access**
- **Running here:**
  - ECS Fargate tasks (containers)
  - RDS databases (if used)
  - Lambda functions (if in VPC)
  - ElastiCache, RedShift, etc.

**Why 2 subnets (Multi-AZ)?**
- **High Availability (HA)**: If one AZ fails, service continues from the other AZ
- **ALB requirement**: ALB requires subnets in at least 2 AZs
- **ECS service**: Tasks can be distributed across different AZs
- **Disaster recovery**: No dependency on a single AZ

**3. Why /24 Netmask?**

```
/24 = 256 IP addresses (251 usable, 5 AWS reserved)
```

**AWS reserved IPs:**
- `10.0.1.0` → Network address
- `10.0.1.1` → VPC router
- `10.0.1.2` → DNS server
- `10.0.1.3` → Future use
- `10.0.1.255` → Broadcast (AWS doesn't use but reserves)

#### NAT Gateway: Why Necessary and How It Works?

##### ❓ Problem: How Will Containers in Private Subnet Access the Internet?

**Scenario:**
1. ECS Fargate task starts in private subnet
2. Container needs to **pull Docker image from ECR** to start
3. ECR is on the internet → Container can't start if it can't access the internet
4. Container doesn't start ❌

**Also:**
- DynamoDB endpoint is on the internet (or if VPC endpoint not used)
- `pip install` / `apt-get update` require internet access
- AWS API calls (CloudWatch logs, etc.) go to the internet

##### ✅ Solution: NAT Gateway

**What does NAT Gateway do?**
- Enables resources in private subnet to access the internet **unidirectionally**
- Ensures security by **blocking** traffic from the internet

**Flow:**

```
ECS Task (private subnet, 10.0.11.5)
    ↓
    ├─ "Pull image from ECR" request
    ↓
NAT Gateway (public subnet)
    ↓
    ├─ NAT: Source IP 10.0.11.5 → Converted to NAT's public IP
    ↓
Internet Gateway
    ↓
Amazon ECR (Container Registry endpoint)
    ↓
    ├─ Sends back Docker image layers
    ↓
NAT Gateway (redirects response back to 10.0.11.5)
    ↓
ECS Task (image successfully pulled ✅)
```

**Important Points:**

1. **Unidirectional:**
   - Private → Internet ✅
   - Internet → Private ❌

2. **NAT Gateway must be in public subnet:**
   - Because it also needs to access the internet

3. **Elastic IP required:**
   - NAT Gateway must have a static public IP

##### 🔧 NAT Gateway Setup with Terraform

```hcl
# 1. Create Elastic IP
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# 2. Create NAT Gateway (in public subnet)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  # Public subnet

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.main]
}

# 3. Add to private subnet route table
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
```

**Route table logic:**

```
Public Route Table:
  - 10.0.0.0/16 → local (within VPC)
  - 0.0.0.0/0   → Internet Gateway (all internet traffic)

Private Route Table:
  - 10.0.0.0/16 → local (within VPC)
  - 0.0.0.0/0   → NAT Gateway (internet traffic exits via NAT)
```

##### 🐛 Issue Encountered: Missing NAT Gateway

**Initially NAT Gateway was missing:**

```bash
# Error when ECS task starts:
CannotPullContainerError: 
  Error response from daemon: 
  Get https://358712298152.dkr.ecr.eu-central-1.amazonaws.com/v2/: 
  dial tcp: lookup 358712298152.dkr.ecr.eu-central-1.amazonaws.com: 
  i/o timeout
```

**Reason:**
- ECS task in private subnet
- Internet needed to access ECR
- No NAT Gateway → no internet access

**Solution:**
1. Added NAT Gateway to Terraform
2. Redirected private route table 0.0.0.0/0 → NAT Gateway
3. Ran `terraform apply`
4. Redeployed ECS service
5. Container started successfully ✅

#### Internet Gateway vs NAT Gateway

| Feature | Internet Gateway | NAT Gateway |
|---------|------------------|-------------|
| **Direction** | Bidirectional (inbound+outbound) | Unidirectional (outbound only) |
| **Usage** | For public subnets | For private subnets |
| **Public IP** | On resources themselves | On NAT Gateway (Elastic IP) |
| **Security** | Controlled with security groups | No internet access |
| **Cost** | Free | ~$32/month + data transfer |
| **HA** | Managed by AWS | Single AZ (multiple needed for Multi-AZ) |

### 🔐 Security Groups

Two main security groups are used in this architecture:

- **ALB Security Group** → The only entry point open to the internet
- **ECS Security Group** → Backend that only accepts traffic from ALB

```hcl
# ALB Security Group
Inbound:
  - 443/TCP from 0.0.0.0/0
  - 80/TCP from 0.0.0.0/0
Outbound:
  - All traffic

# ECS Security Group
Inbound:
  - 8000/TCP from ALB-SG
Outbound:
  - 443/TCP to 0.0.0.0/0 (HTTPS - ECR, DynamoDB)
```

## 🔄 CI/CD

### Pipeline Structure

#### 1. Application Pipeline (ci-cd.yml)

**Trigger:**
```yaml
on:
  push:
    paths:
      - 'app/**'
      - '.github/workflows/ci-cd.yml'
```

**Jobs:**

```mermaid
graph LR
    A[Checkout] --> B[Setup Python]
    B --> C[Install Dependencies]
    C --> D[Run Tests]
    D --> E[Build Docker AMD64]
    E --> F[Push to ECR]
    F --> G[Deploy to ECS]
```

**Critical Steps:**

```yaml
# 1. Python test
- name: Run tests
  run: |
    cd app
    pip install -r requirements.txt
    pytest tests/ || python -m compileall src

# 2. Docker build (platform important!)
- name: Build image
  run: |
    docker buildx build \
      --platform linux/amd64 \
      -t picus-api:${{ github.sha }} \
      app/

# 3. ECS deployment
- name: Deploy to ECS
  run: |
    aws ecs update-service \
      --cluster picus-cluster \
      --service picus-service \
      --force-new-deployment
```

#### 2. Lambda Pipeline (lambda-ci.yml)

**Trigger:**
```yaml
on:
  push:
    paths:
      - 'serverless-delete/**'
      - '.github/workflows/lambda-ci.yml'
```

**Jobs:**
```bash
1. npm ci
2. npx serverless deploy --stage dev
```

#### 3. Infrastructure Pipeline (infra-ci.yml)

**Trigger:**
```yaml
on:
  push:
    paths:
      - 'infra/**'
      - '.github/workflows/infra-ci.yml'
```

**Jobs:**
```bash
1. terraform fmt -check
2. terraform init -backend=false
3. terraform validate
4. terraform plan -lock=false
```

⚠️ **Important:** `terraform apply` doesn't run in CI. Infrastructure changes require manual approval.

### Zero-Downtime Deployment Strategy

```hcl
# ecs-service.tf
deployment_minimum_healthy_percent = 100
deployment_maximum_percent         = 200
```

**Deployment Flow:**

```
1. Current: 2 tasks running (100%)
2. Start new task: 4 tasks running (200%)
3. Health check: Are new tasks healthy?
4. Yes → Stop old tasks
5. Result: 2 new tasks running (100%)

Downtime: 0 seconds ✅
```

## 📚 API Documentation

### Endpoint Summary

| Method | Path | Handler | Description |
|--------|------|---------|----------|
| GET | `/picus/health` | FastAPI | Health check |
| POST | `/picus/put` | FastAPI | Create new record |
| GET | `/picus/get/{id}` | FastAPI | Get single record |
| GET | `/picus/list` | FastAPI | List all records |
| DELETE | `/picus/{id}` | Lambda | Delete record |

### Request/Response Models

#### POST /picus/put

**Request:**
```json
{
  "name": "string",       // Required
  "role": "string",       // Required
  "team": "string",       // Optional
  "email": "string",      // Optional
  // ... any JSON payload
}
```

**Response (201):**
```json
{
  "id": "uuid-v4-string"
}
```

#### GET /picus/get/{id}

**Response (200):**
```json
{
  "id": "uuid",
  "payload": { /* original data */ },
  "created_at": "ISO-8601 timestamp"
}
```

**Response (404):**
```json
{
  "detail": "Item not found"
}
```

### Error Handling

```python
# FastAPI automatic validation
422 Unprocessable Entity - JSON schema error

# Custom exceptions
404 Not Found - Record not found
500 Internal Server Error - DynamoDB error
```

## 🛠 Development

### Local Development

```bash
# 1. Clone repo
git clone <repo-url>
cd picus-case/app

# 2. Virtual environment
python3 -m venv .venv
source .venv/bin/activate

# 3. Dependencies
pip install -r requirements.txt

# 4. Environment variables
export AWS_REGION=eu-central-1
export AWS_ACCESS_KEY_ID=your-key
export AWS_SECRET_ACCESS_KEY=your-secret
export DYNAMODB_TABLE_NAME=picus

# 5. Run with Uvicorn
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

**Swagger UI:**
```
http://localhost:8000/docs
```

### Local Testing with Docker

```bash
# Build
docker build -t picus-api:local .

# Run
docker run --rm -p 8000:8000 \
  -e AWS_REGION=eu-central-1 \
  -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
  -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
  -e DYNAMODB_TABLE_NAME=picus \
  picus-api:local

# Test
curl http://localhost:8000/picus/health
```

### Code Style

```bash
# Black formatter
pip install black
black src/

# Linting
pip install flake8
flake8 src/

# Type checking
pip install mypy
mypy src/
```

### Testing

```bash
# Unit tests
pytest tests/unit/

# Integration tests
pytest tests/integration/

# Coverage report
pytest --cov=src tests/
```

## 📊 Monitoring & Logging

### CloudWatch Logs

#### ECS Logs

```bash
# Log Group: /ecs/picus-api
# Stream: ecs/picus-api/{task-id}

# View with AWS CLI
aws logs tail /ecs/picus-api --follow --region eu-central-1
```

#### Lambda Logs

```bash
# Log Group: /aws/lambda/picus-delete-dev-deletePicusItem

# Tail logs
aws logs tail /aws/lambda/picus-delete-dev-deletePicusItem --follow
```

### ALB Metrics

```bash
# CloudWatch Metrics
- TargetResponseTime
- RequestCount
- HTTPCode_Target_2XX_Count
- HTTPCode_Target_4XX_Count
- HTTPCode_Target_5XX_Count
- HealthyHostCount
- UnHealthyHostCount
```

### DynamoDB Metrics

```bash
- ConsumedReadCapacityUnits
- ConsumedWriteCapacityUnits
- UserErrors
- SystemErrors
```

### Log Query Examples

```bash
# Find 5xx errors
fields @timestamp, @message
| filter @message like /5[0-9]{2}/
| sort @timestamp desc

# Slow requests (>1s)
fields @timestamp, @message
| filter @message like /response_time/
| filter response_time > 1000
| sort response_time desc
```