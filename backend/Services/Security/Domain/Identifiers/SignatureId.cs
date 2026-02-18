namespace Security.Domain.Identifiers;

/// <summary>
///     Strongly-typed identifier for TransactionSignature
/// </summary>
public readonly struct SignatureId : IEquatable<SignatureId>
{
  public Guid Value { get; }

  public SignatureId(Guid value) => Value = value;

  public static SignatureId New() => new(Guid.NewGuid());

  public static SignatureId Parse(string value) =>
      new(Guid.Parse(value));

  public override string ToString() => Value.ToString();

  public bool Equals(SignatureId other) => Value == other.Value;

  public override bool Equals(object? obj) =>
      obj is SignatureId other && Equals(other);

  public override int GetHashCode() => Value.GetHashCode();

  public static bool operator ==(SignatureId left, SignatureId right) =>
      left.Equals(right);

  public static bool operator !=(SignatureId left, SignatureId right) =>
      !left.Equals(right);
}
