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

FROM public.ecr.aws/lambda/dotnet:10 AS runtime
WORKDIR /var/task
COPY --from=build /out .
CMD ["Payroll.API"]
