using Audit.Domain.Entities;
using Audit.Domain.Identifiers;
using Audit.Infrastructure.Persistence.Converters;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Audit.Infrastructure.Persistence.Configurations;

/// <summary>
///     Entity Framework Core configuration for the GlobalAuditLog entity.
///     Defines the database schema, relationships, constraints, and indexes for audit records.
/// </summary>
public class GlobalAuditLogConfiguration : IEntityTypeConfiguration<GlobalAuditLog>
{
  public void Configure(EntityTypeBuilder<GlobalAuditLog> builder)
  {
    // Primary key
    builder.HasKey(a => a.Id);

    // Property conversions for strongly-typed IDs
    builder.Property(a => a.Id)
        .HasConversion(new StronglyTypedIdValueConverter<GlobalAuditLogId>());

    // CorrelationId for event tracing
    builder.Property(a => a.CorrelationId)
        .IsRequired()
        .HasColumnType("uuid");

    // Aggregate metadata
    builder.Property(a => a.AggregateType)
        .IsRequired()
        .HasMaxLength(50);

    builder.Property(a => a.Action)
        .IsRequired()
        .HasMaxLength(50);

    // User tracking
    builder.Property(a => a.UserId)
        .IsRequired()
        .HasMaxLength(36); // UUID format

    // Payload storage
    builder.Property(a => a.Payload)
        .IsRequired()
        .HasColumnType("text");

    // Digital signature storage
    builder.Property(a => a.DigitalSignature)
        .IsRequired()
        .HasColumnType("text");

    // Timestamps
    builder.Property(a => a.ActionTimestamp)
        .IsRequired()
        .HasColumnType("timestamp with time zone");

    builder.Property(a => a.CreatedAt)
        .IsRequired()
        .HasColumnType("timestamp with time zone");

    builder.Property(a => a.VerifiedAt)
        .HasColumnType("timestamp with time zone");

    // Verification flag
    builder.Property(a => a.IsVerified)
        .IsRequired()
        .HasDefaultValue(false);

    // Indexes for efficient querying and compliance reporting
    builder.HasIndex(a => a.CorrelationId)
        .HasDatabaseName("IX_GlobalAuditLog_CorrelationId");

    builder.HasIndex(a => a.UserId)
        .HasDatabaseName("IX_GlobalAuditLog_UserId");

    builder.HasIndex(a => new { a.AggregateType, a.Action })
        .HasDatabaseName("IX_GlobalAuditLog_AggregateType_Action");

    builder.HasIndex(a => a.CreatedAt)
        .HasDatabaseName("IX_GlobalAuditLog_CreatedAt");

    builder.HasIndex(a => a.IsVerified)
        .HasDatabaseName("IX_GlobalAuditLog_IsVerified");

    builder.HasIndex(a => a.ActionTimestamp)
        .HasDatabaseName("IX_GlobalAuditLog_ActionTimestamp");

    // Table name
    builder.ToTable("GlobalAuditLogs");
  }
}
