using Audit.Application.Abstractions;
using Audit.Domain.Identifiers;
using Grpc.Core;
using Medion.Audit.Contracts;
using Security.Application.Abstractions;

namespace Audit.API.Grpc;

/// <summary>
///     gRPC service for audit operations.
///     Provides capabilities for querying audit logs and verifying digital signatures.
///     Called by other services (e.g., Admin Dashboard) to verify audit entries and check compliance.
/// </summary>
public class AuditGrpcService(
    IGlobalAuditLogRepository auditLogRepository,
    IVaultDigitalSignatureService digitalSignatureService)
    : AuditService.AuditServiceBase
{
  public override async Task<VerifySignatureResponse> VerifySignature(
      VerifySignatureRequest request,
      ServerCallContext context)
  {
    try
    {
      if (string.IsNullOrWhiteSpace(request.Base64Payload))
        return new VerifySignatureResponse
        {
          IsValid = false,
          ErrorMessage = "Payload cannot be null or empty"
        };

      if (string.IsNullOrWhiteSpace(request.Signature))
        return new VerifySignatureResponse
        {
          IsValid = false,
          ErrorMessage = "Signature cannot be null or empty"
        };

      // Verify the signature using Vault Transit Engine
      var isValid = await digitalSignatureService.VerifyDataAsync(
          request.Base64Payload,
          request.Signature,
          context.CancellationToken);

      // If valid and audit log ID provided, mark as verified
      if (isValid && !string.IsNullOrWhiteSpace(request.AuditLogId))
      {
        if (Guid.TryParse(request.AuditLogId, out var auditId))
        {
          var id = new GlobalAuditLogId(auditId);
          await auditLogRepository.MarkAsVerifiedAsync(id, context.CancellationToken);
        }
      }

      return new VerifySignatureResponse
      {
        IsValid = isValid,
        VerifiedAt = DateTime.UtcNow.ToUniversalTime().ToString("O")
      };
    }
    catch (Exception ex)
    {
      return new VerifySignatureResponse
      {
        IsValid = false,
        ErrorMessage = $"Verification failed: {ex.Message}"
      };
    }
  }

  public override async Task<GetAuditLogResponse> GetAuditLog(
      GetAuditLogRequest request,
      ServerCallContext context)
  {
    try
    {
      if (string.IsNullOrWhiteSpace(request.Id))
        return new GetAuditLogResponse
        {
          Success = false,
          ErrorMessage = "Audit log ID cannot be null or empty"
        };

      if (!Guid.TryParse(request.Id, out var auditId))
        return new GetAuditLogResponse
        {
          Success = false,
          ErrorMessage = "Invalid audit log ID format"
        };

      var id = new GlobalAuditLogId(auditId);
      var auditLog = await auditLogRepository.GetByIdAsync(id, context.CancellationToken);

      if (auditLog == null)
        return new GetAuditLogResponse
        {
          Success = false,
          ErrorMessage = $"Audit log not found: {auditId}"
        };

      return new GetAuditLogResponse
      {
        Success = true,
        AuditLog = MapToProto(auditLog)
      };
    }
    catch (Exception ex)
    {
      return new GetAuditLogResponse
      {
        Success = false,
        ErrorMessage = $"Error retrieving audit log: {ex.Message}"
      };
    }
  }

  public override async Task<GetAuditsByUserResponse> GetAuditsByUser(
      GetAuditsByUserRequest request,
      ServerCallContext context)
  {
    try
    {
      if (string.IsNullOrWhiteSpace(request.UserId))
        return new GetAuditsByUserResponse
        {
          Success = false,
          ErrorMessage = "User ID cannot be null or empty"
        };

      var auditLogs = await auditLogRepository.GetByUserIdAsync(
          request.UserId,
          context.CancellationToken);

      var auditList = auditLogs.ToList();
      var limit = request.Limit > 0 ? request.Limit : 100;
      var page = request.Page > 0 ? request.Page : 1;
      var skip = (page - 1) * limit;

      var paged = auditList.Skip(skip).Take(limit).ToList();

      var response = new GetAuditsByUserResponse
      {
        Success = true,
        TotalCount = auditList.Count
      };

      response.AuditLogs.AddRange(paged.Select(MapToProto));

      return response;
    }
    catch (Exception ex)
    {
      return new GetAuditsByUserResponse
      {
        Success = false,
        ErrorMessage = $"Error retrieving audits: {ex.Message}"
      };
    }
  }

  public override async Task<GetAuditsByAggregateTypeResponse> GetAuditsByAggregateType(
      GetAuditsByAggregateTypeRequest request,
      ServerCallContext context)
  {
    try
    {
      if (string.IsNullOrWhiteSpace(request.AggregateType))
        return new GetAuditsByAggregateTypeResponse
        {
          Success = false,
          ErrorMessage = "Aggregate type cannot be null or empty"
        };

      IEnumerable<Audit.Domain.Entities.GlobalAuditLog> auditLogs;

      if (!string.IsNullOrWhiteSpace(request.Action))
      {
        auditLogs = await auditLogRepository.GetByAggregateTypeAndActionAsync(
            request.AggregateType,
            request.Action,
            context.CancellationToken);
      }
      else
      {
        auditLogs = await auditLogRepository.GetByAggregateTypeAndActionAsync(
            request.AggregateType,
            "",
            context.CancellationToken);
      }

      var auditList = auditLogs.ToList();
      var limit = request.Limit > 0 ? request.Limit : 100;
      var page = request.Page > 0 ? request.Page : 1;
      var skip = (page - 1) * limit;

      var paged = auditList.Skip(skip).Take(limit).ToList();

      var response = new GetAuditsByAggregateTypeResponse
      {
        Success = true,
        TotalCount = auditList.Count
      };

      response.AuditLogs.AddRange(paged.Select(MapToProto));

      return response;
    }
    catch (Exception ex)
    {
      return new GetAuditsByAggregateTypeResponse
      {
        Success = false,
        ErrorMessage = $"Error retrieving audits: {ex.Message}"
      };
    }
  }

  /// <summary>
  ///     Maps domain entity to protobuf message.
  /// </summary>
  private static AuditLogEntry MapToProto(Audit.Domain.Entities.GlobalAuditLog auditLog)
  {
    return new AuditLogEntry
    {
      Id = auditLog.Id.Value.ToString(),
      CorrelationId = auditLog.CorrelationId.ToString(),
      AggregateType = auditLog.AggregateType,
      Action = auditLog.Action,
      Payload = auditLog.Payload,
      UserId = auditLog.UserId,
      DigitalSignature = auditLog.DigitalSignature,
      ActionTimestamp = auditLog.ActionTimestamp.ToUniversalTime().ToString("O"),
      CreatedAt = auditLog.CreatedAt.ToUniversalTime().ToString("O"),
      IsVerified = auditLog.IsVerified,
      VerifiedAt = auditLog.VerifiedAt?.ToUniversalTime().ToString("O") ?? ""
    };
  }
}
