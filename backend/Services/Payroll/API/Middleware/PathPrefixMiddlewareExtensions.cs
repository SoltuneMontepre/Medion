namespace Payroll.API.Middleware;

public static class PathPrefixMiddlewareExtensions
{
    public static IApplicationBuilder UsePathPrefixRewrite(this IApplicationBuilder app, string prefix)
    {
        return app.UseMiddleware<PathPrefixMiddleware>(prefix);
    }
}
