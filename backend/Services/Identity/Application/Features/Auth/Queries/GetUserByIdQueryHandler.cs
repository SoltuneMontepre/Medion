using Identity.Application.Common.DTOs;
using Identity.Domain.Repositories;

namespace Identity.Application.Features.Auth.Queries;

/// <summary>
///     Handler for GetUserByIdQuery
/// </summary>
public class GetUserByIdQueryHandler(IUserRepository userRepository) : IRequestHandler<GetUserByIdQuery, UserDto>
{
    public async Task<UserDto> Handle(GetUserByIdQuery request, CancellationToken cancellationToken)
    {
        var user = await userRepository.GetByIdAsync(request.UserId, cancellationToken);
        if (user == null) throw new KeyNotFoundException($"User with ID '{request.UserId}' not found.");

        return user.Adapt<UserDto>();
    }
}
