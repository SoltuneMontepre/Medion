FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Directory.Build.props ./
COPY Directory.Packages.props ./
COPY ServiceDefaults/ ./ServiceDefaults/
COPY Services/Approval/Domain/ ./Services/Approval/Domain/
COPY Services/Approval/Application/ ./Services/Approval/Application/
COPY Services/Approval/Infrastructure/ ./Services/Approval/Infrastructure/
COPY Services/Approval/API/ ./Services/Approval/API/

WORKDIR /src/Services/Approval/API
RUN dotnet restore
RUN dotnet publish -c Release -o /out /p:UseAppHost=false /p:PublishReadyToRun=true /p:PublishSingleFile=false

FROM public.ecr.aws/lambda/dotnet:10 AS runtime
WORKDIR /var/task
COPY --from=build /out .
CMD ["Approval.API"]
