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
RUN dotnet publish -c Release -o /out /p:UseAppHost=false /p:PublishReadyToRun=true /p:PublishSingleFile=false

FROM public.ecr.aws/lambda/dotnet:10 AS runtime
WORKDIR /var/task
COPY --from=build /out .
CMD ["Identity.API"]
