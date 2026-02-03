using System.Collections.Generic;

namespace ServiceDefaults.ApiResponses;

/// <summary>
///     Standard API Response Envelope (RFC 7807 Problem Details compliant)
///     Wraps all API responses in a consistent format
/// </summary>
/// <typeparam name="T">The data type being returned</typeparam>
public class ApiResult<T>
{
  public bool IsSuccess { get; set; }
  public T? Data { get; set; }
  public string? Message { get; set; }
  public int StatusCode { get; set; }
  public Dictionary<string, string[]>? Errors { get; set; }

  /// <summary>
  ///     Create a successful API response
  /// </summary>
  public static ApiResult<T> Success(T? data, string? message = null, int statusCode = 200)
  {
    return new ApiResult<T>
    {
      IsSuccess = true,
      Data = data,
      Message = message ?? "Operation completed successfully",
      StatusCode = statusCode
    };
  }

  /// <summary>
  ///     Create a successful API response with custom status code
  /// </summary>
  public static ApiResult<T> Created(T? data, string? message = null)
  {
    return Success(data, message ?? "Resource created successfully", 201);
  }

  /// <summary>
  ///     Create a failure API response
  /// </summary>
  public static ApiResult<T> Failure(string message, int statusCode = 400,
      Dictionary<string, string[]>? errors = null)
  {
    return new ApiResult<T>
    {
      IsSuccess = false,
      Data = default,
      Message = message,
      StatusCode = statusCode,
      Errors = errors
    };
  }

  /// <summary>
  ///     Create an unauthorized response
  /// </summary>
  public static ApiResult<T> Unauthorized(string message = "Unauthorized access")
  {
    return Failure(message, 401);
  }

  /// <summary>
  ///     Create a not found response
  /// </summary>
  public static ApiResult<T> NotFound(string message = "Resource not found")
  {
    return Failure(message, 404);
  }

  /// <summary>
  ///     Create an internal server error response
  /// </summary>
  public static ApiResult<T> InternalServerError(string message = "An internal server error occurred")
  {
    return Failure(message, 500);
  }

  /// <summary>
  ///     Create a validation error response
  /// </summary>
  public static ApiResult<T> ValidationError(Dictionary<string, string[]> errors,
      string message = "Validation failed")
  {
    return new ApiResult<T>
    {
      IsSuccess = false,
      Data = default,
      Message = message,
      StatusCode = 400,
      Errors = errors
    };
  }
}

/// <summary>
///     Non-generic API result for void operations
/// </summary>
public class ApiResult
{
  public bool IsSuccess { get; set; }
  public string? Message { get; set; }
  public int StatusCode { get; set; }
  public Dictionary<string, string[]>? Errors { get; set; }

  public static ApiResult Success(string? message = null, int statusCode = 200)
  {
    return new ApiResult
    {
      IsSuccess = true,
      Message = message ?? "Operation completed successfully",
      StatusCode = statusCode
    };
  }

  public static ApiResult Failure(string message, int statusCode = 400,
      Dictionary<string, string[]>? errors = null)
  {
    return new ApiResult
    {
      IsSuccess = false,
      Message = message,
      StatusCode = statusCode,
      Errors = errors
    };
  }
}
