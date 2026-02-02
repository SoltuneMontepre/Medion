using Identity.Application.Common.DTOs;
using Identity.Domain.Repositories;
using Mapster;
using MediatR;

namespace Identity.Application.Features.Auth.Queries;

/// <summary>
///     Handler for GetUserByIdQuery
/// </summary>
public class GetUserByIdQueryHandler : IRequestHandler<GetUserByIdQuery, UserDto>
{
    private readonly IUserRepository _userRepository;

    public GetUserByIdQueryHandler(IUserRepository userRepository)
    {
        _userRepository = userRepository;
    }

    public async Task<UserDto> Handle(GetUserByIdQuery request, CancellationToken cancellationToken)
    {
        var user = await _userRepository.GetByIdAsync(request.UserId, cancellationToken);
        if (user == null) throw new KeyNotFoundException($"User with ID '{request.UserId}' not found.");

        return user.Adapt<UserDto>();
    }
}
