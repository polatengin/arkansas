FROM mcr.microsoft.com/dotnet/nightly/sdk:7.0 AS build
WORKDIR /src
COPY "api.csproj" /src/
RUN dotnet restore "/src/api.csproj"
COPY . .
RUN dotnet build "api.csproj" -c Release -o /app/build

FROM mcr.microsoft.com/dotnet/nightly/aspnet:7.0-alpine3.17 AS publish
ARG AI_CONNECTION_STRING=""
ENV APPLICATION_INSIGHTS_CONNECTION_STRING=$AI_CONNECTION_STRING
WORKDIR /app
COPY --from=build /app/build .
ENTRYPOINT [ "dotnet", "api.dll" ]
