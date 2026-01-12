using Amazon.S3;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
namespace SharedStorage;

public static class S3ServiceCollectionExtensions
{
  public static IServiceCollection AddS3Storage(this IServiceCollection services, IConfiguration configuration)
  {
    var options = configuration.GetSection("S3Storage").Get<S3StorageOptions>() ?? new S3StorageOptions(); var s3Config = new Amazon.S3.AmazonS3Config { RegionEndpoint = Amazon.RegionEndpoint.GetBySystemName(options.Region), ForcePathStyle = options.UsePathStyle }; if (!string.IsNullOrEmpty(options.Endpoint)) { s3Config.ServiceURL = options.Endpoint; }
    services.Configure<S3StorageOptions>(o => configuration.GetSection("S3Storage").Bind(o));
    services.AddSingleton(s3Config);
    services.AddSingleton<IAmazonS3>(new AmazonS3Client(s3Config));
    services.AddScoped<IStorageService, S3StorageService>();

    return services;
  }
}

