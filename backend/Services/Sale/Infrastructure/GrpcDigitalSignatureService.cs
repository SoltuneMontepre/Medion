using Grpc.Core;
using Medion.Security.Contracts;
using Sale.Application.Abstractions;
using Sale.Domain.Identifiers;

namespace Sale.Infrastructure;

public sealed class GrpcDigitalSignatureService(SignatureService.SignatureServiceClient client) : IDigitalSignatureService
{
    public async Task<bool> VerifyPinAsync(UserId userId, string pin, CancellationToken cancellationToken = default)
    {
        try
        {
            var response = await client.CheckPinAsync(new PinRequest
            {
                UserId = userId.ToString(),
                Pin = pin
            }, cancellationToken: cancellationToken);

            return response.IsValid;
        }
        catch (RpcException rpcException)
        {
            throw MapException(rpcException);
        }
    }

    public async Task<DigitalSignatureResult> SignAsync(UserId userId, string payload, string pin,
        CancellationToken cancellationToken = default)
    {
        try
        {
            var response = await client.VerifyAndSignAsync(new SignRequest
            {
                UserId = userId.ToString(),
                Payload = payload,
                Pin = pin
            }, cancellationToken: cancellationToken);

            return new DigitalSignatureResult(response.Signature.ToByteArray(), response.PublicKey);
        }
        catch (RpcException rpcException)
        {
            throw MapException(rpcException);
        }
    }

    private static DigitalSignatureException MapException(RpcException rpcException)
    {
        return rpcException.StatusCode switch
        {
            StatusCode.Unauthenticated => new DigitalSignatureException(
                DigitalSignatureFailure.InvalidPin,
                rpcException.Status.Detail,
                rpcException),
            StatusCode.InvalidArgument => new DigitalSignatureException(
                DigitalSignatureFailure.InvalidArgument,
                rpcException.Status.Detail,
                rpcException),
            StatusCode.Unavailable => new DigitalSignatureException(
                DigitalSignatureFailure.Unavailable,
                rpcException.Status.Detail,
                rpcException),
            _ => new DigitalSignatureException(
                DigitalSignatureFailure.Internal,
                rpcException.Status.Detail,
                rpcException)
        };
    }
}
