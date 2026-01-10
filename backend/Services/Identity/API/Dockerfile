# syntax=docker/dockerfile:1.7-labs
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ../../../../Directory.Build.props ./
COPY ../../../../Directory.Packages.props ./
COPY ../Domain/ ../Services/Identity/Domain/
COPY ../Application/ ../Services/Identity/Application/
COPY ../Infrastructure/ ../Services/Identity/Infrastructure/
COPY . ../Services/Identity/API/
WORKDIR /src/Services/Identity/API
RUN dotnet restore
RUN dotnet publish -c Release -o /out /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /out .
ENTRYPOINT ["dotnet", "Identity.API.dll"]
