import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../constants/app_constants.dart';
import '../models/api_response.dart';

class ApiService {
  ApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const int _timeoutSeconds = 15;

  Future<ApiResponse<dynamic>> getHealth() async {
    return _get('/health');
  }

  Future<ApiResponse<dynamic>> getGurus() async {
    return _get('/gurus');
  }

  Future<ApiResponse<dynamic>> addGuru(Map<String, dynamic> guru) async {
    return _post('/gurus', guru);
  }

  Future<ApiResponse<dynamic>> explainQuery(Map<String, dynamic> payload) async {
    return _post('/explain', payload);
  }

  Future<ApiResponse<dynamic>> analyzeMood(Map<String, dynamic> payload) async {
    return _post('/mood/analyze', payload);
  }

  Future<ApiResponse<dynamic>> analyzeJournal(Map<String, dynamic> payload) async {
    return _post('/journal/analyze', payload);
  }
  
  Future<ApiResponse<dynamic>> getChapterShlokas(int chapter) async {
    return _get('/chapter/$chapter');
  }

  Future<ApiResponse<dynamic>> getDailyShloka() async {
    return _get('/daily');
  }
  
  Future<bool> verifyAdmin(String password) async {
    try {
      final res = await _post('/admin/verify', {'password': password});
      return res.success;
    } catch (e) {
      return false;
    }
  }

  Future<ApiResponse<dynamic>> _get(String path) => _send(() {
        return _client.get(_uri(path), headers: _headers);
      });

  Future<ApiResponse<dynamic>> _post(String path, dynamic body) => _send(() {
        return _client.post(
          _uri(path),
          headers: _headers,
          body: jsonEncode(body),
        );
      });

  Future<ApiResponse<dynamic>> _send(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: _timeoutSeconds));
      return _parseResponse(response);
    } on TimeoutException {
      return ApiResponse.error('timeout', 'The server is taking longer than expected. Please try again.');
    } on SocketException {
      return ApiResponse.error('network_unavailable', 'Please check your internet connection and try again.');
    } on FormatException {
      return ApiResponse.error('invalid_json', 'The server returned an unreadable response.');
    } catch (e) {
      return ApiResponse.error('unknown_error', 'Something went wrong: ${e.toString()}');
    }
  }

  ApiResponse<dynamic> _parseResponse(http.Response response) {
    try {
      if (response.body.trim().isEmpty) {
         if (response.statusCode >= 200 && response.statusCode < 300) {
            return ApiResponse(success: true);
         }
         return ApiResponse.error('http_error', 'Request failed with status ${response.statusCode}');
      }
      
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      
      // Some traditional backends might not wrap the entire thing in success/data envelope if it failed with HTTP code 
      if (response.statusCode < 200 || response.statusCode >= 300) {
          if (decoded.containsKey('error') && decoded['error'] is Map) {
             return ApiResponse.error(decoded['error']['code']?.toString() ?? 'unknown', decoded['error']['message']?.toString() ?? 'Error');
          }
          return ApiResponse.error('http_error', 'HTTP ${response.statusCode}');
      }

      // Automatically map traditional fastapi 'success' boolean envelope if exists.
      // If it doesn't exist, we force it manually to preserve compatibility.
      if (!decoded.containsKey('success')) {
         return ApiResponse(success: true, data: decoded);
      }
      
      return ApiResponse.fromJson(decoded, (data) => data);
    } catch (e) {
      return ApiResponse.error('parse_error', 'Failed to parse server response.');
    }
  }

  Uri _uri(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('${AppConstants.baseUrl}$normalizedPath');
  }

  Map<String, String> get _headers => const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
}
