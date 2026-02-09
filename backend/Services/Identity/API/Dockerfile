# syntax=docker/dockerfile:1.7-labs
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY Directory.Build.props ./
COPY Directory.Packages.props ./
COPY Protos ./Protos
COPY ServiceDefaults/ ./ServiceDefaults/
COPY Services/Identity/Domain/ ./Services/Identity/Domain/
COPY Services/Identity/Application/ ./Services/Identity/Application/
COPY Services/Identity/Infrastructure/ ./Services/Identity/Infrastructure/
COPY Services/Identity/API/ ./Services/Identity/API/
WORKDIR /src/Services/Identity/API
RUN dotnet restore
RUN dotnet publish -c Release -o /out /p:UseAppHost=false

FROM base AS final
WORKDIR /app
# AWS Lambda Web Adapter: translates Lambda events to HTTP requests for Kestrel
COPY --from=public.ecr.aws/awsguru/aws-lambda-adapter:0.9.1 /lambda-adapter /opt/extensions/lambda-adapter
COPY --from=build /out .
ENTRYPOINT ["dotnet", "Identity.API.dll"]