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

# Optimized publish for Lambda cold start performance
RUN dotnet publish -c Release -o /out \
    /p:UseAppHost=false \
    /p:PublishReadyToRun=true \
    /p:PublishSingleFile=false \
    /p:PublishTrimmed=false \
    /p:TieredCompilation=false \
    /p:TieredCompilationQuickJit=false

FROM public.ecr.aws/lambda/dotnet:10 AS runtime

# Install ca-certificates for HTTPS connections
RUN dnf install -y ca-certificates && dnf clean all

WORKDIR /var/task
COPY --from=build /out .

# Set optimized .NET runtime options for Lambda
ENV DOTNET_SYSTEM_GLOBALIZATION_INVARIANT=1 \
    DOTNET_gcServer=0 \
    DOTNET_RUNNING_IN_CONTAINER=true

