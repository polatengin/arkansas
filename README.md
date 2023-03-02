# Arizona

You can find deploy script in `deploy.sh` file.

## Deploy guideline

1. Clone this repository
2. Login to Azure CLI
3. Run `./deploy.sh` script

## Resources created

- Resource group
- Log Analytics workspace
- Application Insights
- Azure App Service Plan
- Web App (dotnet api app)
- Web App (nextjs 13 web app)

After deployment, you can find logs and metrics in the application insights.
