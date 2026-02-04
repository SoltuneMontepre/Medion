using Identity.Application.Common.DTOs;

namespace Identity.Application.Features.Auth.Queries;

/// <summary>
///     Query to get user by ID
/// </summary>
public class GetUserByIdQuery(Guid userId) : IRequest<UserDto>
{
    public Guid UserId { get; set; } = userId;
}
