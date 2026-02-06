using Sale.Domain.Abstractions;

namespace Sale.Domain.Entities;

/// <summary>
///     Customer entity representing a customer in the sales system
///     Extends BaseEntity for audit trails and soft delete support
/// </summary>

public sealed class Customer : BaseEntity
{
    public string Code { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Address { get; set; } = null!;
    public string PhoneNumber { get; set; } = null!;
}
