using System.Linq.Expressions;
using Sale.Domain.Abstractions;
using Sale.Domain.Identifiers;

namespace Sale.Application.Abstractions;

public interface IBaseRepository<TEntity, TId>
    where TEntity : BaseEntity<TId>
    where TId : struct, IStronglyTypedId
{
    Task<TEntity?> GetByIdAsync(TId id, CancellationToken cancellationToken = default,
        params Expression<Func<TEntity, object>>[] includes);

    Task<IReadOnlyList<TEntity>> ListAsync(Expression<Func<TEntity, bool>> predicate,
        CancellationToken cancellationToken = default,
        params Expression<Func<TEntity, object>>[] includes);

    Task<IReadOnlyList<TEntity>> ListAsync(ISpecification<TEntity> specification,
        CancellationToken cancellationToken = default);

    Task AddAsync(TEntity entity, CancellationToken cancellationToken = default);
    Task UpdateAsync(TEntity entity, CancellationToken cancellationToken = default);
    Task DeleteAsync(TEntity entity, CancellationToken cancellationToken = default);

    Task<bool> AnyAsync(Expression<Func<TEntity, bool>>? predicate = null,
        CancellationToken cancellationToken = default);

    Task<long> CountAsync(Expression<Func<TEntity, bool>>? predicate = null,
        CancellationToken cancellationToken = default);
}
