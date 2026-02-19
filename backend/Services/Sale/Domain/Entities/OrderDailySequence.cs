namespace Sale.Domain.Entities;

public sealed class OrderDailySequence
{
    public DateOnly Date { get; set; }
    public int CurrentValue { get; set; }
}
