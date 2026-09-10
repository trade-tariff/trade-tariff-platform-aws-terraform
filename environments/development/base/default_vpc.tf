data "aws_availability_zones" "available" {
  state = "available"
}

# Adopts the account's default subnets (unrelated to module.vpc above) so we can
# disable public IP auto-assignment and close Security Hub finding EC2.15.
resource "aws_default_subnet" "default" {
  for_each = toset(data.aws_availability_zones.available.names)

  availability_zone       = each.value
  map_public_ip_on_launch = false
}
