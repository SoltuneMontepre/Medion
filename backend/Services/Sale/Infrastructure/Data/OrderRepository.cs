using Microsoft.EntityFrameworkCore;
using Sale.Application.Abstractions;
using Sale.Domain.Entities;

namespace Sale.Infrastructure.Data;

public sealed class OrderRepository(SaleDbContext db) : IOrderRepository
{
    public ValueTask<Order?> GetAsync(string id, CancellationToken ct = default)
    {
        return new ValueTask<Order?>(db.Orders.AsNoTracking().FirstOrDefaultAsync(o => o.Id == id, ct));
    }

    public async ValueTask<Order> AddAsync(Order order, CancellationToken ct = default)
    {
        db.Orders.Add(order);
        await db.SaveChangesAsync(ct);
        return order;
    }
}
