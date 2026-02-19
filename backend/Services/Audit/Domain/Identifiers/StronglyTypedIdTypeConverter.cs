using System.ComponentModel;
using System.Globalization;
using Audit.Domain.Identifiers;

namespace Audit.Domain.Identifiers;

/// <summary>
///     Type converter for strongly-typed IDs.
///     Enables String-to-ID and ID-to-String conversions for JSON serialization and type coercion.
/// </summary>
public class StronglyTypedIdTypeConverter<TId> : TypeConverter
    where TId : struct, IStronglyTypedId
{
  public override bool CanConvertFrom(ITypeDescriptorContext? context, Type sourceType)
  {
    return sourceType == typeof(string)
           || sourceType == typeof(Guid)
           || base.CanConvertFrom(context, sourceType);
  }

  public override object? ConvertFrom(ITypeDescriptorContext? context, CultureInfo? culture, object value)
  {
    return value switch
    {
      string s => s.Trim().Length == 0
          ? (object?)null
          : (object?)Activator.CreateInstance(typeof(TId), Guid.Parse(s)),
      Guid g => (object?)Activator.CreateInstance(typeof(TId), g),
      _ => base.ConvertFrom(context, culture, value)
    };
  }

  public override bool CanConvertTo(ITypeDescriptorContext? context, Type? destinationType)
  {
    return destinationType == typeof(string)
           || destinationType == typeof(Guid)
           || base.CanConvertTo(context, destinationType);
  }

  public override object? ConvertTo(ITypeDescriptorContext? context, CultureInfo? culture, object? value,
      Type destinationType)
  {
    if (value is null)
      return null;

    if (destinationType == typeof(string))
    {
      var id = (TId)value;
      return id.Value.ToString();
    }

    if (destinationType == typeof(Guid))
    {
      var id = (TId)value;
      return id.Value;
    }

    return base.ConvertTo(context, culture, value, destinationType);
  }
}
