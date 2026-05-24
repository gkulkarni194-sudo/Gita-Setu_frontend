import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/api_response.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ApiResponse<dynamic>> getHealth() => _get('/health');

  Future<ApiResponse<dynamic>> getGurus() =>
      _get('/gurus').then(_withGuruListData);

  /// Sends guru payload to POST /gurus.
  /// [adminKey] is read from adminPasswordProvider at the call site —
  /// never hardcoded in source.
  Future<ApiResponse<dynamic>> addGuru(
    Map<String, dynamic> guru, {
    required String adminKey,
  }) =>
      _post('/gurus', {
        'name': guru['name'],
        'expertise': _guruExpertise(guru),
        'contact': guru['contact'],
        'admin_key': adminKey,
      }).then(_withGuruMapData);

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

  Future<ApiResponse<dynamic>> _get(String path) => _send('GET', path);

  Future<ApiResponse<dynamic>> _post(String path, dynamic body) =>
      _send('POST', path, body: body);

  Future<ApiResponse<dynamic>> _send(
    String method,
    String path, {
    dynamic body,
  }) async {
    final uri = _uri(path);
    final encodedBody = body == null ? null : jsonEncode(body);
    debugPrint('API REQUEST: $method $uri ${encodedBody ?? ''}');

    try {
      final response = method == 'POST'
          ? await _client
              .post(uri, headers: _headers, body: encodedBody)
              .timeout(AppConstants.requestTimeout)
          : await _client
              .get(uri, headers: _headers)
              .timeout(AppConstants.requestTimeout);
      debugPrint('API RESPONSE: ${response.statusCode} ${response.body}');
      return _parseResponse(response);
    } on TimeoutException catch (e) {
      debugPrint('API EXCEPTION: $method $uri $e');
      return ApiResponse.error('timeout', e.toString());
    } on SocketException catch (e) {
      debugPrint('API EXCEPTION: $method $uri $e');
      return ApiResponse.error('network_unavailable', e.toString());
    } on http.ClientException catch (e) {
      debugPrint('API EXCEPTION: $method $uri $e');
      return ApiResponse.error('client_exception', e.toString());
    } on FormatException catch (e) {
      debugPrint('API EXCEPTION: $method $uri $e');
      return ApiResponse.error(
          'invalid_json', 'The server returned an unreadable response: $e');
    } catch (e) {
      debugPrint('API EXCEPTION: $method $uri $e');
      return ApiResponse.error(
          'unknown_error', 'Something went wrong: ${e.toString()}');
    }
  }

  ApiResponse<dynamic> _parseResponse(http.Response response) {
    try {
      if (response.body.trim().isEmpty) {
        return response.statusCode >= 200 && response.statusCode < 300
            ? ApiResponse(success: true)
            : ApiResponse.error('http_error',
                'Request failed with status ${response.statusCode}');
      }

      final decoded = jsonDecode(response.body);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        if (decoded is Map) {
          final message = _extractErrorMessage(decoded);
          return ApiResponse.error(
            'http_error',
            'HTTP ${response.statusCode}: ${message ?? response.body}',
          );
        }
        return ApiResponse.error(
          'http_error',
          'HTTP ${response.statusCode}: ${decoded is String && decoded.trim().isNotEmpty ? decoded : response.body}',
        );
      }

      if (decoded is! Map<String, dynamic>) {
        return ApiResponse(success: true, data: decoded);
      }

      if (!decoded.containsKey('success')) {
        return ApiResponse(success: true, data: decoded);
      }

      return ApiResponse.fromJson(decoded, (data) => data);
    } catch (e) {
      return ApiResponse.error('parse_error',
          'Failed to parse server response: $e. Body: ${response.body}');
    }
  }

  String? _extractErrorMessage(Map<dynamic, dynamic> decoded) {
    final message = decoded['message'];
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final error = decoded['error'];
    if (error is String && error.trim().isNotEmpty) {
      return error;
    }
    if (error is Map) {
      final errorMessage = error['message'] ?? error['detail'] ?? error['code'];
      if (errorMessage != null && errorMessage.toString().trim().isNotEmpty) {
        return errorMessage.toString();
      }
    }

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
    return null;
  }

  ApiResponse<dynamic> _withGuruListData(ApiResponse<dynamic> response) {
    if (!response.success) return response;

    final data = response.data;
    if (data is List) return response;
    if (data is Map && data['data'] is List) {
      return ApiResponse<dynamic>(
        success: true,
        data: data['data'],
        error: response.error,
      );
    }
    return response;
  }

  ApiResponse<dynamic> _withGuruMapData(ApiResponse<dynamic> response) {
    if (!response.success) return response;

    final data = response.data;
    if (data is Map && data['data'] is Map) {
      return ApiResponse<dynamic>(
        success: true,
        data: data['data'],
        error: response.error,
      );
    }
    return response;
  }

  String _guruExpertise(Map<String, dynamic> guru) {
    final existing = guru['expertise'];
    if (existing is String && existing.trim().isNotEmpty) {
      return existing.trim();
    }

    final parts = <String>[];
    final title = guru['title']?.toString().trim();
    if (title != null && title.isNotEmpty) parts.add(title);

    final specializations = guru['specializations'];
    if (specializations is List) {
      parts.addAll(
        specializations
            .map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty),
      );
    }

    return parts.join(', ');
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
    final baseUrl = AppConstants.baseUrl.replaceFirst(RegExp(r'/+$'), '');
    return Uri.parse('$baseUrl$p');
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
