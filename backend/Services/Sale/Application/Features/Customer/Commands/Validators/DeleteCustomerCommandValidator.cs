using FluentValidation;

namespace Sale.Application.Features.Customer.Commands.Validators;

/// <summary>
///     Validator for DeleteCustomerCommand
///     Ensures customer ID is valid
/// </summary>
public class DeleteCustomerCommandValidator : AbstractValidator<DeleteCustomerCommand>
{
    public DeleteCustomerCommandValidator()
    {
        RuleFor(x => x.Id)
            .NotEmpty()
            .WithMessage("Customer ID is required");
    }
}
