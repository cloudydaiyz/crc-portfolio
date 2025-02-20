data "cloudflare_zone" "portfolio" {
  name = "cloudydaiyz.com"
}

# Add a record to the domain
resource "cloudflare_record" "gateway_cert_record" {
  zone_id = data.cloudflare_zone.portfolio.id
  name    = tolist(aws_acm_certificate.gateway_cert.domain_validation_options)[0].resource_record_name
  type    = tolist(aws_acm_certificate.gateway_cert.domain_validation_options)[0].resource_record_type
  content = tolist(aws_acm_certificate.gateway_cert.domain_validation_options)[0].resource_record_value
  ttl     = 1
}

# Add a record to the domain
resource "cloudflare_record" "crc_record" {
  zone_id = data.cloudflare_zone.portfolio.id
  name    = "api.crc"
  content = aws_api_gateway_domain_name.domain.cloudfront_domain_name
  type    = "CNAME"
  ttl     = 1
}