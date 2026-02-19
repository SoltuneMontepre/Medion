namespace Sale.Application.Common.Attributes;

/// <summary>
///     Marker interface for MediatR commands that require digital signature verification
///     These commands will trigger the TransactionSigningBehavior
/// </summary>
public interface IRequireDigitalSignature
{
}
