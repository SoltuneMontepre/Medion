using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Common.DTOs;

/// <summary>
///     DTO for customer representation
/// </summary>
public class CustomerDto
{
    public CustomerId Id { get; set; }
    public string Code { get; set; } = null!;
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Address { get; set; } = null!;
    public string PhoneNumber { get; set; } = null!;
    public DateTime CreatedAt { get; set; }
    public DateTime? UpdatedAt { get; set; }
    public UserId? CreatedBy { get; set; }
    public UserId? UpdatedBy { get; set; }
}
