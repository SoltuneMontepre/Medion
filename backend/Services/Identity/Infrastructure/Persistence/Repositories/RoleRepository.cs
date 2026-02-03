using Identity.Domain.Entities;
using Identity.Domain.Repositories;
using Microsoft.EntityFrameworkCore;

namespace Identity.Infrastructure.Persistence;

/// <summary>
///     Repository implementation for Role entity
/// </summary>
public class RoleRepository(IdentityDbContext dbContext) : IRoleRepository
{
    public async Task<Role?> GetByIdAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await dbContext.Roles
            .Include(r => r.UserRoles)
            .Include(r => r.Claims)
            .FirstOrDefaultAsync(r => r.Id == id && !r.IsDeleted, cancellationToken);
    }

    public async Task<Role?> GetByNameAsync(string name, CancellationToken cancellationToken = default)
    {
        return await dbContext.Roles
            .Include(r => r.UserRoles)
            .Include(r => r.Claims)
            .FirstOrDefaultAsync(r => r.Name == name && !r.IsDeleted, cancellationToken);
    }

    public async Task<Role?> GetByNormalizedNameAsync(string normalizedName,
        CancellationToken cancellationToken = default)
    {
        return await dbContext.Roles
            .Include(r => r.UserRoles)
            .Include(r => r.Claims)
            .FirstOrDefaultAsync(r => r.NormalizedName == normalizedName && !r.IsDeleted, cancellationToken);
    }

    public async Task<IEnumerable<Role>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        return await dbContext.Roles
            .Include(r => r.UserRoles)
            .Include(r => r.Claims)
            .Where(r => !r.IsDeleted)
            .ToListAsync(cancellationToken);
    }

    public async Task<IEnumerable<Role>> GetUserRolesAsync(Guid userId, CancellationToken cancellationToken = default)
    {
        return await dbContext.Roles
            .Include(r => r.UserRoles)
            .Include(r => r.Claims)
            .Where(r => r.UserRoles.Any(ur => ur.UserId == userId) && !r.IsDeleted)
            .ToListAsync(cancellationToken);
    }

    public async Task AddAsync(Role role, CancellationToken cancellationToken = default)
    {
        await dbContext.Roles.AddAsync(role, cancellationToken);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task UpdateAsync(Role role, CancellationToken cancellationToken = default)
    {
        role.UpdatedAt = DateTime.UtcNow;
        dbContext.Roles.Update(role);
        await dbContext.SaveChangesAsync(cancellationToken);
    }

    public async Task DeleteAsync(Guid id, CancellationToken cancellationToken = default)
    {
        var role = await GetByIdAsync(id, cancellationToken);
        if (role != null)
        {
            role.IsDeleted = true;
            role.DeletedAt = DateTime.UtcNow;
            await UpdateAsync(role, cancellationToken);
        }
    }

    public async Task<bool> ExistsAsync(Guid id, CancellationToken cancellationToken = default)
    {
        return await dbContext.Roles.AnyAsync(r => r.Id == id && !r.IsDeleted, cancellationToken);
    }

    public async Task<bool> ExistsByNameAsync(string name, CancellationToken cancellationToken = default)
    {
        return await dbContext.Roles.AnyAsync(r => r.Name == name && !r.IsDeleted, cancellationToken);
    }
}
