using System.Text;
using Mapster;
using MediatR;
using Sale.Application.Abstractions;
using Sale.Application.Common.DTOs;
using Sale.Domain.Entities;
using ServiceDefaults.ApiResponses;

namespace Sale.Application.Features.Order.Commands;

// TODO: LEGACY PIN-based signing temporarily disabled pending migration to transaction password-based signing via TransactionSigningBehavior
public class CreateOrderCommandHandler(
        ICustomerRepository customerRepository,
        IOrderRepository orderRepository,
        IProductRepository productRepository)
    // IDigitalSignatureService digitalSignatureService) // Commented out - no longer registered
    : IRequestHandler<CreateOrderCommand, ApiResult<OrderDto>>
{
    public async Task<ApiResult<OrderDto>> Handle(CreateOrderCommand request, CancellationToken cancellationToken)
    {
        var customer = await customerRepository.GetByIdAsync(request.CustomerId, cancellationToken);
        if (customer == null)
            return ApiResult<OrderDto>.NotFound("Customer not found");

        var today = DateOnly.FromDateTime(DateTime.UtcNow);
        var existingOrder =
            await orderRepository.GetTodayOrderForCustomerAsync(request.CustomerId, today, cancellationToken);
        if (existingOrder != null)
        {
            var errors = new Dictionary<string, string[]>
            {
                { "ExistingOrderId", [existingOrder.Id.ToString()] },
                { "ExistingOrderNumber", [existingOrder.OrderNumber] }
            };

            return ApiResult<OrderDto>.Failure("Customer already has an order today", 409, errors);
        }

        var productIds = request.Items.Select(i => i.ProductId).Distinct().ToArray();
        var products = await productRepository.GetByIdsAsync(productIds, cancellationToken);
        var productLookup = products.ToDictionary(p => p.Id, p => p);

        var missingProductIds = productIds.Where(id => !productLookup.ContainsKey(id)).ToArray();
        if (missingProductIds.Length != 0)
        {
            var errors = new Dictionary<string, string[]>
            {
                { "MissingProducts", missingProductIds.Select(id => id.ToString()).ToArray() }
            };

            return ApiResult<OrderDto>.Failure("One or more products were not found", 400, errors);
        }

        var orderNumber = await orderRepository.GenerateOrderNumberAsync(today, cancellationToken);
        var order = new Domain.Entities.Order();
        order.Initialize(orderNumber, request.CustomerId, request.SalesStaffId, DateTime.UtcNow);

        foreach (var item in request.Items)
        {
            var product = productLookup[item.ProductId];
            var orderItem = new OrderItem();
            orderItem.Initialize(order.Id, item.ProductId, product.Code, product.Name, item.Quantity);
            orderItem.CreatedAt = DateTime.UtcNow;
            orderItem.CreatedBy = request.SalesStaffId;
            order.AddItem(orderItem);
        }

        // LEGACY: PIN-based signing logic - temporarily commented out
        // TODO: Replace with TransactionSigningBehavior using transaction passwords
        /*
        var payload = BuildSignaturePayload(order, request.Items);
        DigitalSignatureResult signature;
        try
        {
            signature = await digitalSignatureService.SignAsync(request.SalesStaffId, payload, request.Pin, cancellationToken);
        }
        catch (DigitalSignatureException signatureException) when (signatureException.Failure == DigitalSignatureFailure.InvalidPin)
        {
            return ApiResult<OrderDto>.Failure("Invalid PIN", 401);
        }
        catch (DigitalSignatureException signatureException) when (signatureException.Failure == DigitalSignatureFailure.InvalidArgument)
        {
            return ApiResult<OrderDto>.Failure(signatureException.Message, 400);
        }
        catch (DigitalSignatureException signatureException) when (signatureException.Failure == DigitalSignatureFailure.Unavailable)
        {
            return ApiResult<OrderDto>.InternalServerError("Security service is unavailable.");
        }
        catch (DigitalSignatureException signatureException) when (signatureException.Failure == DigitalSignatureFailure.Internal)
        {
            return ApiResult<OrderDto>.InternalServerError(signatureException.Message);
        }
        order.MarkSigned(request.SalesStaffId, signature.Signature, signature.PublicKey, DateTime.UtcNow);
        */

        // Temporary: Skip signing until migration is complete
        // order.MarkSigned(...) - commented out
        order.CreatedAt = DateTime.UtcNow;
        order.CreatedBy = request.SalesStaffId;

        await orderRepository.AddAsync(order, cancellationToken);

        var dto = order.Adapt<OrderDto>();
        dto.Items = order.Items.Adapt<IReadOnlyCollection<OrderItemDto>>();
        return ApiResult<OrderDto>.Created(dto, "Order created and signed successfully");
    }

    private static string BuildSignaturePayload(Domain.Entities.Order order,
        IReadOnlyCollection<CreateOrderItemDto> items)
    {
        var builder = new StringBuilder();
        builder.Append(order.OrderNumber).Append('|')
            .Append(order.CustomerId).Append('|')
            .Append(order.OrderDate.ToString("O")).Append('|')
            .Append(order.SalesStaffId).Append('|');

        foreach (var item in items.OrderBy(i => i.ProductId.Value))
            builder.Append(item.ProductId).Append(':').Append(item.Quantity).Append(';');

        return builder.ToString();
    }
}
