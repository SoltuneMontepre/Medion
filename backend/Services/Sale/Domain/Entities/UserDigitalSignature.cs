using Sale.Domain.Identifiers;

namespace Sale.Domain.Entities;

public sealed class UserDigitalSignature
{
  public UserId UserId { get; set; }
  public byte[] PinHash { get; set; } = Array.Empty<byte>();
  public byte[] PinSalt { get; set; } = Array.Empty<byte>();
  public string PublicKey { get; set; } = string.Empty;
  public DateTime CreatedAt { get; set; }
  public DateTime? UpdatedAt { get; set; }
}
