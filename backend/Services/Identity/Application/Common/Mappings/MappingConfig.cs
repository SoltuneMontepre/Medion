using Identity.Application.Common.DTOs;
using Identity.Domain.Entities;
using Mapster;

namespace Identity.Application.Common.Mappings;

/// <summary>
///     Mapster configuration for identity-related mappings
/// </summary>
public class MappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        // User -> UserDto
        config.NewConfig<User, UserDto>()
            .Map(dest => dest.Roles, src => src.Roles.Select(ur => ur.Role!.Name).ToList());

        // RegisterUserDto -> User
#pragma warning disable CS8603 // Possible null reference return - Mapster's Ignore() method signature issue
        config.NewConfig<RegisterUserDto, User>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.CreatedAt)
            .Ignore(dest => dest.UpdatedAt)
            .Ignore(dest => dest.CreatedBy)
            .Ignore(dest => dest.UpdatedBy)
            .Ignore(dest => dest.IsDeleted)
            .Ignore(dest => dest.DeletedAt)
            .Ignore(dest => dest.DeletedBy)
            .Ignore(dest => dest.NormalizedEmail)
            .Ignore(dest => dest.NormalizedUserName)
            .Ignore(dest => dest.PasswordHash)
            .Ignore(dest => dest.Claims)
            .Ignore(dest => dest.Roles);
#pragma warning restore CS8603

        // Role -> RoleDto
        config.NewConfig<Role, RoleDto>();

        // UserClaim mapping
        config.NewConfig<UserClaim, ClaimDto>()
            .Map(dest => dest.Type, src => src.ClaimType!)
            .Map(dest => dest.Value, src => src.ClaimValue!);

        // RoleClaim mapping
        config.NewConfig<RoleClaim, ClaimDto>()
            .Map(dest => dest.Type, src => src.ClaimType)
            .Map(dest => dest.Value, src => src.ClaimValue);
    }
}

/// <summary>
///     Simple DTO for claims
/// </summary>
public class ClaimDto
{
    public string Type { get; set; } = null!;
    public string Value { get; set; } = null!;
}
