resource "aws_ecr_repository" "picus_api" {
  name                 = "picus-api"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Environment = "dev"
    Project     = "picus-case"
    Component   = "ecr"
  }
}

resource "aws_ecr_lifecycle_policy" "picus_api" {
  repository = aws_ecr_repository.picus_api.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep only the last 10 images"
        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

/*
AÇIKLAMA:
Bu dosya, API container image'lerinin saklanacağı AWS ECR repository'sini tanımlar.
- aws_ecr_repository.picus_api:
  - name = "picus-api": Repository adı, Docker image'leri bu isimle taglenecek.
  - image_tag_mutability = "MUTABLE": Aynı tag'in üzerine yeni image push etmeye izin verir
    (CI/CD pipeline'larda convenience sağlar).
  - image_scanning_configuration.scan_on_push = true: Image push edildiğinde otomatik güvenlik taraması yapar.
  - encryption_configuration.encryption_type = "AES256": ECR içindeki image layer'ları AWS tarafından yönetilen
    anahtarlarla şifreler.
  - tags: Kaynağın ortam, proje ve komponent bilgilerini belirtir.

- aws_ecr_lifecycle_policy.picus_api:
  - repository: Policy'nin uygulanacağı ECR repository.
  - policy: jsonencode ile bir lifecycle policy oluşturur.
    "imageCountMoreThan" ve "countNumber = 10" sayesinde sadece son 10 image saklanır,
    daha eski tag'li image'ler otomatik olarak silinir.
    Bu, ECR maliyetini kontrol altında tutmak ve eski, kullanılmayan image'leri otomatik temizlemek için önemlidir.
*/
