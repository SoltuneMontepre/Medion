using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Sale.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class CleanupModelAfterEventDrivenRefactoring : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            // Use raw SQL to safely drop the table only if it exists
            // This handles the case where the table was never created (e.g., in new environments)
            migrationBuilder.Sql("DROP TABLE IF EXISTS \"CustomerSignatures\" CASCADE;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "CustomerSignatures",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    CustomerId = table.Column<Guid>(type: "uuid", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    DeletedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    DeletedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false),
                    IsVerified = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    Signature = table.Column<string>(type: "text", nullable: false),
                    SignedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    SignedByUserId = table.Column<Guid>(type: "uuid", nullable: false),
                    SignedPayload = table.Column<string>(type: "text", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    VerifiedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CustomerSignatures", x => x.Id);
                    table.ForeignKey(
                        name: "FK_CustomerSignatures_Customers_CustomerId",
                        column: x => x.CustomerId,
                        principalTable: "Customers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSignature_CustomerId",
                table: "CustomerSignatures",
                column: "CustomerId",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSignature_IsVerified",
                table: "CustomerSignatures",
                column: "IsVerified");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSignature_SignedAt",
                table: "CustomerSignatures",
                column: "SignedAt");

            migrationBuilder.CreateIndex(
                name: "IX_CustomerSignature_SignedByUserId",
                table: "CustomerSignatures",
                column: "SignedByUserId");
        }
    }
}
