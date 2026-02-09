using System.Text.Json;
using System.Text.Json.Serialization;
using Sale.Domain.Identifiers;

namespace Sale.API.Serialization;

public sealed class StronglyTypedIdJsonConverter<TId> : JsonConverter<TId>
    where TId : struct, IStronglyTypedId
{
    public override TId Read(ref Utf8JsonReader reader, Type typeToConvert, JsonSerializerOptions options)
    {
        if (reader.TokenType == JsonTokenType.String)
        {
            var value = reader.GetString();
            if (string.IsNullOrWhiteSpace(value))
                return default;
            return (TId)Activator.CreateInstance(typeof(TId), Guid.Parse(value))!;
        }

        if (reader.TokenType == JsonTokenType.Null)
            return default;

        throw new JsonException($"Unable to convert to {typeof(TId).Name}.");
    }

    public override void Write(Utf8JsonWriter writer, TId value, JsonSerializerOptions options)
        => writer.WriteStringValue(value.Value);
}
