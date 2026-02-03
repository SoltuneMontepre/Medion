using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;

namespace ServiceDefaults.ApiResponses;

/// <summary>
///     Extension methods for converting ApiResult to HTTP responses
/// </summary>
public static class ApiResultExtensions
{
  /// <summary>
  ///     Convert ApiResult to IResult (for minimal APIs)
  /// </summary>
  public static IResult ToResult<T>(this ApiResult<T> result)
  {
    return result.StatusCode switch
    {
      200 => Results.Ok(result),
      201 => Results.Created(string.Empty, result),
      400 => Results.BadRequest(result),
      401 => Results.Unauthorized(),
      403 => Results.Forbid(),
      404 => Results.NotFound(result),
      409 => Results.Conflict(result),
      500 => Results.StatusCode(500),
      _ => Results.StatusCode(result.StatusCode)
    };
  }

  /// <summary>
  ///     Convert ApiResult to ObjectResult (for controller-based APIs)
  /// </summary>
  public static ObjectResult ToObjectResult<T>(this ApiResult<T> result)
  {
    return new ObjectResult(result) { StatusCode = result.StatusCode };
  }

  /// <summary>
  ///     Convert non-generic ApiResult to IResult
  /// </summary>
  public static IResult ToResult(this ApiResult result)
  {
    return result.StatusCode switch
    {
      200 => Results.Ok(result),
      201 => Results.Created(string.Empty, result),
      400 => Results.BadRequest(result),
      401 => Results.Unauthorized(),
      403 => Results.Forbid(),
      404 => Results.NotFound(result),
      409 => Results.Conflict(result),
      500 => Results.StatusCode(500),
      _ => Results.StatusCode(result.StatusCode)
    };
  }

  /// <summary>
  ///     Convert non-generic ApiResult to ObjectResult
  /// </summary>
  public static ObjectResult ToObjectResult(this ApiResult result)
  {
    return new ObjectResult(result) { StatusCode = result.StatusCode };
  }

  /// <summary>
  ///     Create an IResult from data (Success wrapper)
  /// </summary>
  public static IResult AsResult<T>(this T data, string? message = null)
  {
    var result = ApiResult<T>.Success(data, message);
    return result.ToResult();
  }

  /// <summary>
  ///     Create an IResult from error
  /// </summary>
  public static IResult AsFailureResult<T>(this string message, int statusCode = 400)
  {
    var result = ApiResult<T>.Failure(message, statusCode);
    return result.ToResult();
  }
}
