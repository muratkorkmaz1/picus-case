############################################
# ECS Cluster
############################################
resource "aws_ecs_cluster" "picus" {
  name = "picus-cluster"

  # İstersen istersen container insights'i açabiliriz, şimdilik kapalı
  setting {
    name  = "containerInsights"
    value = "disabled"
  }

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

############################################
# CloudWatch Logs - picus API
############################################
resource "aws_cloudwatch_log_group" "picus_api" {
  name              = "/ecs/picus-api"
  retention_in_days = 7

  tags = {
    Project     = var.project
    Environment = var.environment
    Component   = "ecs"
  }
}

############################################
# ECS Task Definition (Fargate)
############################################
resource "aws_ecs_task_definition" "picus_api" {
  family                   = "picus-api-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_task_cpu    # örn: 256
  memory                   = var.ecs_task_memory # örn: 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "picus-api"
      image     = "${aws_ecr_repository.picus_api.repository_url}:latest"
      essential = true

      portMappings = [
        {
          containerPort = var.container_port # 8000
          protocol      = "tcp"
        }
      ]

      environment = [
        {
          name  = "AWS_REGION"
          value = var.aws_region
        },
        {
          name  = "DYNAMODB_TABLE"
          value = aws_dynamodb_table.picus.name
        }
      ]

      # >>> Burada awslogs aktif
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.picus_api.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "picus-api"
        }
      }
    }
  ])

  tags = {
    Project     = var.project
    Environment = var.environment
    Component   = "ecs"
  }

  depends_on = [
    aws_cloudwatch_log_group.picus_api
  ]
}

/*
AÇIKLAMA:

Bu dosya, Picus case için ECS tarafındaki temel iki kaynağı tanımlar:
1) ECS Cluster
2) API'nin çalışacağı Task Definition

--------------------------------------------------
1) aws_ecs_cluster.picus
--------------------------------------------------
- name = "picus-cluster":
  ECS tarafındaki tüm servislerin çalışacağı cluster adıdır. ECS Console’da
  cluster listesinde bu isimle görünecek.

- capacity_providers = ["FARGATE"]:
  Bu cluster üzerinde Fargate launch type kullanılacağını belirtir. Yani
  EC2 instance yönetmek yerine tamamen serverless container (Fargate) kullanıyoruz.

- tags:
  Environment/Project/Component tag’leri; maliyet takibi, filtreleme ve
  kaynak yönetimi için önemlidir.

--------------------------------------------------
2) aws_ecs_task_definition.picus_api
--------------------------------------------------
Bu blok, FastAPI tabanlı "picus-api" container'ının nasıl koşulacağını tarif eder.

- family = "picus-api-task":
  Task definition ailesi. AWS tarafında task definition versiyonları
  picus-api-task:1, picus-api-task:2 şeklinde tutulur.

- requires_compatibilities = ["FARGATE"]:
  Bu task sadece Fargate üzerinde çalışabilir demektir.

- network_mode = "awsvpc":
  Fargate için zorunlu network modu. Her task’e kendi ENI (network interface)
  atanır, bu sayede security group ve subnet seviyesinde izole edilebilir.

- cpu = "256", memory = "512":
  Fargate’in desteklediği CPU/RAM kombinasyonlarından biri:
  0.25 vCPU ve 512MB RAM. Demo/case için yeterli bir değer.

- execution_role_arn:
  Daha önce iam.tf içinde tanımladığımız
  aws_iam_role.ecs_task_execution_role rolü burada kullanılıyor.
  Bu rol:
    * ECR'den container image çekmek
    * CloudWatch Logs'a log yazmak
  gibi ECS altyapı operasyonları için kullanılır.
  Uygulama kodunun AWS kaynaklarına erişimi bu rol üzerinden DEĞİL, task_role_arn üzerinden yapılır.

- task_role_arn:
  Yine iam.tf içinde tanımlanan aws_iam_role.ecs_task_role.
  Bu role sadece DynamoDB 'picus' tablosuna GetItem/PutItem/Scan yetkisi veren
  özel bir policy bağladık (least privilege prensibi).
  Container içinde çalışan FastAPI uygulaması boto3 ile DynamoDB’ye eriştiğinde,
  bu rol üzerinden yetkilendirilmiş olur.

--------------------------------------------------
container_definitions
--------------------------------------------------
Burada ECS’e “container’ı nasıl çalıştıracağını” JSON formatında anlatıyoruz.
jsonencode([...]) ile HCL → JSON dönüşümü yapılıyor.

Tek bir container tanımlı: "picus-api"

- name = "picus-api":
  Task içindeki container adı.

- image:
  aws_ecr_repository.picus_api.repository_url değeri kullanılıyor ve sonuna :latest tag’i ekleniyor.
  Örnek:
    358712298152.dkr.ecr.eu-central-1.amazonaws.com/picus-api:latest

- portMappings:
  containerPort = 8000 → Uygulama container içinde 8000 portunda dinliyor.
  İlerleyen adımda ECS Service ve ALB Target Group bu porta göre yapılandırılacak.

- essential = true:
  Eğer bu container çökerse, task "failed" kabul edilir.
  Tek container’lı API’de mantıklı bir seçim.

- environment:
  Uygulamaya geçilen environment değişkenleri:
    * AWS_REGION:
      var.aws_region üzerinden geliyor (muhtemelen "eu-central-1").
      FastAPI/boto3 tarafında AWS region’ını belirtmek için kullanılıyor.
    * DYNAMODB_TABLE:
      aws_dynamodb_table.picus.name → "picus"
      Uygulamanın hangi DynamoDB tablosuyla konuşacağını belirtiyor.

Bu environment değişkenleri Python tarafında config.py içinde okunuyor:
  AWS_REGION → boto3 resource region_name
  DYNAMODB_TABLE → DynamoDB tablo adı

--------------------------------------------------
Genel Bakış
--------------------------------------------------
Bu ecs.tf ile:
- picus-cluster adında bir ECS Fargate cluster’ı oluşturduk.
- picus-api-task adında bir task definition tanımladık:
  - ECR’den picus-api:latest image’ini kullanıyor,
  - 8000 portunu expose ediyor,
  - IAM roller üzerinden DynamoDB'ye erişebiliyor,
  - Fargate üzerinde awsvpc network moduyla koşturulacak şekilde ayarlandı.

Bir sonraki aşamada:
- Bu task definition’ı kullanan bir ECS Service tanımlanacak,
- Service, VPC içindeki uygun subnet/security group’larla bağlanacak,
- Üzerine bir Application Load Balancer (ALB) konup
  /picus/* endpoint’leri tek bir domain/IP üzerinden dış dünyaya açılacak.
*/
