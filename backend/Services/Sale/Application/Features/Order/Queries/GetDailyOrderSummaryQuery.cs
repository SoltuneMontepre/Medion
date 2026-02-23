using Sale.Application.Common.DTOs;

namespace Sale.Application.Features.Order.Queries;

/// <summary>
///     Query to get aggregated daily order summary by product (tổng hợp đơn đặt hàng trong ngày).
///     Date format: yyyy-MM-dd (e.g. 2026-02-22). If null, uses today (UTC).
/// </summary>
public sealed class GetDailyOrderSummaryQuery : IRequest<IReadOnlyList<DailyOrderSummaryItemDto>>
{
    public GetDailyOrderSummaryQuery(DateOnly? date = null)
    {
        Date = date ?? DateOnly.FromDateTime(DateTime.UtcNow);
    }

    public DateOnly Date { get; }
}
