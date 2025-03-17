output "user_pool_arn" {
  value = aws_cognito_user_pool.this.arn
}

output "user_pool_id" {
  value = aws_cognito_user_pool.this.id
}

output "client_id" {
  value = aws_cognito_user_pool_client.this[0].id
}

output "client_secret" {
  value     = aws_cognito_user_pool_client.this[0].client_secret
  sensitive = true
}

output "domain" {
  value = var.domain_certificate_arn != null ? var.domain : "${aws_cognito_user_pool.this.domain}.auth.${data.aws_region.current.name}.amazoncognito.com"
}

output "user_pool_public_keys_url" {
  value = "https://cognito-idp.${data.aws_region.current.name}.amazonaws.com/${aws_cognito_user_pool.this.id}/.well-known/jwks.json"
}

output "cloudfront_distribution_arn" {
  value = aws_cognito_user_pool_domain.this[0].cloudfront_distribution_arn
}

output "cloudfront_distribution_zone_id" {
  value = aws_cognito_user_pool_domain.this[0].cloudfront_distribution_zone_id
}
