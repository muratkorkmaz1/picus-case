resource "aws_dynamodb_table" "picus" {
  name         = "picus"
  billing_mode = "PAY_PER_REQUEST"

  hash_key = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = "dev"
    Project     = "picus-case"
    Component   = "dynamodb"
  }
}

# AÇIKLAMA:
# Bu dosya DynamoDB üzerinde "picus" isimli bir tablo oluşturur.
# billing_mode = PAY_PER_REQUEST, tabloyu On-Demand kapasite modunda çalıştırır.
# hash_key = "id", tablonun primary key alanının 'id' olduğunu ifade eder.
# attribute bloğu, sadece index edilen alanların tipini belirtmek için gereklidir.
# DynamoDB şemasız çalıştığından payload veya created_at gibi alanları
# burada tanımlamaya gerek yoktur; item eklenirken dinamik olarak gönderilir.
# tags bölümü AWS kaynak yönetimi, maliyet takibi ve sınıflandırma için kullanılır.
