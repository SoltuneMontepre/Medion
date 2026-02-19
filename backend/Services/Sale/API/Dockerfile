# syntax=docker/dockerfile:1.7-labs
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
# If GitHub Actions runs from repo root, use backend/ prefix
# If it runs from backend/ dir, remove backend/ prefix from all paths below
COPY backend/Directory.Build.props ./
COPY backend/Directory.Packages.props ./
COPY backend/Protos/ ./Protos/
COPY backend/Shared/ ./Shared/
COPY backend/ServiceDefaults/ ./ServiceDefaults/
COPY backend/Services/SharedStorage/ ./Services/SharedStorage/
COPY backend/Services/Sale/Domain/ ./Services/Sale/Domain/
COPY backend/Services/Sale/Application/ ./Services/Sale/Application/
COPY backend/Services/Sale/Infrastructure/ ./Services/Sale/Infrastructure/
COPY backend/Services/Sale/API/ ./Services/Sale/API/
WORKDIR /src/Services/Sale/API
RUN dotnet restore
RUN dotnet publish -c Release -o /out /p:UseAppHost=false

FROM base AS final
WORKDIR /app
# AWS Lambda Web Adapter: translates Lambda events to HTTP requests for Kestrel
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=build /out .
ENTRYPOINT ["dotnet", "Sale.API.dll"]
