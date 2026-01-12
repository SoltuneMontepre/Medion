using Amazon.S3;
using Amazon.S3.Model;
using Microsoft.Extensions.Options;

namespace SharedStorage;

public interface IStorageService
{
    Task<string> UploadFileAsync(string bucketName, string key, Stream fileStream, string contentType, CancellationToken cancellationToken = default);
    Task<Stream> DownloadFileAsync(string bucketName, string key, CancellationToken cancellationToken = default);
    Task DeleteFileAsync(string bucketName, string key, CancellationToken cancellationToken = default);
    Task<string> GetPresignedUrlAsync(string bucketName, string key, int expirationMinutes = 60, CancellationToken cancellationToken = default);
}

public class S3StorageService : IStorageService
{
    private readonly IAmazonS3 _s3Client;
    private readonly S3StorageOptions _options;

    public S3StorageService(IAmazonS3 s3Client, IOptions<S3StorageOptions> options)
    {
        _s3Client = s3Client;
        _options = options.Value;
    }

    public async Task<string> UploadFileAsync(string bucketName, string key, Stream fileStream, string contentType, CancellationToken cancellationToken = default)
    {
        try
        {
            var putRequest = new PutObjectRequest
            {
                BucketName = bucketName,
                Key = key,
                InputStream = fileStream,
                ContentType = contentType
            };

            var response = await _s3Client.PutObjectAsync(putRequest, cancellationToken);
            return key;
        }
        catch (Exception ex)
        {
            throw new StorageException($"Failed to upload file {key} to bucket {bucketName}", ex);
        }
    }

    public async Task<Stream> DownloadFileAsync(string bucketName, string key, CancellationToken cancellationToken = default)
    {
        try
        {
            var getRequest = new GetObjectRequest
            {
                BucketName = bucketName,
                Key = key
            };

            var response = await _s3Client.GetObjectAsync(getRequest, cancellationToken);
            return response.ResponseStream;
        }
        catch (Exception ex)
        {
            throw new StorageException($"Failed to download file {key} from bucket {bucketName}", ex);
        }
    }

    public async Task DeleteFileAsync(string bucketName, string key, CancellationToken cancellationToken = default)
    {
        try
        {
            var deleteRequest = new DeleteObjectRequest
            {
                BucketName = bucketName,
                Key = key
            };

            await _s3Client.DeleteObjectAsync(deleteRequest, cancellationToken);
        }
        catch (Exception ex)
        {
            throw new StorageException($"Failed to delete file {key} from bucket {bucketName}", ex);
        }
    }

    public async Task<string> GetPresignedUrlAsync(string bucketName, string key, int expirationMinutes = 60, CancellationToken cancellationToken = default)
    {
        try
        {
            var request = new GetPreSignedUrlRequest
            {
                BucketName = bucketName,
                Key = key,
                Expires = DateTime.UtcNow.AddMinutes(expirationMinutes)
            };

            return _s3Client.GetPreSignedURL(request);
        }
        catch (Exception ex)
        {
            throw new StorageException($"Failed to generate presigned URL for {key} in bucket {bucketName}", ex);
        }
    }
}

public class S3StorageOptions
{
    public string Region { get; set; } = "us-east-1";
    public string Endpoint { get; set; } = string.Empty;
    public bool UsePathStyle { get; set; } = false;
}

public class StorageException : Exception
{
    public StorageException(string message) : base(message) { }
    public StorageException(string message, Exception innerException) : base(message, innerException) { }
}
