using Identity.Application.Common.DTOs;
using MediatR;

namespace Identity.Application.Features.Auth.Queries;

/// <summary>
///     Query to get user by ID
/// </summary>
public class GetUserByIdQuery : IRequest<UserDto>
{
    public GetUserByIdQuery(Guid userId)
    {
        UserId = userId;
    }

    public Guid UserId { get; set; }
}
