using Sale.Domain.Entities;

namespace Sale.Application.Abstractions;

public interface IOrderRepository
{
    ValueTask<Order?> GetAsync(string id, CancellationToken ct = default);
    ValueTask<Order> AddAsync(Order order, CancellationToken ct = default);
}
