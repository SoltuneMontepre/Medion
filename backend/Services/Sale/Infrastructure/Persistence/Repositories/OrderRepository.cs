using System.Data;
using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Sale.Application.Abstractions;
using Sale.Domain.Entities;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;
using Sale.Infrastructure.Data;
using Sale.Infrastructure.Persistence;

namespace Sale.Infrastructure.Persistence.Repositories;

public class OrderRepository(SaleDbContext dbContext) : BaseRepository<Order, OrderId>(dbContext), IOrderRepository
{
  public override async Task<Order?> GetByIdAsync(OrderId id, CancellationToken cancellationToken = default,
    params Expression<Func<Order, object>>[] includes)
  {
    IQueryable<Order> query = Queryable.Include(o => o.Items);
    if (includes.Length > 0)
    {
      foreach (var include in includes)
        query = query.Include(include);
    }

    return await query.FirstOrDefaultAsync(o => o.Id == id, cancellationToken);
  }

  public async Task<Order?> GetTodayOrderForCustomerAsync(CustomerId customerId, DateOnly date,
      CancellationToken cancellationToken = default)
  {
    var start = date.ToDateTime(TimeOnly.MinValue, DateTimeKind.Utc);
    var end = date.ToDateTime(TimeOnly.MaxValue, DateTimeKind.Utc);

    return await Queryable
      .FirstOrDefaultAsync(o => o.CustomerId == customerId && o.OrderDate >= start && o.OrderDate <= end,
        cancellationToken);
  }

  public async Task<string> GenerateOrderNumberAsync(DateOnly date, CancellationToken cancellationToken = default)
  {
    var nextValue = await GetNextSequenceValueAsync(date, cancellationToken);
    return $"DH{date:yyyyMMdd}-{nextValue:D3}";
  }

  private async Task<int> GetNextSequenceValueAsync(DateOnly date, CancellationToken cancellationToken)
  {
    var connection = DbContext.Database.GetDbConnection();
    if (connection.State != ConnectionState.Open)
      await connection.OpenAsync(cancellationToken);

    await using var command = connection.CreateCommand();
    command.CommandText = """
            INSERT INTO "OrderDailySequences" ("Date", "CurrentValue")
            VALUES (@date, 1)
            ON CONFLICT ("Date")
            DO UPDATE SET "CurrentValue" = "OrderDailySequences"."CurrentValue" + 1
            RETURNING "CurrentValue";
            """;

    var dateParameter = command.CreateParameter();
    dateParameter.ParameterName = "date";
    dateParameter.Value = date;
    command.Parameters.Add(dateParameter);

    var result = await command.ExecuteScalarAsync(cancellationToken);
    return result == null ? 1 : Convert.ToInt32(result);
  }
}
