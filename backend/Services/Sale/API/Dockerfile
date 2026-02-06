FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

COPY Directory.Build.props ./
COPY Directory.Packages.props ./
COPY Protos ./Protos
COPY ServiceDefaults/ ./ServiceDefaults/
COPY Services/SharedStorage/ ./Services/SharedStorage/
COPY Services/Sale/Domain/ ./Services/Sale/Domain/
COPY Services/Sale/Application/ ./Services/Sale/Application/
COPY Services/Sale/Infrastructure/ ./Services/Sale/Infrastructure/
COPY Services/Sale/API/ ./Services/Sale/API/

WORKDIR /src/Services/Sale/API
RUN dotnet restore
RUN dotnet publish -c Release -o /out /p:UseAppHost=false

FROM public.ecr.aws/lambda/dotnet:10.0 AS runtime
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

COPY --from=build /out .
ENTRYPOINT ["dotnet", "Sale.API.dll"]
