namespace Identity.Application.Common.DTOs;

/// <summary>
///     DTO for role representation
/// </summary>
public class RoleDto
{
    public Guid Id { get; set; }
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
}
