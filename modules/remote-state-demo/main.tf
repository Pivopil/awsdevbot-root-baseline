data "terraform_remote_state" "baseline" {
  backend = "remote"
  config = {
    hostname = "app.terraform.io"
    organization = "awsdevbot"
    workspaces = {
      name = "awsdevbot-root-baseline"
    }
  }
}

output "acm_arn" {
  value = data.terraform_remote_state.baseline.outputs.acm_arn
}



