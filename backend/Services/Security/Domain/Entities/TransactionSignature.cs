using Security.Domain.Identifiers;
using Security.Domain.ValueObjects;

namespace Security.Domain.Entities;

/// <summary>
///     Represents a digitally signed transaction in the Security domain
/// </summary>
public sealed class TransactionSignature : IAuditable
{
  public SignatureId Id { get; set; }
  public string Payload { get; set; } = null!;
  public SignatureHash SignatureHash { get; set; } = null!;
  public string OperationType { get; set; } = null!;
  public DateTime CreatedAt { get; set; }
  public DateTime? UpdatedAt { get; set; }
  public Guid? CreatedBy { get; set; }
  public Guid? UpdatedBy { get; set; }
  public bool IsDeleted { get; set; }
  public DateTime? DeletedAt { get; set; }
  public Guid? DeletedBy { get; set; }

  /// <summary>
  ///     Factory method to create a signed transaction
  /// </summary>
  public static TransactionSignature CreateSigned(
      string payload,
      string signatureHashValue,
      string operationType,
      Guid? userId = null)
  {
    return new TransactionSignature
    {
      Id = SignatureId.New(),
      Payload = payload,
      SignatureHash = SignatureHash.Create(signatureHashValue),
      OperationType = operationType,
      CreatedAt = DateTime.UtcNow,
      CreatedBy = userId
    };
  }
}

public interface IAuditable
{
  DateTime CreatedAt { get; set; }
  DateTime? UpdatedAt { get; set; }
  Guid? CreatedBy { get; set; }
  Guid? UpdatedBy { get; set; }
  bool IsDeleted { get; set; }
  DateTime? DeletedAt { get; set; }
  Guid? DeletedBy { get; set; }
}
