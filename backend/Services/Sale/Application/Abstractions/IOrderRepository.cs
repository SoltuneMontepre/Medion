using Sale.Domain.Entities;
using Sale.Domain.Identifiers.Id;

namespace Sale.Application.Abstractions;

public interface IOrderRepository : IBaseRepository<Order, OrderId>
{
    Task<Order?> GetTodayOrderForCustomerAsync(CustomerId customerId, DateOnly date,
        CancellationToken cancellationToken = default);

    Task<IReadOnlyList<Order>> GetOrdersByDateAsync(DateOnly date, CancellationToken cancellationToken = default);

    Task<string> GenerateOrderNumberAsync(DateOnly date, CancellationToken cancellationToken = default);

    /// <summary>
    ///     Saves a tracked order whose Items collection has been cleared and repopulated with new items.
    ///     Old items are detected as deleted (required FK); new items are explicitly marked as Added.
    /// </summary>
    Task UpdateOrderWithNewItemsAsync(Order order, CancellationToken cancellationToken = default);
}
