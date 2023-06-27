locals {
  redis_major_version = tonumber(split(".", var.redis_version)[0])
  redis_minor_version = tonumber(split(".", var.redis_version)[1])
}
