using Identity.Domain.Identifiers;

namespace Identity.Domain.Abstractions;

public interface IAuditable
{
    DateTime CreatedAt { get; set; }
    DateTime? UpdatedAt { get; set; }
    IdentityId? CreatedBy { get; set; }
    IdentityId? UpdatedBy { get; set; }
}
