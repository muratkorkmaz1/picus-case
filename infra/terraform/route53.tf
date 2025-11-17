############################
# Route53 – Hosted Zone
############################

# KENDİ DOMAIN'İNİ BURAYA YAZ
variable "root_domain_name" {
  type        = string
  description = "Ana domain (örnek: example.com veya picus-case.dev)"
  default     = "muratkorkmaz.dev"
}

variable "picus_subdomain" {
  type        = string
  description = "Picus case için kullanılacak subdomain (ör: picus-case.example.com)"
  default     = "picus.muratkorkmaz.dev"
}

# Hosted Zone – picus-case.example.com
resource "aws_route53_zone" "picus" {
  name = var.picus_subdomain

  tags = {
    Project     = "picus-case"
    Environment = "dev"
    Component   = "route53"
  }
}

# Dokümantasyon için name server'ları output et
output "route53_picus_name_servers" {
  description = "Bu hosted zone için kullanılacak NS kayıtları (registrar tarafına gireceksin)."
  value       = aws_route53_zone.picus.name_servers
}

############################
# A Alias – api.picus-case.example.com → ALB
############################

resource "aws_route53_record" "api_alb" {
  zone_id = aws_route53_zone.picus.zone_id
  name    = "api.${aws_route53_zone.picus.name}" # api.picus-case.example.com
  type    = "A"

  alias {
    name                   = aws_lb.picus.dns_name
    zone_id                = aws_lb.picus.zone_id
    evaluate_target_health = true
  }
}
