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
      return ApiResponse<T>(
        success: false,
        error: rawError is Map
            ? ApiError.fromJson(Map<String, dynamic>.from(rawError))
            : ApiError(
                code: 'unknown',
                message: rawError?.toString() ?? 'No error provided',
              ),
      );
    }
  }

  factory ApiResponse.error(String code, String message) {
    return ApiResponse<T>(
      success: false,
      error: ApiError(code: code, message: message),
    );
  }
}
