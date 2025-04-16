FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build

WORKDIR /src

COPY "api.csproj" /src/

RUN dotnet restore "/src/api.csproj"

COPY . .

RUN dotnet build "api.csproj" -c Release -o /app/build

FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS publish

WORKDIR /app

COPY --from=build /app/build .

ENTRYPOINT [ "dotnet", "api.dll" ]

LABEL org.opencontainers.image.source https://github.com/polatengin/arkansas
