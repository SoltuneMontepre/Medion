namespace Payroll.API.Middleware;

public class PathPrefixMiddleware(RequestDelegate next, string prefix)
{
  public async Task InvokeAsync(HttpContext context)
  {
    var path = context.Request.Path.Value ?? string.Empty;

    if (path.StartsWith(prefix, StringComparison.OrdinalIgnoreCase))
    {
      context.Request.Path = path[prefix.Length..];

      if (string.IsNullOrEmpty(context.Request.Path.Value))
      {
        context.Request.Path = "/";
      }
    }

    await next(context);
  }
}
