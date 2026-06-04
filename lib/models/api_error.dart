class ApiError implements Exception {
  final String code;
  final String message;

  ApiError({required this.code, required this.message});

  factory ApiError.fromJson(Map<String, dynamic> json) {
    return ApiError(
      code: json['code']?.toString() ?? 'unknown_error',
      message: json['message']?.toString() ?? 'An unknown error occurred.',
    );
  }

  @override
  String toString() => 'ApiError($code): $message';
}
