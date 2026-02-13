using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using VaultSharp;
using VaultSharp.V1.AuthMethods;
using VaultSharp.V1.AuthMethods.AppRole;
using VaultSharp.V1.AuthMethods.Token;

namespace Security.Infrastructure;

public static class VaultClientExtensions
{
  public static IServiceCollection AddVaultClient(this IServiceCollection services, IConfiguration configuration)
  {
    var section = configuration.GetSection(VaultOptions.SectionName);

    var options = new VaultOptions
    {
      Url = section["Url"] ?? string.Empty,
      MountPoint = section["MountPoint"] ?? "transit",
      KeyName = section["KeyName"] ?? "medion-order-key",
      Auth = new VaultAuthOptions
      {
        Method = section["Auth:Method"] ?? "Token",
        RoleId = section["Auth:RoleId"],
        SecretId = section["Auth:SecretId"]
      }
    };

    if (string.IsNullOrWhiteSpace(options.Url))
      throw new InvalidOperationException("Vault Url is required. Configure Vault:Url.");

    var token = Environment.GetEnvironmentVariable("MEDION_VAULT_TOKEN");
    var roleId = Environment.GetEnvironmentVariable("MEDION_VAULT_ROLE_ID") ?? options.Auth.RoleId;
    var secretId = Environment.GetEnvironmentVariable("MEDION_VAULT_SECRET_ID") ?? options.Auth.SecretId;

    IAuthMethodInfo authMethod;
    if (!string.IsNullOrWhiteSpace(token))
    {
      authMethod = new TokenAuthMethodInfo(token);
    }
    else if (string.Equals(options.Auth.Method, "AppRole", StringComparison.OrdinalIgnoreCase)
             && !string.IsNullOrWhiteSpace(roleId)
             && !string.IsNullOrWhiteSpace(secretId))
    {
      authMethod = new AppRoleAuthMethodInfo(roleId, secretId);
    }
    else
    {
      throw new InvalidOperationException(
          "Vault authentication is not configured. Set MEDION_VAULT_TOKEN or configure Vault:Auth for AppRole.");
    }

    var settings = new VaultClientSettings(options.Url, authMethod)
    {
      ContinueAsyncTasksOnCapturedContext = false
    };

    services.AddSingleton(options);
    services.AddSingleton<IVaultClient>(new VaultClient(settings));

    return services;
  }
}
