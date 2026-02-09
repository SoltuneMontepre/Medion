namespace Sale.Application.Common.DTOs;

/// <summary>
///     DTO for creating a new customer
/// </summary>
public class CreateCustomerDto
{
    public string FirstName { get; set; } = null!;
    public string LastName { get; set; } = null!;
    public string Address { get; set; } = null!;
    public string PhoneNumber { get; set; } = null!;
}
