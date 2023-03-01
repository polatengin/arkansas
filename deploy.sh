RESOURCE_SUFFIX=$(openssl rand -base64 20 | tr -dc 'a-z0-9' | head -c 6)
LOCATION="westus"
SUBSCRIPTION_ID=$(az account show --query "id" --output "tsv")

az group create --name "arkansas-${RESOURCE_SUFFIX}-rg" --location "${LOCATION}"

az appservice plan create --resource-group "arkansas-${RESOURCE_SUFFIX}-rg" --name "arkansas-${RESOURCE_SUFFIX}-plan" --location "${LOCATION}" --sku B1 --is-linux

az webapp create --resource-group "arkansas-${RESOURCE_SUFFIX}-rg" --plan "arkansas-${RESOURCE_SUFFIX}-plan" --name "arkansas-${RESOURCE_SUFFIX}-app" --runtime "DOTNETCORE:7.0"
