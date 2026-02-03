using Microsoft.AspNetCore.Mvc;
using ServiceDefaults.ApiResponses;

namespace ServiceDefaults.ApiResponses;

/// <summary>
///     Base controller class with ApiResult support
///     All controllers should inherit from this class
/// </summary>
public abstract class ApiControllerBase : ControllerBase
{
  /// <summary>
  ///     Return a successful response with data
  /// </summary>
  protected OkObjectResult Ok<T>(T data, string? message = null)
  {
    var result = ApiResult<T>.Success(data, message);
    return base.Ok(result);
  }

  /// <summary>
  ///     Return a created response (201)
  /// </summary>
  protected CreatedAtActionResult Created<T>(string actionName, object routeValues, T data,
      string? message = null)
  {
    var result = ApiResult<T>.Created(data, message);
    return base.CreatedAtAction(actionName, routeValues, result);
  }

  /// <summary>
  ///     Return a bad request response with validation errors
  /// </summary>
  protected BadRequestObjectResult BadRequest<T>(string message,
      Dictionary<string, string[]>? errors = null)
  {
    var result = ApiResult<T>.ValidationError(errors ?? new Dictionary<string, string[]>(),
        message);
    return base.BadRequest(result);
  }

  /// <summary>
  ///     Return an unauthorized response
  /// </summary>
  protected ObjectResult Unauthorized<T>(string message = "Unauthorized access")
  {
    var result = ApiResult<T>.Unauthorized(message);
    return new ObjectResult(result) { StatusCode = 401 };
  }

  /// <summary>
  ///     Return a not found response
  /// </summary>
  protected NotFoundObjectResult NotFound<T>(string message = "Resource not found")
  {
    var result = ApiResult<T>.NotFound(message);
    return base.NotFound(result);
  }

  /// <summary>
  ///     Return a conflict response (409)
  /// </summary>
  protected ConflictObjectResult Conflict<T>(string message)
  {
    var result = ApiResult<T>.Failure(message, 409);
    return base.Conflict(result);
  }

  /// <summary>
  ///     Return a generic response with custom status code
  /// </summary>
  protected ObjectResult ApiResponse<T>(ApiResult<T> result)
  {
    return new ObjectResult(result) { StatusCode = result.StatusCode };
  }
}
