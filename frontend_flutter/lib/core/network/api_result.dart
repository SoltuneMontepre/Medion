/// Parses backend ApiResult envelope: { isSuccess, data, message?, statusCode?, errors? }.
/// Backend uses camelCase JSON.
T? parseData<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
  final data = json['data'];
  if (data == null) return null;
  if (data is Map<String, dynamic>) return fromJson(data);
  return null;
}

/// Parses ApiResult with data as a list.
List<T> parseDataList<T>(Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
  final data = json['data'];
  if (data == null || data is! List) return [];
  final list = <T>[];
  for (final e in data) {
    if (e is Map<String, dynamic>) list.add(fromJson(e));
  }
  return list;
}

bool isApiSuccess(Map<String, dynamic> json) =>
    json['isSuccess'] as bool? ?? false;

String? apiMessage(Map<String, dynamic> json) =>
    json['message'] as String?;
