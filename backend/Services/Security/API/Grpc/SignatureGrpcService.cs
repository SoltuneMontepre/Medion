using Grpc.Core;
using Medion.Security.Contracts;
using Sale.Domain.Identifiers;
using Security.Application.Abstractions;

namespace Security.API.Grpc;

public sealed class SignatureGrpcService(ISignatureService signatureService) : SignatureService.SignatureServiceBase
{
  public override async Task<SignResponse> VerifyAndSign(SignRequest request, ServerCallContext context)
  {
    if (!TryParseUserId(request.UserId, out var userId))
      throw new RpcException(new Status(StatusCode.InvalidArgument, "Invalid userId format."));

    if (string.IsNullOrWhiteSpace(request.Payload))
      throw new RpcException(new Status(StatusCode.InvalidArgument, "Payload is required."));

    if (string.IsNullOrWhiteSpace(request.Pin))
      throw new RpcException(new Status(StatusCode.InvalidArgument, "PIN is required."));

    try
    {
      var result = await signatureService.VerifyAndSignAsync(userId, request.Pin, request.Payload,
          context.CancellationToken);

      return new SignResponse
      {
        Signature = Google.Protobuf.ByteString.CopyFrom(result.Signature),
        PublicKey = result.PublicKey,
        IsSuccess = true
      };
    }
    catch (UnauthorizedAccessException ex)
    {
      throw new RpcException(new Status(StatusCode.Unauthenticated, ex.Message));
    }
    catch (InvalidOperationException ex)
    {
      throw new RpcException(new Status(StatusCode.InvalidArgument, ex.Message));
    }
    catch (Exception ex)
    {
      throw new RpcException(new Status(StatusCode.Internal, ex.Message));
    }
  }

  public override async Task<PinResponse> CheckPin(PinRequest request, ServerCallContext context)
  {
    if (!TryParseUserId(request.UserId, out var userId))
      throw new RpcException(new Status(StatusCode.InvalidArgument, "Invalid userId format."));

    if (string.IsNullOrWhiteSpace(request.Pin))
      throw new RpcException(new Status(StatusCode.InvalidArgument, "PIN is required."));

    var isValid = await signatureService.CheckPinAsync(userId, request.Pin, context.CancellationToken);
    return new PinResponse { IsValid = isValid };
  }

  private static bool TryParseUserId(string value, out UserId userId)
  {
    userId = UserId.Empty;
    if (string.IsNullOrWhiteSpace(value))
      return false;

    if (!Guid.TryParse(value, out var guid))
      return false;

    userId = new UserId(guid);
    return true;
  }
}
