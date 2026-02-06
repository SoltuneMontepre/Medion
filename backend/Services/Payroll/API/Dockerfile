FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Directory.Build.props ./
COPY Directory.Packages.props ./
COPY ServiceDefaults/ ./ServiceDefaults/
COPY Services/Payroll/Domain/ ./Services/Payroll/Domain/
COPY Services/Payroll/Application/ ./Services/Payroll/Application/
COPY Services/Payroll/Infrastructure/ ./Services/Payroll/Infrastructure/
COPY Services/Payroll/API/ ./Services/Payroll/API/

WORKDIR /src/Services/Payroll/API
RUN dotnet restore
RUN dotnet publish -c Release -o /out /p:UseAppHost=false

FROM public.ecr.aws/lambda/dotnet:10.0 AS runtime
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

COPY --from=build /out .
ENTRYPOINT ["dotnet", "Payroll.API.dll"]
