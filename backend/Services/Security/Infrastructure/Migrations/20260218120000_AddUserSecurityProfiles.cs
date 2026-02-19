using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Security.Infrastructure.Migrations
{
  /// <inheritdoc />
  public partial class AddUserSecurityProfiles : Migration
  {
    /// <inheritdoc />
    protected override void Up(MigrationBuilder migrationBuilder)
    {
      migrationBuilder.CreateTable(
          name: "UserSecurityProfiles",
          columns: table => new
          {
            UserId = table.Column<Guid>(type: "uuid", nullable: false),
            TransactionPinHash = table.Column<string>(type: "character varying(200)", maxLength: 200, nullable: false),
            CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
            UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true)
          },
          constraints: table =>
          {
            table.PrimaryKey("PK_UserSecurityProfiles", x => x.UserId);
          });

      migrationBuilder.CreateIndex(
          name: "IX_UserSecurityProfiles_UserId",
          table: "UserSecurityProfiles",
          column: "UserId",
          unique: true);
    }

    /// <inheritdoc />
    protected override void Down(MigrationBuilder migrationBuilder)
    {
      migrationBuilder.DropTable(
          name: "UserSecurityProfiles");
    }
  }
}
