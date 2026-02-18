using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Security.Infrastructure.Migrations
{
    /// <inheritdoc />
    public partial class AddTransactionSignatures : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "TransactionSignatures",
                columns: table => new
                {
                    Id = table.Column<Guid>(type: "uuid", nullable: false),
                    Payload = table.Column<string>(type: "character varying(10000)", maxLength: 10000, nullable: false),
                    SignatureHash = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
                    OperationType = table.Column<string>(type: "character varying(100)", maxLength: 100, nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    CreatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    UpdatedBy = table.Column<Guid>(type: "uuid", nullable: true),
                    IsDeleted = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
                    DeletedAt = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
                    DeletedBy = table.Column<Guid>(type: "uuid", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TransactionSignatures", x => x.Id);
                });

            migrationBuilder.Sql(
                "CREATE TABLE IF NOT EXISTS \"UserDigitalSignatures\" (" +
                "\"UserId\" uuid NOT NULL, " +
                "\"PinHash\" bytea NOT NULL, " +
                "\"PinSalt\" bytea NOT NULL, " +
                "\"PublicKey\" character varying(500) NOT NULL, " +
                "\"CreatedAt\" timestamp with time zone NOT NULL, " +
                "\"UpdatedAt\" timestamp with time zone, " +
                "CONSTRAINT \"PK_UserDigitalSignatures\" PRIMARY KEY (\"UserId\")" +
                ");");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionSignatures_CreatedAt",
                table: "TransactionSignatures",
                column: "CreatedAt");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionSignatures_CreatedBy",
                table: "TransactionSignatures",
                column: "CreatedBy");

            migrationBuilder.CreateIndex(
                name: "IX_TransactionSignatures_OperationType",
                table: "TransactionSignatures",
                column: "OperationType");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "TransactionSignatures");

            migrationBuilder.Sql("DROP TABLE IF EXISTS \"UserDigitalSignatures\"");
        }
    }
}
