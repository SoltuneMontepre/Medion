using FluentValidation;
using Sale.Application.Features.Customer.Queries;

namespace Sale.Application.Features.Customer.Validators;

/// <summary>
///     Validator for GetCustomerByIdQuery
///     Ensures customer ID is valid
/// </summary>
public class GetCustomerByIdQueryValidator : AbstractValidator<GetCustomerByIdQuery>
{
    public GetCustomerByIdQueryValidator()
    {
        RuleFor(x => x.CustomerId)
            .NotEmpty()
            .WithMessage("Customer ID is required");
    }
}
