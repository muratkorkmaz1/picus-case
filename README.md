# Picus Case – Production-Grade AWS Mimari

FastAPI, DynamoDB, ECS Fargate, Lambda, Terraform ve GitHub Actions kullanarak geliştirilmiş, production-ready bir cloud-native uygulama.

[![AWS](https://img.shields.io/badge/AWS-ECS%20%7C%20Lambda-orange)](https://aws.amazon.com)
[![Terraform](https://img.shields.io/badge/IaC-Terraform-844FBA)](https://www.terraform.io/)
[![FastAPI](https://img.shields.io/badge/Framework-FastAPI-009688)](https://fastapi.tiangolo.com/)
[![CI/CD](https://img.shields.io/badge/CI%2FCD-GitHub%20Actions-2088FF)](https://github.com/features/actions)

## 📋 İçindekiler

- [Genel Bakış](#-genel-bakış)
- [Mimari](#-mimari)
- [Özellikler](#-özellikler)
- [Kurulum](#-kurulum)
- [Kullanım](#-kullanım)
- [Altyapı](#-altyapı)
- [CI/CD](#-cicd)
- [API Dokümantasyonu](#-api-dokümantasyonu)
- [Geliştirme](#-geliştirme)
- [Monitoring & Logging](#-monitoring--logging)

## 🎯 Genel Bakış

Bu proje, modern DevOps ve SRE best practice'lerini uygulayan, AWS üzerinde çalışan **tamamen Infrastructure as Code (IaC)** ile yönetilen bir REST API uygulamasıdır.

### Temel Amaç

DynamoDB tabanlı bir CRUD API'sini mikroservis mimarisiyle sunmak:
- **ECS Fargate** ile containerized FastAPI uygulaması
- **Lambda** ile serverless DELETE endpoint
- **Zero-downtime deployment** destekli otomatik CI/CD
- **Production-grade** güvenlik, networking ve monitoring

### Canlı Endpoint

```
https://api.picus.muratkorkmaz.dev
```

## 🏗 Mimari

### Yüksek Seviye Diyagram

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

### Teknoloji Stack

| Katman | Teknoloji | Açıklama |
|--------|-----------|----------|
| **Application** | FastAPI | Yüksek performanslı Python web framework |
| **Container** | Docker | AMD64 platform desteği ile containerization |
| **Compute** | ECS Fargate | Serverless container orchestration |
| **Serverless** | AWS Lambda | Event-driven DELETE endpoint |
| **Database** | DynamoDB | NoSQL, fully managed, on-demand billing |
| **Load Balancer** | Application LB | HTTPS termination, health checks |
| **Networking** | VPC, NAT Gateway | Private/public subnet separation |
| **DNS** | Route53 + Cloudflare | Hybrid DNS yapısı |
| **IaC** | Terraform | Tüm infra kod olarak yönetiliyor |
| **CI/CD** | GitHub Actions | Otomatik build, test, deploy |
| **Monitoring** | CloudWatch Logs | Merkezi log toplama |

## ✨ Özellikler

### 🚀 Uygulama

- ✅ RESTful API tasarımı (FastAPI)
- ✅ DynamoDB ile schemaless data storage
- ✅ UUID bazlı kayıt yönetimi
- ✅ Timestamp tracking (created_at)
- ✅ Health check endpoint
- ✅ Swagger UI dokümantasyonu

### 🛡️ Güvenlik

- ✅ IAM role-based access control
- ✅ Private subnet'te container'lar
- ✅ NAT Gateway ile tek yönlü internet
- ✅ MFA zorunluluğu (root user)
- ✅ HTTPS-only communication
- ✅ ALB üzerinde SSL/TLS termination

### 🔄 DevOps

- ✅ Tam otomatik CI/CD pipeline
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

## 🚀 Kurulum

### Gereksinimler

```bash
# Yerel geliştirme için
- Python 3.13+
- Docker Desktop
- AWS CLI v2
- Terraform 1.5+
- Node.js 18+ (Serverless için)

# AWS üzerinde
- AWS Account
- IAM kullanıcıları (admin + programmatic)
- Domain (Route53 veya Cloudflare)
- ACM sertifikası (HTTPS için)
```

Bu bölüm, proje kapsamında kullanılacak AWS kaynaklarının güvenli, yönetilebilir ve production-grade bir şekilde hazırlanması için yapılan temel AWS hesap yapılandırmasını açıklamaktadır.

Bu aşama, projede ilerleyen adımlarda kullanılacak olan:
- **Terraform**
- **Serverless Framework**
- **AWS CLI**
- **GitHub Actions CI/CD**

gibi araçların **sağlıklı çalışabilmesi** için gereklidir.

### 1️⃣ AWS Hesap Hazırlığı

AWS hesabı oluşturulduktan sonra yapılan ilk işlem, **root hesabını tamamen güvene almak** olmuştur.

#### 📌 1. Root User Güvenliğinin Sağlanması

AWS hesabı oluşturulduğunda, root hesabı AWS içerisindeki **en yetkili hesaptır**. Root hesabın yetkilerinden bazıları:

- Billing (ödeme) ayarlarını değiştirme
- Hesabı kapatma veya kurtarma
- IAM üst düzey işlemleri
- AWS Support planı değiştirme

**Root hesabın tehlikeleri:**
- Günlük işlemlerde kullanılırsa risk artar
- Saldırganlar ele geçirirse tüm hesabı kontrol ederler
- Parola sızarsa telafisi zor

**Bu nedenle root hesabını şu şekilde güvenli hale getirdik:**

##### ✅ MFA (Multi-Factor Authentication) Aktif Edildi

MFA, parolanın yanında ikinci bir güvenlik katmanı eklendi.

##### ✅ Root Hesabının Günlük Kullanımdan Kaldırılması

**AWS Well-Architected Framework'e uygun:** Root kullanıcı, günlük operasyonel işlemlerde asla kullanılmıyor.

---

#### 📌 2. IAM Kullanıcıları: Yönetim ve Programmatic Ayrımı

Root hesap güvenli hale getirildikten sonra, **günlük çalışmalar için IAM kullanıcıları** oluşturuldu.

Proje kapsamında iki farklı IAM kullanıcısı oluşturuldu:

##### 🧑‍💼 `picus-admin` — Console Admin User

**Amaç:**  
AWS Console (web arayüzü) üzerinden manuel yönetim işlemleri için kullanılacak bir kullanıcı.

**Özellikleri:**
- AWS Management Console erişimi var
- Programmatic access (CLI/SDK) yok
- AdministratorAccess policy'si var (tam yetki)
- MFA zorunlu

**Artık günlük AWS Console işlemleri bu kullanıcı ile yapılıyor.**

##### 🤖 `picus-dev` — Programmatic Access User

**Amaç:**  
CLI, SDK, Terraform, Serverless Framework ve GitHub Actions gibi araçlardan AWS kaynaklarına erişim sağlamak.

**Özellikleri:**
- AWS Management Console erişimi **yok**
- Programmatic access (Access Key) var
- AdministratorAccess policy'si var (development aşamasında)
  - ⚠️ **Production'da daraltılmalı** (least privilege principle)
- MFA **opsiyonel** (CLI/SDK'da MFA karmaşık)

#### AWS CLI Yapılandırması

Lokal makinede `picus-dev` kullanıcısı ile AWS CLI'yi yapılandırmak:

```bash
aws configure --profile picus-dev
# AWS Access Key ID: AKIA... (picus-dev'in key'i)
# AWS Secret Access Key: ******
# Default region: eu-central-1
# Default output format: json

# Test
aws sts get-caller-identity --profile picus-dev
```

**Çıktı:**
```json
{
  "UserId": "AIDA...",
  "Account": "358712298152",
  "Arn": "arn:aws:iam::358712298152:user/picus-dev"
}
```

✅ CLI yapılandırması başarılı.

**Artık tüm AWS CLI komutlarında:**
```bash
aws s3 ls --profile picus-dev
terraform apply  # ~/.aws/credentials'dan otomatik okur
```

---

#### 📌 3. Bölge (Region) Seçimi

AWS, global bir cloud provider olduğu için kaynaklarınızı farklı coğrafi bölgelerde (region) oluşturabilirsiniz.

**Proje için seçilen region:**

```
Region: eu-central-1 (Frankfurt, Almanya)
```

##### ❓ Neden `eu-central-1`?

Bölge seçimi, aşağıdaki kriterlere göre yapıldı:

1. **Latency (Gecikme Süresi)**

2. **Servis Olgunluğu**
   - ECS Fargate ✅
   - Lambda ✅
   - DynamoDB ✅
   - ALB ✅
   - Route53 (global) ✅
   - Tüm modern AWS servisleri mevcut

3. **Availability Zone (AZ) Sayısı**
   - `eu-central-1` → **3 AZ** (eu-central-1a, 1b, 1c)
   - High Availability için yeterli
   - Multi-AZ deployment mümkün

4. **Fiyat/Performans Dengesi**

5. **Compliance**

**Sonuç:** Tüm AWS kaynakları `eu-central-1` bölgesinde oluşturuldu ve yapılandırıldı.

### 2️⃣ Terraform ile Altyapı Kurulumu

#### Terraform Nedir ve Neden Kullanıyoruz?

**Terraform**, HashiCorp tarafından geliştirilen bir **Infrastructure as Code (IaC)** aracıdır. Manuel AWS Console tıklamaları yerine, altyapınızı **kod olarak** tanımlayıp versiyonlayabilirsiniz.

**Bu projedeki avantajları:**

1. **Tekrarlanabilirlik**
   - Aynı altyapıyı farklı ortamlarda (dev/staging/prod) kolayca kurabiliriz
   - Yeni bir AWS hesabında aynı altyapıyı dakikalar içinde oluşturabiliriz

2. **Versiyon Kontrolü**
   - Altyapı değişiklikleri Git'te tutulur
   - Kim, ne zaman, neyi değiştirdi? → Git history
   - Hatalı değişiklik → rollback mümkün

3. **Collaboration**
   - Ekip üyeleri aynı Terraform kod tabanında çalışabilir
   - Code review yapılabilir
   - Pull request ile altyapı değişikliği önerilebilir

4. **State Management**
   - Terraform, AWS'deki mevcut kaynakların durumunu (state) takip eder
   - `terraform plan` → ne değişecek gösterir
   - `terraform apply` → sadece değişen kaynakları günceller


#### Terraform Kurulum Adımları

```bash
# 1. Repository klonlama
git clone <repo-url>
cd picus-case

# 2. Terraform dizinine git
cd infra/terraform

# 3. Backend yapılandırması (S3 + DynamoDB lock)
terraform init

# Çıktı:
# Initializing the backend...
# Successfully configured the backend "s3"!

# 4. Değişkenleri kontrol et
cat terraform.tfvars

# Örnek içerik:
# environment = "dev"
# project_name = "picus-case"
# domain_name = "picus.muratkorkmaz.dev"
# certificate_arn = "arn:aws:acm:eu-central-1:358712298152:certificate/..."

# 5. Plan oluştur (ne değişecek göster)
terraform plan -out=tfplan

# Çıktı örneği:
# Plan: 42 to add, 0 to change, 0 to destroy.

# 6. Altyapıyı kur (dikkatli olun!)
terraform apply tfplan

# Onay iste:
# Do you want to perform these actions?
#   Terraform will perform the actions described above.
#   Only 'yes' will be accepted to approve.
#
# Enter a value: yes

# 15-20 dakika sürer (NAT Gateway, ECS, ALB vb.)
```

**Terraform Outputs:**

Apply tamamlandıktan sonra önemli değerleri kaydedin:

```bash
# Önemli değerleri göster
terraform output

# Çıktı:
# alb_dns_name = "picus-alb-1234567890.eu-central-1.elb.amazonaws.com"
# ecr_repository_url = "358712298152.dkr.ecr.eu-central-1.amazonaws.com/picus-api"
# dynamodb_table_name = "picus"
# ecs_cluster_name = "picus-cluster"
# ecs_service_name = "picus-service"

# Tek bir output'u almak:
terraform output -raw alb_dns_name
```

#### Terraform Workflow Best Practices

```bash
# 1. Değişiklik yapmadan önce plan çalıştır
terraform plan

# 2. Plan çıktısını incele (ne silinecek, ne eklenecek?)
# Özellikle "destroy" işaretli kaynakları kontrol et

# 3. Plan'ı dosyaya kaydet
terraform plan -out=tfplan

# 4. Apply'dan önce peer review (opsiyonel)
git diff

# 5. Apply uygula
terraform apply tfplan

# 6. State'i kontrol et
terraform show

# 7. Belirli bir kaynağı görmek
terraform state show aws_dynamodb_table.picus
```

#### Terraform Modül Yapısı

```
infra/terraform/
├── main.tf              # Provider, backend, genel ayarlar
├── variables.tf         # Input değişkenler
├── outputs.tf           # Output değerler
├── terraform.tfvars     # Değişken değerleri
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

**Her dosya tek bir mantıksal bileşeni yönetir.**

#### Örnek: DynamoDB Terraform Kodu

```hcl
# infra/terraform/dynamodb.tf
resource "aws_dynamodb_table" "picus" {
  name         = var.dynamodb_table_name  # "picus"
  billing_mode = "PAY_PER_REQUEST"        # On-demand, otomatik scale

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

# Output: DynamoDB table'ın ARN'ını ver
output "dynamodb_table_arn" {
  value       = aws_dynamodb_table.picus.arn
  description = "ARN of the DynamoDB table"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.picus.name
  description = "Name of the DynamoDB table"
}
```

**Bu kod ne yapar?**
- `picus` adında bir DynamoDB tablosu oluşturur
- Partition key: `id` (String)
- Billing: On-demand (capacity yönetimine gerek yok)
- Backup aktif
- Encryption aktif
- Tags ile organizasyon

**IAM policy'lerde kullanım:**
```hcl
# Bu ARN'ı ECS task role'üne vereceğiz
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
Delete yetkisi verilmedi çünkü;
Bu mimaride DELETE /picus/{key} endpoint’i tamamen Lambda üzerinden çalışır.
ECS Fargate üzerindeki FastAPI uygulaması hiçbir şekilde silme işlemi yapmaz.

### 3️⃣ Uygulama Kurulumu (Lokal)

```bash
cd ../../app

# Virtual environment
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate

# Bağımlılıklar
pip install -r requirements.txt

# Ortam değişkenleri
cp .env.example .env
# .env dosyasını düzenle:
# AWS_REGION=eu-central-1
# DYNAMODB_TABLE_NAME=picus
```

### 4️⃣ Docker Image Oluşturma ve ECR'e Push

```bash
# AMD64 platform için build (Apple Silicon için gerekli)
docker buildx build --platform linux/amd64 -t picus-api:latest .

# ECR login
aws ecr get-login-password --region eu-central-1 \
  | docker login --username AWS --password-stdin \
    358712298152.dkr.ecr.eu-central-1.amazonaws.com

# Tag ve push
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

# Serverless Framework ile deploy
npx serverless deploy --stage dev --region eu-central-1

# Output'tan Lambda ARN'ı kaydet
```

### 6️⃣ DNS Yapılandırması

#### Cloudflare'de (muratkorkmaz.dev)

```bash
# DNS → picus.muratkorkmaz.dev için NS kayıtları ekle:
ns-1287.awsdns-32.org
ns-1786.awsdns-31.co.uk
ns-488.awsdns-61.com
ns-566.awsdns-06.net
```

#### Doğrulama

```bash
# NS kayıtlarını kontrol et
dig NS picus.muratkorkmaz.dev

# A kaydını kontrol et
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
SERVERLESS_ACCESS_KEY=... (Serverless Dashboard'dan)
```

## 💻 Kullanım

### API Endpoint'leri

#### Health Check

```bash
curl https://api.picus.muratkorkmaz.dev/picus/health

# Response
{
  "status": "ok",
  "message": "Picus-API alive"
}
```

#### Yeni Kayıt Oluşturma (POST)

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

**DynamoDB'de saklanan veri:**
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

#### Tek Kayıt Getirme (GET)

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

#### Tüm Kayıtları Listeleme (GET)

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

#### Kayıt Silme (DELETE) - Lambda

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

Interaktif API dokümantasyonu ve test arayüzü.

## 🏗 Altyapı

### Dizin Yapısı

```
picus-case/
├── app/                          # FastAPI uygulaması
│   ├── src/
│   │   ├── main.py              # FastAPI entry point
│   │   ├── config.py            # Ortam değişkenleri
│   │   ├── db.py                # DynamoDB client
│   │   ├── models.py            # Pydantic modeller
│   │   └── routes/
│   │       └── picus.py         # API endpoint'leri
│   ├── requirements.txt
│   ├── Dockerfile
│   └── .env.example
│
├── serverless-delete/            # Lambda fonksiyonu
│   ├── handler.py               # DELETE logic
│   ├── serverless.yml           # Serverless config
│   └── package.json
│
├── infra/
│   └── terraform/               # IaC tanımları
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

### Terraform Modülleri

#### VPC ve Networking

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
  billing_mode = "PAY_PER_REQUEST"  # On-demand (otomatik scaling)
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

### Networking Detayları

#### VPC Tasarımı ve Gerekçeleri

**Virtual Private Cloud (VPC)**, AWS'deki tüm kaynakların içinde çalıştığı **izole sanal ağdır**. İnternet gibi, ama sadece sizin kontrolünüzde.

##### 🎯 Tasarım Kararları

**1. CIDR Bloğu Seçimi**

```
VPC CIDR: 10.0.0.0/16
```

**Neden bu blok?**
- RFC 1918 private IP aralığı (10.0.0.0/8)
- `/16` netmask = **65,536 IP adresi** (10.0.0.1 - 10.0.255.254)
- Yeterince büyük (gelecekte subnet eklenebilir)
- Yeterince küçük (gereksiz yere alan tüketmez)
- Diğer VPC'lerle peering yapılacaksa çakışma riski düşük

**Alternatifler ve neden seçilmedi:**
- `192.168.0.0/16` → Ev/ofis ağlarıyla çakışma riski yüksek
- `172.16.0.0/12` → Genellikle corporate ağlarda kullanılır
- `10.0.0.0/24` → Çok küçük (256 IP), genişlemeye yer yok

**2. Subnet Stratejisi: Public vs Private**

```
Public Subnets:
  - 10.0.1.0/24  (AZ: eu-central-1a) - 256 IP
  - 10.0.2.0/24  (AZ: eu-central-1b) - 256 IP

Private Subnets:
  - 10.0.3.0/24 (AZ: eu-central-1a) - 256 IP
  - 10.0.4.0/24 (AZ: eu-central-1b) - 256 IP
```

**Public Subnet Özellikleri:**
- Internet Gateway (IGW) ile doğrudan internet erişimi var
- Public IP adresleri alabilir
- İnternetten gelen trafiği kabul edebilir
- **Burada çalışanlar:**
  - Application Load Balancer (ALB)
  - NAT Gateway
  - Bastion host'lar (opsiyonel)

**Private Subnet Özellikleri:**
- İnternete doğrudan erişim **yok**
- NAT Gateway üzerinden tek yönlü internet erişimi var
- İnternetten gelen trafik **direkt erişemez**
- **Burada çalışanlar:**
  - ECS Fargate task'ları (container'lar)
  - RDS database'ler (kullanılsaydı)
  - Lambda fonksiyonları (VPC içindeyse)
  - ElastiCache, RedShift vb.

**Neden 2 subnet (Multi-AZ)?**
- **High Availability (HA)**: Bir AZ çökse, diğer AZ'den servis devam eder
- **ALB requirement**: ALB en az 2 AZ'de subnet ister
- **ECS service**: Task'lar farklı AZ'lere dağıtılabilir
- **Disaster recovery**: Tek AZ'ye bağımlılık yok

**3. Neden /24 Netmask?**

```
/24 = 256 IP adresi (251 kullanılabilir, 5 AWS reserve)
```

**AWS'nin reserved IP'leri:**
- `10.0.1.0` → Network address
- `10.0.1.1` → VPC router
- `10.0.1.2` → DNS server
- `10.0.1.3` → Future use
- `10.0.1.255` → Broadcast (AWS kullanmaz ama reserve eder)

#### NAT Gateway: Neden Gerekli ve Nasıl Çalışıyor?

##### ❓ Problem: Private Subnet'teki Container'lar İnternete Nasıl Erişecek?

**Senaryo:**
1. ECS Fargate task'ı private subnet'te başlıyor
2. Container başlamak için **ECR'den Docker image çekmesi gerekiyor**
3. ECR internette → Container internete erişemiyorsa image çekemez
4. Container başlamaz ❌

**Ayrıca:**
- DynamoDB endpoint'i internette (veya VPC endpoint kullanılmadıysa)
- `pip install` / `apt-get update` internete erişim gerektirir
- AWS API çağrıları (CloudWatch logs vb.) internete gider

##### ✅ Çözüm: NAT Gateway

**NAT Gateway ne yapar?**
- Private subnet'teki kaynakların **tek yönlü olarak** internete çıkmasını sağlar
- İnternetten gelen trafiği **engelleyerek** güvenliği sağlar

**Akış:**

```
ECS Task (private subnet, 10.0.11.5)
    ↓
    ├─ "ECR'den image çek" isteği
    ↓
NAT Gateway (public subnet)
    ↓
    ├─ NAT: Source IP 10.0.11.5 → NAT’ın public IP’sine çevrilir
    ↓
Internet Gateway
    ↓
Amazon ECR (Container Registry endpoint)
    ↓
    ├─ Docker image layer'larını geri gönderir
    ↓
NAT Gateway (response'u tekrar 10.0.11.5’e yönlendirir)
    ↓
ECS Task (image başarıyla çekildi ✅)

```

**Önemli Noktalar:**

1. **Tek yönlü:**
   - Private → Internet ✅
   - Internet → Private ❌

2. **NAT Gateway public subnet'te olmalı:**
   - Çünkü kendisinin de internete erişmesi gerekiyor

3. **Elastic IP gerekli:**
   - NAT Gateway'in sabit bir public IP'si olmalı

##### 🔧 Terraform ile NAT Gateway Kurulumu

```hcl
# 1. Elastic IP oluştur
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# 2. NAT Gateway oluştur (public subnet'te)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id  # Public subnet

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.main]
}

# 3. Private subnet route table'ına ekle
resource "aws_route" "private_nat_gateway" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main.id
}
```

**Route table mantığı:**

```
Public Route Table:
  - 10.0.0.0/16 → local (VPC içi)
  - 0.0.0.0/0   → Internet Gateway (tüm internet trafiği)

Private Route Table:
  - 10.0.0.0/16 → local (VPC içi)
  - 0.0.0.0/0   → NAT Gateway (internet trafiği NAT'tan çıkar)
```

##### 🐛 Yaşanan Sorun: NAT Gateway Eksikliği

**İlk denemede NAT Gateway yoktu:**

```bash
# ECS task başlarken hata:
CannotPullContainerError: 
  Error response from daemon: 
  Get https://358712298152.dkr.ecr.eu-central-1.amazonaws.com/v2/: 
  dial tcp: lookup 358712298152.dkr.ecr.eu-central-1.amazonaws.com: 
  i/o timeout
```

**Sebep:**
- ECS task private subnet'te
- ECR'ye erişmek için internet gerekli
- NAT Gateway yok → internet erişimi yok

**Çözüm:**
1. Terraform'a NAT Gateway eklendi
2. Private route table 0.0.0.0/0 → NAT Gateway yönlendirildi
3. `terraform apply` çalıştırıldı
4. ECS service yeniden deploy edildi
5. Container başarıyla başladı ✅

#### Internet Gateway vs NAT Gateway

| Özellik | Internet Gateway | NAT Gateway |
|---------|------------------|-------------|
| **Yön** | İki yönlü (inbound+outbound) | Tek yönlü (sadece outbound) |
| **Kullanım** | Public subnet'ler için | Private subnet'ler için |
| **Public IP** | Kaynakların kendisinde | NAT Gateway'de (Elastic IP) |
| **Güvenlik** | Security group ile kontrol | İnternetten erişim yok |
| **Maliyet** | Ücretsiz | ~$32/ay + data transfer |
| **HA** | AWS tarafından yönetilir | Tek AZ (Multi-AZ için birden fazla gerekli) |



### 🔐 Security Groups

Bu mimaride iki ana security group kullanılıyor:

- **ALB Security Group** → İnternete açık tek entry point  
- **ECS Security Group** → Sadece ALB’den gelen trafiği kabul eden backend


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

### Pipeline Yapısı

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

**Kritik Adımlar:**

```yaml
# 1. Python test
- name: Run tests
  run: |
    cd app
    pip install -r requirements.txt
    pytest tests/ || python -m compileall src

# 2. Docker build (platform önemli!)
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

⚠️ **Önemli:** `terraform apply` CI'da çalışmıyor. Altyapı değişiklikleri manuel approve gerektirir.

### Zero-Downtime Deployment Stratejisi

```hcl
# ecs-service.tf
deployment_minimum_healthy_percent = 100
deployment_maximum_percent         = 200
```

**Deployment Flow:**

```
1. Mevcut: 2 task running (100%)
2. Yeni task başlat: 4 task running (200%)
3. Health check: Yeni task'lar healthy mi?
4. Evet → Eski task'ları durdur
5. Sonuç: 2 yeni task running (100%)

Downtime: 0 saniye ✅
```

## 📚 API Dokümantasyonu

### Endpoint Özeti

| Method | Path | Handler | Açıklama |
|--------|------|---------|----------|
| GET | `/picus/health` | FastAPI | Sağlık kontrolü |
| POST | `/picus/put` | FastAPI | Yeni kayıt oluştur |
| GET | `/picus/get/{id}` | FastAPI | Tek kayıt getir |
| GET | `/picus/list` | FastAPI | Tüm kayıtları listele |
| DELETE | `/picus/{id}` | Lambda | Kayıt sil |

### Request/Response Modelleri

#### POST /picus/put

**Request:**
```json
{
  "name": "string",       // Zorunlu
  "role": "string",       // Zorunlu
  "team": "string",       // Opsiyonel
  "email": "string",      // Opsiyonel
  // ... herhangi bir JSON payload
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
  "payload": { /* orijinal veri */ },
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
# FastAPI otomatik validation
422 Unprocessable Entity - JSON schema hatası

# Custom exceptions
404 Not Found - Kayıt bulunamadı
500 Internal Server Error - DynamoDB hatası
```

## 🛠 Geliştirme

### Lokal Development

```bash
# 1. Repo'yu klonla
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

# 5. Uvicorn ile çalıştır
uvicorn src.main:app --reload --host 0.0.0.0 --port 8000
```

**Swagger UI:**
```
http://localhost:8000/docs
```

### Docker ile Lokal Test

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

# AWS CLI ile görüntüleme
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

### Log Query Örnekleri

```bash
# 5xx hatalarını bul
fields @timestamp, @message
| filter @message like /5[0-9]{2}/
| sort @timestamp desc

# Yavaş istekler (>1s)
fields @timestamp, @message
| filter @message like /response_time/
| filter response_time > 1000
| sort response_time desc
```




