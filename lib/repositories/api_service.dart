import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/api_response.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ApiResponse<dynamic>> getHealth() => _get('/health');

  Future<ApiResponse<dynamic>> getGurus() => _get('/gurus');

  /// Sends guru payload to POST /gurus.
  /// [adminKey] is read from adminPasswordProvider at the call site —
  /// never hardcoded in source.
  Future<ApiResponse<dynamic>> addGuru(
    Map<String, dynamic> guru, {
    required String adminKey,
  }) =>
      _post('/gurus', {...guru, 'admin_key': adminKey});

  Future<ApiResponse<dynamic>> explainQuery(Map<String, dynamic> payload) =>
      _post('/explain', payload);

  Future<ApiResponse<dynamic>> analyzeMood(Map<String, dynamic> payload) =>
      _post('/mood/analyze', payload);

  Future<ApiResponse<dynamic>> analyzeJournal(Map<String, dynamic> payload) =>
      _post('/journal/analyze', payload);

  Future<ApiResponse<dynamic>> getChapterShlokas(int chapter) =>
      _get('/chapter/$chapter');

  Future<ApiResponse<dynamic>> getDailyShloka() => _get('/daily');

  Future<bool> verifyAdmin(String password) async {
    try {
      final res = await _post('/admin/verify', {'password': password});
      return res.success;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // Private
  // ---------------------------------------------------------------------------

  Future<ApiResponse<dynamic>> _get(String path) =>
      _send(() => _client.get(_uri(path), headers: _headers));

  Future<ApiResponse<dynamic>> _post(String path, dynamic body) =>
      _send(() =>
          _client.post(_uri(path), headers: _headers, body: jsonEncode(body)));

  Future<ApiResponse<dynamic>> _send(
    Future<http.Response> Function() request,
  ) async {
    try {
      final response = await request().timeout(AppConstants.requestTimeout);
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.error(
          'timeout', 'The server is taking longer than expected. Please try again.');
    } on SocketException {
      return ApiResponse.error(
          'network_unavailable', 'Please check your internet connection and try again.');
    } on FormatException {
      return ApiResponse.error('invalid_json', 'The server returned an unreadable response.');
    } catch (e) {
      return ApiResponse.error('unknown_error', 'Something went wrong: ${e.toString()}');
    }
  }

  ApiResponse<dynamic> _parseResponse(http.Response response) {
    try {
      if (response.body.trim().isEmpty) {
        return response.statusCode >= 200 && response.statusCode < 300
            ? ApiResponse(success: true)
            : ApiResponse.error(
                'http_error', 'Request failed with status ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (decoded is Map && decoded['error'] is Map) {
          final err = decoded['error'] as Map;
          return ApiResponse.error(
            err['code']?.toString() ?? 'unknown',
            err['message']?.toString() ?? 'Error',
          );
        }
        if (decoded is Map) {
          return ApiResponse.error(
            'http_error',
            _extractErrorMessage(decoded) ?? 'HTTP ${response.statusCode}',
          );
        }
        return ApiResponse.error(
          'http_error',
          decoded is String && decoded.trim().isNotEmpty
              ? decoded
              : 'HTTP ${response.statusCode}',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        return ApiResponse(success: true, data: decoded);
      }

      if (!decoded.containsKey('success')) {
        return ApiResponse(success: true, data: decoded);
      }

      return ApiResponse.fromJson(decoded, (data) => data);
    } catch (_) {
      return ApiResponse.error(
          'parse_error', 'Failed to parse server response.');
    }
  }

  String? _extractErrorMessage(Map<dynamic, dynamic> decoded) {
    final detail = decoded['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    if (detail is List && detail.isNotEmpty) {
      return detail
          .map(_formatDetailItem)
          .where((item) => item.isNotEmpty)
          .join('\n');
    }
    final message = decoded['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }
    return null;
  }

  String _formatDetailItem(dynamic item) {
    if (item is String) return item;
    if (item is Map) {
      final message = item['msg'] ?? item['message'] ?? item['detail'];
      final location = item['loc'];
      if (message == null) return item.toString();
      if (location is List && location.isNotEmpty) {
        return '${location.join('.')}: $message';
      }
      return message.toString();
    }
    return item.toString();
  }

  Uri _uri(String path) {
    final p = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${AppConstants.baseUrl}$p');
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
