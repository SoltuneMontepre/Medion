using Mapster;
using Sale.Application.Common.DTOs;
using Sale.Domain.Entities;

namespace Sale.Application.Common.Mappings;

/// <summary>
///     Mapster configuration for sale-related mappings
/// </summary>
public class MappingConfig : IRegister
{
    public void Register(TypeAdapterConfig config)
    {
        // Customer -> CustomerDto (default mapping works)
        config.NewConfig<Customer, CustomerDto>();

        // Product -> ProductDto
        config.NewConfig<Product, ProductDto>();

        // Order -> OrderDto
        config.NewConfig<Order, OrderDto>();

        // OrderItem -> OrderItemDto
        config.NewConfig<OrderItem, OrderItemDto>();

#pragma warning disable CS8603 // Possible null reference return - Mapster's Ignore() method signature issue
        // CreateCustomerDto -> Customer
        config.NewConfig<CreateCustomerDto, Customer>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.CreatedAt)
            .Ignore(dest => dest.UpdatedAt)
            .Ignore(dest => dest.CreatedBy)
            .Ignore(dest => dest.UpdatedBy)
            .Ignore(dest => dest.IsDeleted)
            .Ignore(dest => dest.DeletedAt)
            .Ignore(dest => dest.DeletedBy);

        // UpdateCustomerDto -> Customer (partial update)
        config.NewConfig<UpdateCustomerDto, Customer>()
            .Ignore(dest => dest.Id)
            .Ignore(dest => dest.CreatedAt)
            .Ignore(dest => dest.UpdatedAt)
            .Ignore(dest => dest.CreatedBy)
            .Ignore(dest => dest.UpdatedBy)
            .Ignore(dest => dest.IsDeleted)
            .Ignore(dest => dest.DeletedAt)
            .Ignore(dest => dest.DeletedBy);
#pragma warning restore CS8603
    }
}
