using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;

namespace ServiceDefaults.ExceptionHandling;

/// <summary>
///     Fallback exception handler for any unhandled exceptions
///     Acts as the last resort handler if GlobalExceptionHandler doesn't handle it
/// </summary>
public class FallbackExceptionHandler : IExceptionHandler
{
  private readonly ILogger<FallbackExceptionHandler> _logger;

  public FallbackExceptionHandler(ILogger<FallbackExceptionHandler> logger)
  {
    _logger = logger;
  }

  public async ValueTask<bool> TryHandleAsync(
      HttpContext httpContext,
      Exception exception,
      CancellationToken cancellationToken)
  {
    _logger.LogError(exception, "Unhandled exception in fallback handler");

    httpContext.Response.StatusCode = StatusCodes.Status500InternalServerError;
    httpContext.Response.ContentType = "application/json";

    var problemDetails = new ProblemDetails
    {
      Type = "https://httpwg.org/specs/rfc7231.html#status.500",
      Title = "Internal Server Error",
      Status = StatusCodes.Status500InternalServerError,
      Detail = "An unexpected error occurred while processing your request.",
      Instance = httpContext.Request.Path
    };

    problemDetails.Extensions["traceId"] = httpContext.TraceIdentifier;

    await httpContext.Response.WriteAsJsonAsync(problemDetails, cancellationToken);

    return true;
  }
}
