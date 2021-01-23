# awsdevbot-root-baseline
awsdevbot-root-baseline

# terraform-aws-ec2
Custom terraform aws ec2 module


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

## Env vars example
```hcl-terraform
public_subdomain=YOUR_SUB_DOMAIN.com	
bucket_prefix=YOUR_BUCKET_PREFIX	
ses_bucket=EMAIL_BUCKET	
dmarc_rua_email=SOME_OTHER_EMAIL@gmail.com
```

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| public\_subdomain | n/a | `any` | n/a | yes |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
