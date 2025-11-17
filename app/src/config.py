import os
from dotenv import load_dotenv

load_dotenv()

AWS_REGION = os.getenv("AWS_REGION", "eu-central-1")
DYNAMODB_TABLE = os.getenv("DYNAMODB_TABLE", "picus")

"""
AÇIKLAMA:
Bu dosya API'nin konfigürasyon ayarlarını yönetir.
- AWS_REGION: Uygulamanın hangi AWS bölgesiyle konuşacağını belirler.
  Varsayılan olarak eu-central-1 (Frankfurt) kullanılır.
- DYNAMODB_TABLE: Uygulamanın kullanacağı DynamoDB tablosunun adıdır.
  Varsayılan olarak 'picus' atanmıştır.
load_dotenv() çağrısı sayesinde lokal geliştirme sırasında .env dosyasındaki
değerler de okunabilir. ECS ortamında ise bu değerler container environment
variables üzerinden sağlanacaktır.
"""
