using System.Linq.Expressions;
using Microsoft.EntityFrameworkCore;
using Sale.Application.Abstractions;
using Sale.Domain.Abstractions;
using Sale.Domain.Identifiers;
using Sale.Infrastructure.Data;

namespace Sale.Infrastructure.Persistence;

public abstract class BaseRepository<TEntity, TId>(SaleDbContext dbContext) : IBaseRepository<TEntity, TId>
    where TEntity : BaseEntity<TId>
    where TId : struct, IStronglyTypedId
{
    protected SaleDbContext DbContext { get; } = dbContext;
    protected DbSet<TEntity> Entities => DbContext.Set<TEntity>();
    protected virtual bool ApplySoftDeleteFilter => true;

    protected IQueryable<TEntity> Queryable
        => ApplySoftDeleteFilter ? Entities.Where(entity => !entity.IsDeleted) : Entities;

    public virtual async Task<TEntity?> GetByIdAsync(TId id, CancellationToken cancellationToken = default,
        params Expression<Func<TEntity, object>>[] includes)
    {
        var query = ApplyIncludes(Queryable, includes);
        return await query.FirstOrDefaultAsync(entity => entity.Id.Equals(id),
            cancellationToken);
    }

    public virtual async Task<IReadOnlyList<TEntity>> ListAsync(Expression<Func<TEntity, bool>> predicate,
        CancellationToken cancellationToken = default, params Expression<Func<TEntity, object>>[] includes)
    {
        var query = ApplyIncludes(Queryable.Where(predicate), includes);
        return await query.ToListAsync(cancellationToken);
    }

    public virtual async Task<IReadOnlyList<TEntity>> ListAsync(ISpecification<TEntity> specification,
        CancellationToken cancellationToken = default)
    {
        var query = ApplySpecification(specification);
        return await query.ToListAsync(cancellationToken);
    }

    public virtual async Task AddAsync(TEntity entity, CancellationToken cancellationToken = default)
    {
        await Entities.AddAsync(entity, cancellationToken);
        await DbContext.SaveChangesAsync(cancellationToken);
    }

    public virtual async Task UpdateAsync(TEntity entity, CancellationToken cancellationToken = default)
    {
        if (entity is IAuditable auditable)
            auditable.UpdatedAt = DateTime.UtcNow;

        Entities.Update(entity);
        await DbContext.SaveChangesAsync(cancellationToken);
    }

    public virtual async Task DeleteAsync(TEntity entity, CancellationToken cancellationToken = default)
    {
        entity.IsDeleted = true;
        entity.DeletedAt = DateTime.UtcNow;
        await UpdateAsync(entity, cancellationToken);
    }

    public virtual Task<bool> AnyAsync(Expression<Func<TEntity, bool>>? predicate = null,
        CancellationToken cancellationToken = default)
    {
        return predicate == null
            ? Queryable.AnyAsync(cancellationToken)
            : Queryable.AnyAsync(predicate, cancellationToken);
    }

    public virtual Task<long> CountAsync(Expression<Func<TEntity, bool>>? predicate = null,
        CancellationToken cancellationToken = default)
    {
        return predicate == null
            ? Queryable.LongCountAsync(cancellationToken)
            : Queryable.LongCountAsync(predicate, cancellationToken);
    }

    private static IQueryable<TEntity> ApplyIncludes(IQueryable<TEntity> query,
        params Expression<Func<TEntity, object>>[] includes)
    {
        if (includes.Length == 0)
            return query;

        foreach (var include in includes)
            query = query.Include(include);

        return query;
    }

    private static IQueryable<TEntity> ApplyIncludes(IQueryable<TEntity> query,
        IEnumerable<Expression<Func<TEntity, object>>> includes)
    {
        foreach (var include in includes)
            query = query.Include(include);

        return query;
    }

    private IQueryable<TEntity> ApplySpecification(ISpecification<TEntity> specification)
    {
        var query = Queryable;

        if (specification.Criteria != null)
            query = query.Where(specification.Criteria);

        query = ApplyIncludes(query, specification.Includes);

        if (specification.OrderBy != null)
            query = query.OrderBy(specification.OrderBy);
        else if (specification.OrderByDescending != null)
            query = query.OrderByDescending(specification.OrderByDescending);

        if (specification.Skip.HasValue)
            query = query.Skip(specification.Skip.Value);

        if (specification.Take.HasValue)
            query = query.Take(specification.Take.Value);

        return query;
    }
}
