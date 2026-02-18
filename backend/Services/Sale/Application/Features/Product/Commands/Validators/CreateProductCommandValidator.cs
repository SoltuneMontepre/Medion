using FluentValidation;

namespace Sale.Application.Features.Product.Commands.Validators;

public class CreateProductCommandValidator : AbstractValidator<CreateProductCommand>
{
    public CreateProductCommandValidator()
    {
        RuleFor(x => x.Code)
            .NotEmpty()
            .WithMessage("Code is required")
            .MaximumLength(50)
            .WithMessage("Code cannot exceed 50 characters");

        RuleFor(x => x.Name)
            .NotEmpty()
            .WithMessage("Name is required")
            .MaximumLength(200)
            .WithMessage("Name cannot exceed 200 characters");

        RuleFor(x => x.Specification)
            .NotEmpty()
            .WithMessage("Specification is required")
            .MaximumLength(500)
            .WithMessage("Specification cannot exceed 500 characters");

        RuleFor(x => x.Type)
            .NotEmpty()
            .WithMessage("Type is required")
            .MaximumLength(100)
            .WithMessage("Type cannot exceed 100 characters");

        RuleFor(x => x.Packaging)
            .NotEmpty()
            .WithMessage("Packaging is required")
            .MaximumLength(100)
            .WithMessage("Packaging cannot exceed 100 characters");
    }
}
