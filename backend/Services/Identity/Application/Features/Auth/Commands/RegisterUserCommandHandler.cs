using Identity.Application.Common.DTOs;
using Identity.Domain.Entities;
using Identity.Domain.Repositories;
using Mapster;
using MediatR;
using Microsoft.AspNetCore.Identity;

namespace Identity.Application.Features.Auth.Commands;

/// <summary>
///     Handler for RegisterUserCommand
///     Validates registration data and creates new user
/// </summary>
public class RegisterUserCommandHandler
(
    IUserRepository userRepository,
    IPasswordHasher<User> passwordHasher
)
    : IRequestHandler<RegisterUserCommand, UserDto>
{
    public async Task<UserDto> Handle(RegisterUserCommand request, CancellationToken cancellationToken)
    {
        // Check if email already exists
        if (await userRepository.ExistsByEmailAsync(request.Email, cancellationToken))
            throw new InvalidOperationException($"Email '{request.Email}' is already registered.");

        // Check if username already exists
        if (await userRepository.ExistsByUserNameAsync(request.UserName, cancellationToken))
            throw new InvalidOperationException($"Username '{request.UserName}' is already taken.");

        // Create new user entity
        var user = User.Create(
            request.Email,
            request.UserName,
            request.FirstName,
            request.LastName);

        // Set password hash
        user.SetPassword(passwordHasher.HashPassword(user, request.Password));

        // Set optional fields
        if (!string.IsNullOrWhiteSpace(request.PhoneNumber)) user.PhoneNumber = request.PhoneNumber;

        if (!string.IsNullOrWhiteSpace(request.Department)) user.Department = request.Department;

        // Save user to database
        await userRepository.AddAsync(user, cancellationToken);

        // Map to DTO and return
        return user.Adapt<UserDto>();
    }
}
