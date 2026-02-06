namespace Sale.Application.Common.DTOs;

/// <summary>
///     DTO for customer representation
/// </summary>
public class CustomerDto
{
  public Guid Id { get; set; }
  public string Code { get; set; } = null!;
  public string FirstName { get; set; } = null!;
  public string LastName { get; set; } = null!;
  public string Address { get; set; } = null!;
  public string PhoneNumber { get; set; } = null!;
  public DateTime CreatedAt { get; set; }
  public DateTime? UpdatedAt { get; set; }
  public Guid? CreatedBy { get; set; }
  public Guid? UpdatedBy { get; set; }
}
