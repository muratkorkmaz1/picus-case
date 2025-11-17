resource "aws_iam_role" "ecs_task_execution_role" {
  name = "picus-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "dev"
    Project     = "picus-case"
    Component   = "ecs"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  name = "picus-ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Environment = "dev"
    Project     = "picus-case"
    Component   = "ecs"
  }
}

resource "aws_iam_policy" "ecs_task_dynamodb_policy" {
  name        = "picus-ecs-task-dynamodb-policy"
  description = "Allow ECS tasks to access the picus DynamoDB table"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:Scan"
        ],
        Resource = aws_dynamodb_table.picus.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_dynamodb_attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_task_dynamodb_policy.arn
}


resource "aws_lambda_permission" "allow_alb_invoke_delete" {
  statement_id = "AllowExecutionFromALBDelete"
  action       = "lambda:InvokeFunction"

  # Serverless ile deploy ettiğin fonksiyonun ARN'i
  function_name = "arn:aws:lambda:eu-central-1:358712298152:function:picus-delete-dev-deletePicusItem"

  principal = "elasticloadbalancing.amazonaws.com"

  # Bu Lambda'ya ALB üzerinden erişim olsun
  source_arn = aws_lb_target_group.picus_delete_lambda.arn
}



/*
AÇIKLAMA:
Bu bloklar ECS Fargate task'lerinin ihtiyaç duyduğu IAM rollerini tanımlar.

- aws_iam_role.ecs_task_execution_role:
  ECS task execution role'dur. ECS ajanı bu rol ile:
  - ECR'den container image çekebilir,
  - CloudWatch Logs'a log yazabilir.
  Kendisine AWS'in yönetilen politikası olan AmazonECSTaskExecutionRolePolicy
  aws_iam_role_policy_attachment.ecs_task_execution_role_policy ile bağlanmıştır.

- aws_iam_role.ecs_task_role:
  Uygulama kodunun (FastAPI container) AWS servislerine erişirken kullandığı roldür.
  Bu role doğrudan hiçbir AWS managed policy bağlanmamıştır,
  bunun yerine sadece ihtiyaç duyduğu DynamoDB izinlerini içeren
  aws_iam_policy.ecs_task_dynamodb_policy ile yetki verilmiştir.

- aws_iam_policy.ecs_task_dynamodb_policy:
  FastAPI uygulamasının çalıştığı ECS task'lerinin sadece picus isimli DynamoDB tablosunda
  GetItem, PutItem ve Scan aksiyonlarını yapmasına izin verir.
  Böylece principle of least privilege (asgari yetki) prensibi uygulanmış olur.

Bu roller ilerleyen adımda ECS Task Definition üzerinde şu alanlarda kullanılacaktır:
- execution_role_arn: ecs_task_execution_role
- task_role_arn: ecs_task_role
*/
