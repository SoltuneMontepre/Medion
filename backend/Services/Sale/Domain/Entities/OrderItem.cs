using Sale.Domain.Abstractions;
using Sale.Domain.Identifiers.Id;

namespace Sale.Domain.Entities;

public sealed class OrderItem : BaseEntity<OrderItemId>
{
    public OrderItem()
    {
        Id = OrderItemId.New();
    }

    public OrderId OrderId { get; private set; }
    public ProductId ProductId { get; private set; }
    public string ProductCode { get; private set; } = null!;
    public string ProductName { get; private set; } = null!;
    public int Quantity { get; private set; }

    public void Initialize(OrderId orderId, ProductId productId, string productCode, string productName, int quantity)
    {
        OrderId = orderId;
        ProductId = productId;
        ProductCode = productCode;
        ProductName = productName;
        Quantity = quantity;
    }
}
