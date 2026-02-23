using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace Sale.Infrastructure.Migrations
{
    /// <summary>
    ///     Enables pg_trgm and creates GIN trigram indexes on Customer search columns.
    ///     Enables efficient ILIKE '%term%' (leading wildcard) search without full table scan.
    /// </summary>
    public partial class AddCustomerSearchGinTrigramIndexes : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql("CREATE EXTENSION IF NOT EXISTS pg_trgm;");

            migrationBuilder.Sql(@"
                CREATE INDEX IF NOT EXISTS ""IX_Customers_Code_gin_trgm""
                ON ""Customers"" USING gin (""Code"" gin_trgm_ops);
            ");
            migrationBuilder.Sql(@"
                CREATE INDEX IF NOT EXISTS ""IX_Customers_FirstName_gin_trgm""
                ON ""Customers"" USING gin (""FirstName"" gin_trgm_ops);
            ");
            migrationBuilder.Sql(@"
                CREATE INDEX IF NOT EXISTS ""IX_Customers_LastName_gin_trgm""
                ON ""Customers"" USING gin (""LastName"" gin_trgm_ops);
            ");
            migrationBuilder.Sql(@"
                CREATE INDEX IF NOT EXISTS ""IX_Customers_PhoneNumber_gin_trgm""
                ON ""Customers"" USING gin (""PhoneNumber"" gin_trgm_ops);
            ");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(@"DROP INDEX IF EXISTS ""IX_Customers_PhoneNumber_gin_trgm"";");
            migrationBuilder.Sql(@"DROP INDEX IF EXISTS ""IX_Customers_LastName_gin_trgm"";");
            migrationBuilder.Sql(@"DROP INDEX IF EXISTS ""IX_Customers_FirstName_gin_trgm"";");
            migrationBuilder.Sql(@"DROP INDEX IF EXISTS ""IX_Customers_Code_gin_trgm"";");
            // Do not drop pg_trgm extension; other objects might depend on it.
        }
    }
}
