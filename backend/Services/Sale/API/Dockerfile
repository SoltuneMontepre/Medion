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
COPY ["Services/Sale/Application/Sale.Application.csproj", "Services/Sale/Application/"]
COPY ["Services/Sale/Infrastructure/Sale.Infrastructure.csproj", "Services/Sale/Infrastructure/"]
COPY ["Services/Sale/API/Sale.API.csproj", "Services/Sale/API/"]
COPY ["Services/SharedStorage/SharedStorage.csproj", "Services/SharedStorage/"]
RUN dotnet restore "Services/Sale/API/Sale.API.csproj"
COPY . .
WORKDIR "/src/Services/Sale/API"
RUN dotnet publish "Sale.API.csproj" -c Release -o /out /p:UseAppHost=false

FROM base AS final
WORKDIR /app
# AWS Lambda Web Adapter: translates Lambda events to HTTP requests for Kestrel
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=build /out .
ENTRYPOINT ["dotnet", "Sale.API.dll"]
