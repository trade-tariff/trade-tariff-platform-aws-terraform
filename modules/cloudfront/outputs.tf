output "aws_cloudfront_distribution_id" {
  value = aws_cloudfront_distribution.this[0].id
}

output "aws_cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.this[0].arn
}

output "aws_cloudfront_distribution_domain_name" {
  value = aws_cloudfront_distribution.this[0].domain_name
}

output "aws_cloudfront_distribution_hosted_zone_id" {
  value = aws_cloudfront_distribution.this[0].hosted_zone_id
}
