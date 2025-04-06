az extension add -n application-insights

PROJECT_NAME="$(basename "$PWD")"
RESOURCE_SUFFIX="$(openssl rand -base64 20 | tr -dc 'a-z0-9' | head -c 6)"
LOCATION="westus"
SUBSCRIPTION_ID="$(az account show --query "id" --output "tsv")"
DOCKER_IMAGE_TAG="v$(date +%Y%m%d%H%M%S)"

az group create --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --location "${LOCATION}"

az monitor log-analytics workspace create --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --location "${LOCATION}" --sku "PerGB2018" --workspace-name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-workspace" --output "none"

az monitor app-insights component create --app "${PROJECT_NAME}-${RESOURCE_SUFFIX}-app" --location "${LOCATION}" --ingestion-access "Enabled" --application-type "web" --kind "web" --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --workspace "/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg/providers/microsoft.operationalinsights/workspaces/${PROJECT_NAME}-${RESOURCE_SUFFIX}-workspace" --output "none"

APPLICATION_INSIGHTS_CONNECTION_STRING=$(az monitor app-insights component show --app "${PROJECT_NAME}-${RESOURCE_SUFFIX}-app" --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --query "connectionString" --output "tsv")

az acr create --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --name "${PROJECT_NAME}${RESOURCE_SUFFIX}acr" --sku Basic --location "${LOCATION}" --output "none"

az acr login --name "${PROJECT_NAME}${RESOURCE_SUFFIX}acr" --output "none"

az appservice plan create --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-plan" --location "${LOCATION}" --sku B3 --is-linux --output "none"

pushd src/api

az acr build --registry "${PROJECT_NAME}${RESOURCE_SUFFIX}acr" --image "${PROJECT_NAME}-api:${DOCKER_IMAGE_TAG}" --file Dockerfile . --output "none"

az webapp create --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --plan "${PROJECT_NAME}-${RESOURCE_SUFFIX}-plan" --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-api" --deployment-container-image-name "ghcr.io/${GITHUB_USER}/${PROJECT_NAME}-api:${RESOURCE_SUFFIX}" --docker-registry-server-user "${GITHUB_USER}" --docker-registry-server-password "${ARKANSAS_GITHUB_TOKEN}" --output "none"

az webapp config appsettings set --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-api" --settings APPLICATION_INSIGHTS_CONNECTION_STRING=${APPLICATION_INSIGHTS_CONNECTION_STRING}

popd

pushd src/web

cp package.json package.json.bak

jq '.config.applicationInsights_connectionString = "'$APPLICATION_INSIGHTS_CONNECTION_STRING'"' package.json > tmp.json && mv tmp.json package.json

az acr build --registry "${PROJECT_NAME}${RESOURCE_SUFFIX}acr" --image "${PROJECT_NAME}-web:${DOCKER_IMAGE_TAG}" --file Dockerfile . --output "none"

mv package.json.bak package.json
rm -rf package.json.bak

az webapp create --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --plan "${PROJECT_NAME}-${RESOURCE_SUFFIX}-plan" --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-web" --deployment-container-image-name "ghcr.io/${GITHUB_USER}/${PROJECT_NAME}-web:${RESOURCE_SUFFIX}" --docker-registry-server-user "${GITHUB_USER}" --docker-registry-server-password "${ARKANSAS_GITHUB_TOKEN}" --output "none"

az webapp config appsettings set --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-web" --settings APPLICATION_INSIGHTS_CONNECTION_STRING=${APPLICATION_INSIGHTS_CONNECTION_STRING}

popd
