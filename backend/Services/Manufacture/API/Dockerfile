# syntax=docker/dockerfile:1.7-labs
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ../../../../Directory.Build.props ./
COPY ../../../../Directory.Packages.props ./
COPY ../Domain/ ../Services/Manufacture/Domain/
COPY ../Application/ ../Services/Manufacture/Application/
COPY ../Infrastructure/ ../Services/Manufacture/Infrastructure/
COPY . ../Services/Manufacture/API/
WORKDIR /src/Services/Manufacture/API
RUN dotnet restore
RUN dotnet publish -c Release -o /out /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /out .
ENTRYPOINT ["dotnet", "Manufacture.API.dll"]
