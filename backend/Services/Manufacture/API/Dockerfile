FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Directory.Build.props ./
COPY Directory.Packages.props ./
COPY ServiceDefaults/ ./ServiceDefaults/
COPY Services/Manufacture/Domain/ ./Services/Manufacture/Domain/
COPY Services/Manufacture/Application/ ./Services/Manufacture/Application/
COPY Services/Manufacture/Infrastructure/ ./Services/Manufacture/Infrastructure/
COPY Services/Manufacture/API/ ./Services/Manufacture/API/

WORKDIR /src/Services/Manufacture/API
RUN dotnet restore
RUN dotnet publish -c Release -o /out /p:UseAppHost=false

FROM public.ecr.aws/lambda/dotnet:10 AS runtime
WORKDIR /var/task
COPY --from=build /out .
CMD ["Manufacture.API"]
