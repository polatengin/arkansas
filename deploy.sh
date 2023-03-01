az extension add -n application-insights

RESOURCE_SUFFIX=$(openssl rand -base64 20 | tr -dc 'a-z0-9' | head -c 6)
LOCATION="westus"
SUBSCRIPTION_ID=$(az account show --query "id" --output "tsv")

az group create --name "arkansas-${RESOURCE_SUFFIX}-rg" --location "${LOCATION}"

az appservice plan create --resource-group "arkansas-${RESOURCE_SUFFIX}-rg" --name "arkansas-${RESOURCE_SUFFIX}-plan" --location "${LOCATION}" --sku B1 --is-linux --output "none"

az webapp create --resource-group "arkansas-${RESOURCE_SUFFIX}-rg" --plan "arkansas-${RESOURCE_SUFFIX}-plan" --name "arkansas-${RESOURCE_SUFFIX}-app" --runtime "DOTNETCORE:7.0" --output "none"

az monitor log-analytics workspace create --resource-group "arkansas-${RESOURCE_SUFFIX}-rg" --location "${LOCATION}" --sku "PerGB2018" --workspace-name "arkansas-${RESOURCE_SUFFIX}-workspace" --output "none"

az monitor app-insights component create --app "arkansas-${RESOURCE_SUFFIX}-app" --location "${LOCATION}" --kind "web" --resource-group "arkansas-${RESOURCE_SUFFIX}-rg" --workspace "/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/arkansas-${RESOURCE_SUFFIX}-rg/providers/microsoft.operationalinsights/workspaces/arkansas-${RESOURCE_SUFFIX}-workspace" --output "none"

APPLICATION_INSIGHTS_CONNECTION_STRING=$(az monitor app-insights component show --app "arkansas-${RESOURCE_SUFFIX}-app" --resource-group "arkansas-${RESOURCE_SUFFIX}-rg" --query "connectionString" --output "tsv")
