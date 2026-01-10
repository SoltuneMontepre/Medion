# syntax=docker/dockerfile:1.7-labs
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ../../../../Directory.Build.props ./
COPY ../../../../Directory.Packages.props ./
COPY ../Domain/ ../Services/Payroll/Domain/
COPY ../Application/ ../Services/Payroll/Application/
COPY ../Infrastructure/ ../Services/Payroll/Infrastructure/
COPY . ../Services/Payroll/API/
WORKDIR /src/Services/Payroll/API
RUN dotnet restore
RUN dotnet publish -c Release -o /out /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=build /out .
ENTRYPOINT ["dotnet", "Payroll.API.dll"]
