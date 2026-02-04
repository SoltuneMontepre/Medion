using FluentValidation;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;

namespace ServiceDefaults.ExceptionHandling;

/// <summary>
///     Global exception handler implementing IExceptionHandler
///     Handles all exceptions across services with RFC 7807 Problem Details format
/// </summary>
public class GlobalExceptionHandler(ILogger<GlobalExceptionHandler> logger) : IExceptionHandler
{
    public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception,
        CancellationToken cancellationToken)
    {
        logger.LogError(exception, "An unhandled exception occurred");

        httpContext.Response.ContentType = "application/json";

        var problemDetails = new ProblemDetails();

        switch (exception)
        {
            case ValidationException validationException:
                await HandleValidationException(httpContext, validationException, problemDetails, cancellationToken);
                break;

            case UnauthorizedAccessException unauthorizedException:
                await HandleUnauthorizedException(httpContext, unauthorizedException, problemDetails,
                    cancellationToken);
                break;

            case ArgumentException argumentException:
                await HandleArgumentException(httpContext, argumentException, problemDetails, cancellationToken);
                break;

            default:
                await HandleGenericException(httpContext, exception, problemDetails, cancellationToken);
                break;
        }

        return true;
    }

    private static Task HandleValidationException(HttpContext httpContext, ValidationException exception,
        ProblemDetails problemDetails, CancellationToken cancellationToken)
    {
        httpContext.Response.StatusCode = StatusCodes.Status400BadRequest;

        problemDetails.Type = "https://tools.ietf.org/html/rfc7231#section-6.5.1";
        problemDetails.Title = "One or more validation errors occurred.";
        problemDetails.Status = StatusCodes.Status400BadRequest;
        problemDetails.Detail = "See errors property for details.";
        problemDetails.Instance = httpContext.Request.Path;

        var errors = exception.Errors
            .GroupBy(x => x.PropertyName)
            .ToDictionary(g => g.Key, g => g.Select(x => x.ErrorMessage).ToArray());

        problemDetails.Extensions["errors"] = errors;
        problemDetails.Extensions["traceId"] = httpContext.TraceIdentifier;

        return httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);
    }

    private static Task HandleUnauthorizedException(HttpContext httpContext, UnauthorizedAccessException exception,
        ProblemDetails problemDetails, CancellationToken cancellationToken)
    {
        httpContext.Response.StatusCode = StatusCodes.Status401Unauthorized;

        problemDetails.Type = "https://tools.ietf.org/html/rfc7235#section-3.1";
        problemDetails.Title = "Unauthorized";
        problemDetails.Status = StatusCodes.Status401Unauthorized;
        problemDetails.Detail = exception.Message;
        problemDetails.Instance = httpContext.Request.Path;
        problemDetails.Extensions["traceId"] = httpContext.TraceIdentifier;

        return httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);
    }

    private static Task HandleArgumentException(HttpContext httpContext, ArgumentException exception,
        ProblemDetails problemDetails, CancellationToken cancellationToken)
    {
        httpContext.Response.StatusCode = StatusCodes.Status400BadRequest;

        problemDetails.Type = "https://tools.ietf.org/html/rfc7231#section-6.5.1";
        problemDetails.Title = "Bad Request";
        problemDetails.Status = StatusCodes.Status400BadRequest;
        problemDetails.Detail = exception.Message;
        problemDetails.Instance = httpContext.Request.Path;
        problemDetails.Extensions["traceId"] = httpContext.TraceIdentifier;

        return httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);
    }

    private Task HandleGenericException(HttpContext httpContext, Exception exception, ProblemDetails problemDetails,
        CancellationToken cancellationToken)
    {
        httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;

        problemDetails.Type = "https://tools.ietf.org/html/rfc7231#section-6.6.1";
        problemDetails.Title = "Internal Server Error";
        problemDetails.Status = StatusCodes.Status500InternalServerError;
        problemDetails.Detail = "An internal server error occurred. Please try again later.";
        problemDetails.Instance = httpContext.Request.Path;
        problemDetails.Extensions["traceId"] = httpContext.TraceIdentifier;

        // Only include exception details in development
        if (!string.IsNullOrEmpty(Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT")) &&
            Environment.GetEnvironmentVariable("ASPNETCORE_ENVIRONMENT") == "Development")
        {
            problemDetails.Extensions["exceptionMessage"] = exception.Message;
            problemDetails.Extensions["exceptionType"] = exception.GetType().Name;
        }

        return httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);
    }
}
