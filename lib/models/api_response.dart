import 'dart:convert'; // 👈 Make sure to add this import at the top
import 'api_error.dart';

class ApiResponse<T> {
  final bool success;
  final T? data;
  final ApiError? error;

  ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json, 
    T Function(dynamic)? fromJsonT
  ) {
    bool isSuccess = json['success'] == true;
    if (isSuccess) {
      return ApiResponse<T>(
        success: true,
        data: fromJsonT != null && json['data'] != null ? fromJsonT(json['data']) : json['data'] as T?,
      );
    } else {
      final rawError = json['error'];
      final rawMessage = json['message'];
      return ApiResponse<T>(
        success: false,
        error: ApiError(
          code: rawError is Map
              ? rawError['code']?.toString() ?? 'unknown'
              : 'unknown',
          message: rawMessage?.toString() ??
              (rawError is Map
                  ? rawError['message']?.toString()
                  : rawError?.toString()) ??
              'No error provided',
        ),
      );
    }
  }

  /// 🛡️ SOLUTION 3 SAFETY NET: Parses a raw string response completely safely.
  /// Use this method in your repositories instead of calling jsonDecode directly.
  factory ApiResponse.fromRawBody(
    String rawBody, 
    T Function(dynamic)? fromJsonT
  ) {
    try {
      final decoded = jsonDecode(rawBody);
      if (decoded is Map<String, dynamic>) {
        return ApiResponse.fromJson(decoded, fromJsonT);
      } else {
        return ApiResponse.error('INVALID_JSON_FORMAT', 'Server response was not a structured JSON object.');
      }
    } catch (e) {
      return ApiResponse.error('CLIENT_PARSE_ERROR', 'Could not read server response. Please check your connectivity.');
    }
  }

  factory ApiResponse.error(String code, String message) {
    return ApiResponse<T>(
      success: false,
      error: ApiError(code: code, message: message),
    );
  }
}
