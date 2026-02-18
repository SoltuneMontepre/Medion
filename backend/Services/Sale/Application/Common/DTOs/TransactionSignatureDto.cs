namespace Sale.Application.Common.DTOs;

/// <summary>
///     DTO representing a signed transaction
/// </summary>
public record TransactionSignatureDto
{
  public string SignatureHash { get; set; } = null!;
  public long TimestampUtc { get; set; }
  public string OperationType { get; set; } = null!;
  public string UserId { get; set; } = null!;
}
