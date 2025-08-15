output "firehose_arn" {
  value = aws_kinesis_firehose_delivery_stream.nr_stream.arn
}
