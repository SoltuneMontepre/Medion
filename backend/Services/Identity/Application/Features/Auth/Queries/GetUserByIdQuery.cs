using Identity.Application.Common.DTOs;
using Identity.Domain.Identifiers;

namespace Identity.Application.Features.Auth.Queries;

/// <summary>
///     Query to get user by ID
/// </summary>
public class GetUserByIdQuery(IdentityId userId) : IRequest<UserDto>
{
    public IdentityId UserId { get; set; } = userId;
}
