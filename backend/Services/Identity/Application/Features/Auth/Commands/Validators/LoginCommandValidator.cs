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
            .WithMessage("Email or username cannot exceed 256 characters")
            .EmailAddress()
            .When(x => x.UserNameOrEmail?.Contains('@') == true)
            .WithMessage("Invalid email format");

        RuleFor(x => x.Password)
            .NotEmpty()
            .WithMessage("Password is required")
            .MinimumLength(8)
            .WithMessage("Password must be at least 8 characters long")
            .Matches(@"[A-Z]")
            .WithMessage("Password must contain at least one uppercase letter")
            .Matches(@"[a-z]")
            .WithMessage("Password must contain at least one lowercase letter")
            .Matches(@"[0-9]")
            .WithMessage("Password must contain at least one digit")
            .Matches(@"[^a-zA-Z0-9]")
            .WithMessage("Password must contain at least one special character");
    }
}
