using Identity.Application.Common.Abstractions;
using Identity.Application.Common.DTOs;
using Identity.Domain.Entities;
using Identity.Domain.Repositories;
using Mapster;
using MediatR;
using Microsoft.AspNetCore.Identity;

namespace Identity.Application.Features.Auth.Commands;

/// <summary>
///     Handler for LoginCommand
///     Authenticates user and returns JWT token
/// </summary>
public class LoginCommandHandler
(
    IUserRepository userRepository,
    IPasswordHasher<User> passwordHasher,
    ITokenService tokenService
) : IRequestHandler<LoginCommand, AuthTokenDto>
{
    public async Task<AuthTokenDto> Handle(LoginCommand request, CancellationToken cancellationToken)
    {
        // Find user by email or username
        var user = (await userRepository.GetByEmailAsync(request.UserNameOrEmail, cancellationToken)
                   ?? await userRepository.GetByUserNameAsync(request.UserNameOrEmail, cancellationToken))
                   ?? throw new UnauthorizedAccessException("Invalid credentials.");

        // Verify password
        var result = passwordHasher.VerifyHashedPassword(user, user.PasswordHash!, request.Password);
        if (result == PasswordVerificationResult.Failed)
        {
            user.IncrementFailedLoginAttempt();
            await userRepository.UpdateAsync(user, cancellationToken);
            throw new UnauthorizedAccessException("Invalid credentials.");
        }

        // Check if user is active
        if (!user.IsActive) throw new UnauthorizedAccessException("User account is inactive.");

        // Check if account is locked
        if (user.LockoutEnd.HasValue && user.LockoutEnd > DateTimeOffset.UtcNow)
            throw new UnauthorizedAccessException("User account is locked.");

        // Reset failed login attempts
        user.UnlockAccount();
        await userRepository.UpdateAsync(user, cancellationToken);

        // Generate JWT token
        var token = await tokenService.GenerateTokenAsync(user, cancellationToken);

        return new AuthTokenDto
        {
            AccessToken = token,
            ExpiresIn = 3600,
            User = user.Adapt<UserDto>()
        };
    }
}
