mock_provider "aws" {}
mock_provider "null" {}

variables {
  pool_name = "test-pool"

  # outputs.tf reads aws_cognito_user_pool_client.this[0] with no guard, so
  # every run must create the client. See the report for this bug.
  client_name = "test-client"

  schemata = [
    {
      name      = "organisation"
      data_type = "String"
    },
    {
      name      = "age"
      data_type = "Number"
      min_value = 18
      max_value = 120
      mutable   = false
      required  = true
    },
  ]
}

run "adds_no_schema_attributes_by_default" {
  command = plan

  variables {
    schemata = null
  }

  assert {
    condition     = length(aws_cognito_user_pool.this.schema) == 0
    error_message = "No schema attributes must be set when schemata is null."
  }
}

run "string_attribute_gets_default_length_constraints" {
  command = plan

  assert {
    condition = one([
      for attribute in aws_cognito_user_pool.this.schema : attribute.string_attribute_constraints[0].max_length
      if attribute.name == "organisation"
    ]) == "2048"
    error_message = "A String attribute must default to a max_length of 2048."
  }

  assert {
    condition = one([
      for attribute in aws_cognito_user_pool.this.schema : length(attribute.number_attribute_constraints)
      if attribute.name == "organisation"
    ]) == 0
    error_message = "A String attribute must not have number constraints."
  }

  assert {
    condition = one([
      for attribute in aws_cognito_user_pool.this.schema : attribute.mutable && !attribute.required && !attribute.developer_only_attribute
      if attribute.name == "organisation"
    ])
    error_message = "A schema attribute must default to mutable, not required and not developer only."
  }
}

run "number_attribute_gets_given_value_constraints" {
  command = plan

  assert {
    condition = one([
      for attribute in aws_cognito_user_pool.this.schema : attribute.number_attribute_constraints[0].min_value
      if attribute.name == "age"
    ]) == "18"
    error_message = "A Number attribute must use the given min_value."
  }

  assert {
    condition = one([
      for attribute in aws_cognito_user_pool.this.schema : length(attribute.string_attribute_constraints)
      if attribute.name == "age"
    ]) == 0
    error_message = "A Number attribute must not have string constraints."
  }

  assert {
    condition = one([
      for attribute in aws_cognito_user_pool.this.schema : !attribute.mutable && attribute.required
      if attribute.name == "age"
    ])
    error_message = "A Number attribute must keep the given mutable and required values."
  }
}

run "schema_checksum_tracks_schemata" {
  command = plan

  # The user pool is replaced when this checksum changes, because AWS cannot
  # change schema attributes in place.
  assert {
    condition     = null_resource.schema_checksum.triggers.schema == md5(jsonencode(var.schemata))
    error_message = "The schema checksum trigger must be the md5 of the JSON encoded schemata."
  }
}
