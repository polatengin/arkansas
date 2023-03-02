az extension add -n application-insights

PROJECT_NAME="${RepositoryName}"
RESOURCE_SUFFIX=$(openssl rand -base64 20 | tr -dc 'a-z0-9' | head -c 6)
LOCATION="westus"
SUBSCRIPTION_ID=$(az account show --query "id" --output "tsv")

az group create --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --location "${LOCATION}"

az monitor log-analytics workspace create --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --location "${LOCATION}" --sku "PerGB2018" --workspace-name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-workspace" --output "none"

az monitor app-insights component create --app "${PROJECT_NAME}-${RESOURCE_SUFFIX}-app" --location "${LOCATION}" --ingestion-access "Enabled" --application-type "web" --kind "web" --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --workspace "/subscriptions/${SUBSCRIPTION_ID}/resourcegroups/${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg/providers/microsoft.operationalinsights/workspaces/${PROJECT_NAME}-${RESOURCE_SUFFIX}-workspace" --output "none"

APPLICATION_INSIGHTS_CONNECTION_STRING=$(az monitor app-insights component show --app "${PROJECT_NAME}-${RESOURCE_SUFFIX}-app" --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --query "connectionString" --output "tsv")

echo "${ARKANSAS_GITHUB_TOKEN}" | docker login ghcr.io -u "${GITHUB_USER}" --password-stdin

az appservice plan create --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-plan" --location "${LOCATION}" --sku B1 --is-linux --output "none"

pushd src/api

docker build -t "ghcr.io/${GITHUB_USER}/${PROJECT_NAME}-api:${RESOURCE_SUFFIX}" .
docker push "ghcr.io/${GITHUB_USER}/${PROJECT_NAME}-api:${RESOURCE_SUFFIX}"

az webapp create --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --plan "${PROJECT_NAME}-${RESOURCE_SUFFIX}-plan" --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-api" --deployment-container-image-name "ghcr.io/${GITHUB_USER}/${PROJECT_NAME}-api:${RESOURCE_SUFFIX}" --docker-registry-server-user "${GITHUB_USER}" --docker-registry-server-password "${ARKANSAS_GITHUB_TOKEN}" --output "none"

az webapp config appsettings set --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-api" --settings APPLICATION_INSIGHTS_CONNECTION_STRING=${APPLICATION_INSIGHTS_CONNECTION_STRING}

popd

pushd src/web

docker build -t "ghcr.io/${GITHUB_USER}/${PROJECT_NAME}-web:${RESOURCE_SUFFIX}" .
docker push "ghcr.io/${GITHUB_USER}/${PROJECT_NAME}-web:${RESOURCE_SUFFIX}"

az webapp create --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --plan "${PROJECT_NAME}-${RESOURCE_SUFFIX}-plan" --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-web" --deployment-container-image-name "ghcr.io/${GITHUB_USER}/${PROJECT_NAME}-web:${RESOURCE_SUFFIX}" --docker-registry-server-user "${GITHUB_USER}" --docker-registry-server-password "${ARKANSAS_GITHUB_TOKEN}" --output "none"

az webapp config appsettings set --resource-group "${PROJECT_NAME}-${RESOURCE_SUFFIX}-rg" --name "${PROJECT_NAME}-${RESOURCE_SUFFIX}-web" --settings APPLICATION_INSIGHTS_CONNECTION_STRING=${APPLICATION_INSIGHTS_CONNECTION_STRING}

popd

docker logout
