namespace Security.Infrastructure;

public sealed class VaultOptions
{
    public const string SectionName = "Vault";

    public string Url { get; set; } = string.Empty;
    public string MountPoint { get; set; } = "transit";
    public string KeyName { get; set; } = "medion-order-key";
    public VaultAuthOptions Auth { get; set; } = new();
}

public sealed class VaultAuthOptions
{
    public string Method { get; set; } = "Token";
    public string? RoleId { get; set; }
    public string? SecretId { get; set; }
}
