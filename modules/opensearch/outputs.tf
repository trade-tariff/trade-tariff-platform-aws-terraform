output "domain_arn" {
  description = "ARN of the OpenSearch domain."
  value       = aws_opensearch_domain.opensearch.arn
}
