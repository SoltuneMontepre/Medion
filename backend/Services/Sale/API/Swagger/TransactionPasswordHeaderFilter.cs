using Microsoft.AspNetCore.Mvc.Controllers;
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
        // Get the action method (ControllerActionDescriptor is more reliable than context.MethodInfo for controllers)
        var methodInfo = context.ApiDescription.ActionDescriptor is ControllerActionDescriptor controllerAction
            ? controllerAction.MethodInfo
            : context.MethodInfo;

        var requiresSignature = methodInfo?
            .GetCustomAttributes(typeof(RequiresTransactionPasswordAttribute), false).Any() ?? false;

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
