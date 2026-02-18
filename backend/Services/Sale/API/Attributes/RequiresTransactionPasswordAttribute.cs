namespace Sale.API.Attributes;

/// <summary>
/// Marks a controller action as requiring a transaction password header
/// for digital signature verification
/// </summary>
[AttributeUsage(AttributeTargets.Method)]
public class RequiresTransactionPasswordAttribute : Attribute
{
}
