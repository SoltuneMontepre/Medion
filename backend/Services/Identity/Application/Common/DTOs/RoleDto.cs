using Identity.Domain.Identifiers;

namespace Identity.Application.Common.DTOs;

/// <summary>
///     DTO for role representation
/// </summary>
public class RoleDto
{
    public IdentityId Id { get; set; }
    public string Name { get; set; } = null!;
    public string? Description { get; set; }
}
