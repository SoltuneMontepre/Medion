namespace Security.Domain.ValueObjects;

/// <summary>
///     Value object representing a digital signature hash with timestamp
/// </summary>
public sealed class SignatureHash : IEquatable<SignatureHash>
{
  public string Hash { get; }
  public long TimestampUtc { get; }

  private SignatureHash(string hash, long timestampUtc)
  {
    if (string.IsNullOrWhiteSpace(hash))
      throw new ArgumentException("Hash cannot be empty", nameof(hash));

    Hash = hash;
    TimestampUtc = timestampUtc;
  }

  public static SignatureHash Create(string hash)
  {
    var timestampUtc = DateTimeOffset.UtcNow.ToUnixTimeMilliseconds();
    return new SignatureHash(hash, timestampUtc);
  }

  /// <summary>
  ///     Reconstructs from persisted value (hash:timestamp format)
  /// </summary>
  public static SignatureHash Parse(string value)
  {
    var parts = value.Split(':');
    if (parts.Length != 2)
      throw new ArgumentException("Invalid signature hash format", nameof(value));

    return new SignatureHash(parts[0], long.Parse(parts[1]));
  }

  public override string ToString() => $"{Hash}:{TimestampUtc}";

  public bool Equals(SignatureHash? other) =>
      other != null && Hash == other.Hash && TimestampUtc == other.TimestampUtc;

  public override bool Equals(object? obj) =>
      obj is SignatureHash other && Equals(other);

  public override int GetHashCode() =>
      HashCode.Combine(Hash, TimestampUtc);
}
