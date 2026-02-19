using MediatR;
using Sale.Application.Abstractions;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Customer.Commands;

/// <summary>
///     Handler for DeleteCustomerCommand
/// </summary>
public class DeleteCustomerCommandHandler(ICustomerRepository customerRepository)
    : IRequestHandler<DeleteCustomerCommand, ApiResult<bool>>
{
    public async Task<ApiResult<bool>> Handle(DeleteCustomerCommand request, CancellationToken cancellationToken)
    {
        // Check if customer exists
        var exists = await customerRepository.ExistsAsync(request.Id, cancellationToken);
        if (!exists)
            return ApiResult<bool>.NotFound($"Customer with ID '{request.Id}' not found");

        // Soft delete
        await customerRepository.DeleteAsync(request.Id, cancellationToken);

        return ApiResult<bool>.Success(true, "Customer deleted successfully");
    }
}
