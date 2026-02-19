using Microsoft.OpenApi.Models;
using Sale.API.Attributes;
using Swashbuckle.AspNetCore.SwaggerGen;

namespace Sale.API.Swagger;

/// <summary>
///     Swagger OperationFilter that adds X-Transaction-Password header parameter
///     to operations that require digital signatures
/// </summary>
public class TransactionPasswordHeaderFilter : IOperationFilter
{
    public void Apply(OpenApiOperation operation, OperationFilterContext context)
    {
        // Check if the controller action has the [RequiresTransactionPassword] attribute
        var requiresSignature = context.MethodInfo
            .GetCustomAttributes(typeof(RequiresTransactionPasswordAttribute), false).Any();

        if (requiresSignature)
        {
            operation.Parameters ??= new List<OpenApiParameter>();

            operation.Parameters.Add(new OpenApiParameter
            {
                Name = "X-Transaction-Password",
                In = ParameterLocation.Header,
                Required = true,
                Description =
                    "Transaction password for digital signature verification (required for sensitive operations)",
                Schema = new OpenApiSchema
                {
                    Type = "string",
                    Format = "password"
                }
            });
        }
    }
}
