namespace Sale.Domain.Entities;

public sealed class Order(string id, string customerId)
{
    public string Id { get; init; } = id;
    public string CustomerId { get; init; } = customerId;
    public DateTime CreatedAtUtc { get; init; } = DateTime.UtcNow;
    public string Status { get; private set; } = "Pending";
    public List<OrderItem> Items { get; init; } = [];

    public decimal Total => Items.Aggregate(0m, (acc, i) => acc + i.UnitPrice * i.Quantity);

    public void MarkSubmitted()
    {
        Status = "Submitted";
    }
}

public sealed class OrderItem(string sku, int quantity, decimal unitPrice)
{
    public string Sku { get; init; } = sku;
    public int Quantity { get; init; } = quantity;
    public decimal UnitPrice { get; init; } = unitPrice;
}
