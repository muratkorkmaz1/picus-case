terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

# AÇIKLAMA:
# Bu dosya Terraform yapılandırmasının ana provider tanımını içerir.
# required_providers bölümü AWS provider'ın hangi sürümle kullanılacağını belirler.
# provider "aws" bloğu ise tüm Terraform kaynaklarının hangi AWS bölgesinde (region)
# oluşturulacağını tanımlar. Bu projede bütün bileşenler Frankfurt (eu-central-1)
# üzerinde oluşturulacaktır. Terraform CLI, ~/.aws/credentials içerisindeki
# kimlik bilgilerini otomatik kullanır.
