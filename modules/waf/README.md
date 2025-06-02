# waf

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.11 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_wafv2_regex_pattern_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_regex_pattern_set) | resource |
| [aws_wafv2_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_association) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alb_arn"></a> [alb\_arn](#input\_alb\_arn) | ARN of the ALB to be associated with the WAFv2 ACL. | `string` | `""` | no |
| <a name="input_associate_alb"></a> [associate\_alb](#input\_associate\_alb) | Whether to associate an ALB with the WAFv2 ACL. | `bool` | `false` | no |
| <a name="input_default_action"></a> [default\_action](#input\_default\_action) | The action to perform if none of the rules contained in the WebACL match. | `string` | `"allow"` | no |
| <a name="input_filtered_header_rule"></a> [filtered\_header\_rule](#input\_filtered\_header\_rule) | HTTP header to filter . Currently supports a single header type and multiple header values. | <pre>object({<br/>    header_types = list(string)<br/>    priority     = number<br/>    header_value = string<br/>    action       = string<br/>  })</pre> | <pre>{<br/>  "action": "block",<br/>  "header_types": [],<br/>  "header_value": "",<br/>  "priority": 1<br/>}</pre> | no |
| <a name="input_group_rules"></a> [group\_rules](#input\_group\_rules) | List of WAFv2 Rule Groups. | <pre>list(object({<br/>    name            = string<br/>    arn             = string<br/>    priority        = number<br/>    override_action = string<br/>    excluded_rules  = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_ip_rate_based_rule"></a> [ip\_rate\_based\_rule](#input\_ip\_rate\_based\_rule) | A rate-based rule tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span | <pre>object({<br/>    name      = string<br/>    priority  = number<br/>    rpm_limit = number<br/>    action    = string<br/>    custom_response = object({<br/>      response_code = number<br/>      body_key      = string<br/>      response_header = object({<br/>        name  = string<br/>        value = string<br/>      })<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_ip_rate_url_based_rules"></a> [ip\_rate\_url\_based\_rules](#input\_ip\_rate\_url\_based\_rules) | A rate and url based rules tracks the rate of requests for each originating IP address, and triggers the rule action when the rate exceeds a limit that you specify on the number of requests in any 5-minute time span | <pre>list(object({<br/>    name                  = string<br/>    priority              = number<br/>    limit                 = number<br/>    action                = string<br/>    search_string         = string<br/>    positional_constraint = string<br/>  }))</pre> | `[]` | no |
| <a name="input_ip_sets_rule"></a> [ip\_sets\_rule](#input\_ip\_sets\_rule) | A rule to detect web requests coming from particular IP addresses or address ranges. | <pre>list(object({<br/>    name       = string<br/>    priority   = number<br/>    ip_set_arn = string<br/>    action     = string<br/>  }))</pre> | `[]` | no |
| <a name="input_managed_rules"></a> [managed\_rules](#input\_managed\_rules) | List of Managed WAF rules. | <pre>map(object({<br/>    priority        = number<br/>    override_action = string<br/>    excluded_rules  = list(string)<br/>  }))</pre> | <pre>{<br/>  "AWSManagedRulesAmazonIpReputationList": {<br/>    "excluded_rules": [],<br/>    "override_action": "none",<br/>    "priority": 20<br/>  },<br/>  "AWSManagedRulesCommonRuleSet": {<br/>    "excluded_rules": [<br/>      "NoUserAgent_HEADER",<br/>      "SizeRestrictions_BODY"<br/>    ],<br/>    "override_action": "none",<br/>    "priority": 10<br/>  },<br/>  "AWSManagedRulesKnownBadInputsRuleSet": {<br/>    "excluded_rules": [],<br/>    "override_action": "none",<br/>    "priority": 30<br/>  },<br/>  "AWSManagedRulesLinuxRuleSet": {<br/>    "excluded_rules": [],<br/>    "override_action": "none",<br/>    "priority": 50<br/>  },<br/>  "AWSManagedRulesSQLiRuleSet": {<br/>    "excluded_rules": [<br/>      "SQLi_QUERYARGUMENTS"<br/>    ],<br/>    "override_action": "none",<br/>    "priority": 40<br/>  },<br/>  "AWSManagedRulesUnixRuleSet": {<br/>    "excluded_rules": [],<br/>    "override_action": "none",<br/>    "priority": 60<br/>  }<br/>}</pre> | no |
| <a name="input_name"></a> [name](#input\_name) | A friendly name of the WebACL. | `string` | n/a | yes |
| <a name="input_scope"></a> [scope](#input\_scope) | The scope of this Web ACL. Valid options: CLOUDFRONT, REGIONAL. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A mapping of tags to assign to the WAFv2 ACL. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_web_acl_id"></a> [web\_acl\_id](#output\_web\_acl\_id) | The ARN of the WAF WebACL. |
<!-- END_TF_DOCS -->
