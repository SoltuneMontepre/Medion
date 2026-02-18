using FluentValidation;

namespace Sale.Application.Features.Order.Commands.Validators;

public class CreateOrderCommandValidator : AbstractValidator<CreateOrderCommand>
{
    public CreateOrderCommandValidator()
    {
        RuleFor(x => x.CustomerId)
            .Must(id => !id.IsEmpty)
            .WithMessage("CustomerId is required");

        RuleFor(x => x.SalesStaffId)
            .Must(id => !id.IsEmpty)
            .WithMessage("SalesStaffId is required");

        RuleFor(x => x.Pin)
            .NotEmpty()
            .WithMessage("PIN is required")
            .MaximumLength(12)
            .WithMessage("PIN must be at most 12 characters");

        RuleFor(x => x.Items)
            .NotEmpty()
            .WithMessage("At least one product is required");

        RuleForEach(x => x.Items).ChildRules(item =>
        {
            item.RuleFor(i => i.ProductId)
                .Must(id => !id.IsEmpty)
                .WithMessage("ProductId is required");

            item.RuleFor(i => i.Quantity)
                .GreaterThan(0)
                .WithMessage("Quantity must be a positive integer");
        });
    }
}
