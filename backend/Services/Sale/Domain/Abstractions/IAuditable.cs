using Sale.Domain.Identifiers;

namespace Sale.Domain.Abstractions;

public interface IAuditable
{
    DateTime CreatedAt { get; set; }
    DateTime? UpdatedAt { get; set; }
    UserId? CreatedBy { get; set; }
    UserId? UpdatedBy { get; set; }
}
