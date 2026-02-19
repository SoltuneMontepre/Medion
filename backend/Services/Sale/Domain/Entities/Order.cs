using Sale.Domain.Abstractions;
using Sale.Domain.Identifiers;
using Sale.Domain.Identifiers.Id;

namespace Sale.Domain.Entities;

public sealed class Order : BaseEntity<OrderId>
{
    private readonly List<OrderItem> items = [];

    public Order()
    {
        Id = OrderId.New();
    }

    public string OrderNumber { get; private set; } = null!;
    public CustomerId CustomerId { get; private set; }
    public DateTime OrderDate { get; private set; }
    public OrderStatus Status { get; private set; } = OrderStatus.Draft;
    public UserId SalesStaffId { get; private set; }
    public DateTime? SignedAt { get; private set; }
    public UserId? SignedBy { get; private set; }
    public byte[]? Signature { get; private set; }
    public string? SignaturePublicKey { get; private set; }

    public IReadOnlyCollection<OrderItem> Items => items;

    public void Initialize(string orderNumber, CustomerId customerId, UserId salesStaffId, DateTime orderDate)
    {
        OrderNumber = orderNumber;
        CustomerId = customerId;
        SalesStaffId = salesStaffId;
        OrderDate = orderDate;
        Status = OrderStatus.Draft;
    }

    public void AddItem(OrderItem item)
    {
        items.Add(item);
    }

    public void MarkSigned(UserId signedBy, byte[] signature, string publicKey, DateTime signedAt)
    {
        SignedBy = signedBy;
        SignedAt = signedAt;
        Signature = signature;
        SignaturePublicKey = publicKey;
        Status = OrderStatus.Signed;
    }
}
