using System.ComponentModel;

namespace Audit.Domain.Identifiers;

/// <summary>
///     Strongly-typed identifier for global audit log records.
///     Ensures type safety and domain semantics across the Audit Service.
/// </summary>
[TypeConverter(typeof(StronglyTypedIdTypeConverter<GlobalAuditLogId>))]
public readonly record struct GlobalAuditLogId(Guid Value) : IStronglyTypedId, IParsable<GlobalAuditLogId>
{
  public static GlobalAuditLogId New() => new(Guid.CreateVersion7());
  public static GlobalAuditLogId Empty => new(Guid.Empty);
  public bool IsEmpty => Value == Guid.Empty;

  public static GlobalAuditLogId Parse(string value) => Parse(value, null);

  public static GlobalAuditLogId Parse(string s, IFormatProvider? provider)
  {
    if (!TryParse(s, provider, out var result))
      throw new FormatException("Invalid GlobalAuditLogId format.");
    return result;
  }

  public static bool TryParse(string? s, IFormatProvider? provider, out GlobalAuditLogId result)
  {
    result = Empty;
    if (string.IsNullOrWhiteSpace(s))
      return false;

    var trimmed = s.Trim();
    if (trimmed.StartsWith("value,", StringComparison.OrdinalIgnoreCase))
      trimmed = trimmed["value,".Length..];

    if (!Guid.TryParse(trimmed, out var guid))
      return false;

    result = new GlobalAuditLogId(guid);
    return true;
  }

  public override string ToString() => Value.ToString();
}
