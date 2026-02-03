using FluentValidation;
using Identity.Application.Common.DTOs;

namespace Identity.Application.Features.Auth.Commands.Validators;

/// <summary>
///     Validator for LoginCommand
///     Ensures email format and password requirements
/// </summary>
public class LoginCommandValidator : AbstractValidator<LoginCommand>
{
  public LoginCommandValidator()
  {
    RuleFor(x => x.UserNameOrEmail)
        .NotEmpty()
        .WithMessage("Email or username is required")
        .MaximumLength(256)
        .WithMessage("Email or username cannot exceed 256 characters");

    RuleFor(x => x.Password)
        .NotEmpty()
        .WithMessage("Password is required")
        .MinimumLength(8)
        .WithMessage("Password must be at least 8 characters long");
  }
}
