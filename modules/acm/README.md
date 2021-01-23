# awsdevbot-root-baseline
ACM module from https://registry.terraform.io/modules/terraform-aws-modules/acm/aws/latest

## Configure Terraform Provider
```shell script
export AWS_PROFILE="[YOU_SSO_ACCOUNT_ID]_AdministratorAccess"
export AWS_DEFAULT_REGION="us-east-1"
export TF_LOG=INFO
```

## Init
```shell script
terraform init
```

## Plan
```shell script
terraform plan
```

## Apply
```shell script
terraform apply -auto-approve
```

## Destroy
```shell script
terraform destroy -auto-approve

```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| certificate\_transparency\_logging\_preference | Specifies whether certificate details should be added to a certificate transparency log | `bool` | `true` | no |
| create\_certificate | Whether to create ACM certificate | `bool` | `true` | no |
| dns\_ttl | The TTL of DNS recursive resolvers to cache information about this record. | `number` | `60` | no |
| domain\_name | A domain name for which the certificate should be issued | `string` | `""` | no |
| subject\_alternative\_names | A list of domains that should be SANs in the issued certificate | `list(string)` | `[]` | no |
| tags | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |
| validate\_certificate | Whether to validate certificate by creating Route53 record | `bool` | `true` | no |
| validation\_allow\_overwrite\_records | Whether to allow overwrite of Route53 records | `bool` | `true` | no |
| validation\_method | Which method to use for validation. DNS or EMAIL are valid, NONE can be used for certificates that were imported into ACM and then into Terraform. | `string` | `"DNS"` | no |
| wait\_for\_validation | Whether to wait for the validation to complete | `bool` | `true` | no |
| zone\_id | The ID of the hosted zone to contain this record. | `string` | `""` | no |

## Outputs

| Name | Description |
|------|-------------|
| distinct\_domain\_names | List of distinct domains names used for the validation. |
| this\_acm\_certificate\_arn | The ARN of the certificate |
| this\_acm\_certificate\_domain\_validation\_options | A list of attributes to feed into other resources to complete certificate validation. Can have more than one element, e.g. if SANs are defined. Only set if DNS-validation was used. |
| this\_acm\_certificate\_validation\_emails | A list of addresses that received a validation E-Mail. Only set if EMAIL-validation was used. |
| validation\_domains | List of distinct domain validation options. This is useful if subject alternative names contain wildcards. |
| validation\_route53\_record\_fqdns | List of FQDNs built using the zone domain and name. |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
