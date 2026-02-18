using Security.Application.Features.Signature.Commands;
using Security.Domain.Entities;
using Security.Infrastructure.Data;

namespace Security.Infrastructure.Persistence.Repositories;

public class SignatureRepository(SecurityDbContext dbContext) : ISignatureRepository
{
    public async Task AddAsync(TransactionSignature signature, CancellationToken cancellationToken)
    {
        await dbContext.TransactionSignatures.AddAsync(signature, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
    }
}
