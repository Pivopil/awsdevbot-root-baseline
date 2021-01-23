# Create .terraformrc somewhere
credentials "app.terraform.io" {
  token = "YOU_TOKEN"
}

export TF_PLUGIN_CACHE_DIR="$HOME/.terraform.d/plugin-cache"

export TF_CLI_CONFIG_FILE="$HOME/apps/pivopil/awsdevbot-root-baseline/.idea/tmp/.terraformrc"
