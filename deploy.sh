RESOURCE_SUFFIX=$(openssl rand -base64 20 | tr -dc 'a-z0-9' | head -c 6)
LOCATION="westus"
SUBSCRIPTION_ID=$(az account show --query "id" --output "tsv")

az group create --name "arkansas-${RESOURCE_SUFFIX}-rg" --location "${LOCATION}"
