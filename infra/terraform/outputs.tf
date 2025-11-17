output "dynamodb_table_name" {
  description = "Name of the DynamoDB table used by the picus application"
  value       = aws_dynamodb_table.picus.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table used by the picus application"
  value       = aws_dynamodb_table.picus.arn
}

output "ecr_repository_name" {
  description = "Name of the ECR repository for the picus API"
  value       = aws_ecr_repository.picus_api.name
}

output "ecr_repository_url" {
  description = "URL of the ECR repository for the picus API"
  value       = aws_ecr_repository.picus_api.repository_url
}

output "ecs_task_execution_role_arn" {
  description = "IAM Role ARN used by ECS tasks for execution (pull image, write logs)"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

output "ecs_task_role_arn" {
  description = "IAM Role ARN used by the application running inside ECS tasks"
  value       = aws_iam_role.ecs_task_role.arn
}

output "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  value       = aws_ecs_cluster.picus.name
}

output "ecs_task_definition_arn" {
  description = "ARN of the ECS task definition for the picus API"
  value       = aws_ecs_task_definition.picus_api.arn
}




# AÇIKLAMA:
# Bu dosya DynamoDB tablosuna ait önemli bilgileri terraform apply sonrası
# terminal çıktısı olarak gösterir. Bu çıktılar daha sonra Lambda IAM policy,
# Serverless Framework config, dokümantasyon veya başka Terraform modüllerinde
# referans olarak kullanılabilir. Özellikle tablo ARN'i Lambda için
# gerekli DeleteItem yetkisini verirken önemlidir.

/*
AÇIKLAMA:
Bu output'lar, oluşturulan ECR repository'sinin adını ve repository_url bilgisini Terraform apply
sonrasında terminalde göstermeye yarar.
- ecr_repository_name: Repository adını (picus-api) döner.
- ecr_repository_url: Docker image push ve ECS Task Definition'da kullanılacak tam ECR URL'sini döner.
  Örnek: <ACCOUNT_ID>.dkr.ecr.eu-central-1.amazonaws.com/picus-api
Bu değerler, CI/CD pipeline'ı (GitHub Actions) ve ECS Task Definition yazılırken doğrudan referans
olarak kullanılabilir.
*/

/*
AÇIKLAMA:
Bu output'lar, ECS Task Definition yazarken ihtiyaç duyulan rol ARN'lerini kolayca
görebilmek için eklenmiştir. Terraform apply sonrasında:
- ecs_task_execution_role_arn: executionRoleArn alanında kullanılacaktır.
- ecs_task_role_arn: taskRoleArn alanında kullanılacaktır.
*/

/*
AÇIKLAMA:
Bu output'lar, ECS tarafındaki önemli referansları (cluster name ve task definition ARN) hızlıca
görebilmek için eklenmiştir. Özellikle manuel debug veya AWS Console üzerinde kontrol yapılırken faydalıdır.
*/