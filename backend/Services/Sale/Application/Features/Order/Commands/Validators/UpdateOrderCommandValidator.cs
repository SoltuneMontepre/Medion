namespace Sale.Application.Features.Order.Commands.Validators;

public class UpdateOrderCommandValidator : AbstractValidator<UpdateOrderCommand>
{
    public UpdateOrderCommandValidator()
    {
        RuleFor(x => x.OrderId)
            .Must(id => !id.IsEmpty)
            .WithMessage("OrderId is required");

        RuleFor(x => x.SalesStaffId)
            .Must(id => !id.IsEmpty)
            .WithMessage("SalesStaffId is required");

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
