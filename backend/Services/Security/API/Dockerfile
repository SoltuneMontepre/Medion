# syntax=docker/dockerfile:1.7-labs
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["Directory.Build.props", "."]
COPY ["Directory.Packages.props", "."]
COPY ["Shared/Shared.csproj", "Shared/"]
COPY ["ServiceDefaults/ServiceDefaults.csproj", "ServiceDefaults/"]
COPY ["Services/Sale/Domain/Sale.Domain.csproj", "Services/Sale/Domain/"]
COPY ["Services/Security/Domain/Security.Domain.csproj", "Services/Security/Domain/"]
COPY ["Services/Security/Application/Security.Application.csproj", "Services/Security/Application/"]
COPY ["Services/Security/Infrastructure/Security.Infrastructure.csproj", "Services/Security/Infrastructure/"]
COPY ["Services/Security/API/Security.API.csproj", "Services/Security/API/"]
COPY ["Services/SharedStorage/SharedStorage.csproj", "Services/SharedStorage/"]
RUN dotnet restore "Services/Security/API/Security.API.csproj"
COPY . .
WORKDIR "/src/Services/Security/API"
RUN dotnet publish "Security.API.csproj" -c Release -o /out /p:UseAppHost=false

FROM base AS final
WORKDIR /app
# AWS Lambda Web Adapter: translates Lambda events to HTTP requests for Kestrel
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=build /out .
ENTRYPOINT ["dotnet", "Security.API.dll"]
