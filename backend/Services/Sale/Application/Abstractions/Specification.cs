using System.Linq.Expressions;

namespace Sale.Application.Abstractions;

public abstract class Specification<TEntity> : ISpecification<TEntity>
{
    private readonly List<Expression<Func<TEntity, object>>> includes = [];

    public Expression<Func<TEntity, bool>>? Criteria { get; protected set; }
    public IReadOnlyCollection<Expression<Func<TEntity, object>>> Includes => includes;
    public Expression<Func<TEntity, object>>? OrderBy { get; protected set; }
    public Expression<Func<TEntity, object>>? OrderByDescending { get; protected set; }
    public int? Skip { get; protected set; }
    public int? Take { get; protected set; }

    protected void AddInclude(Expression<Func<TEntity, object>> include)
    {
        includes.Add(include);
    }

    protected void ApplyOrderBy(Expression<Func<TEntity, object>> orderBy)
    {
        OrderBy = orderBy;
    }

    protected void ApplyOrderByDescending(Expression<Func<TEntity, object>> orderByDescending)
    {
        OrderByDescending = orderByDescending;
    }

    protected void ApplyPaging(int skip, int take)
    {
        Skip = skip;
        Take = take;
    }
}
