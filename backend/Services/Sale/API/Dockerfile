# syntax=docker/dockerfile:1.7-labs

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ../../../../Directory.Build.props ./
COPY ../../../../Directory.Packages.props ./
COPY ../../../../Protos ./Protos
COPY ../Domain/ ../Services/Sale/Domain/
COPY ../Application/ ../Services/Sale/Application/
COPY ../Infrastructure/ ../Services/Sale/Infrastructure/
COPY . ../Services/Sale/API/
WORKDIR /src/Services/Sale/API
RUN dotnet restore
RUN dotnet publish -c Release -o /out /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /out .
ENTRYPOINT ["dotnet", "Sale.API.dll"]
