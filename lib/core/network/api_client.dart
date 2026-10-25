// ignore_for_file: prefer_initializing_formals

import 'package:dio/dio.dart';

import '../storage/token_storage.dart';
import 'api_exception.dart';

typedef JsonParser<T> = T Function(Object? json);

class ApiClient {
  ApiClient({required String baseUrl, required TokenStorage tokens, Dio? dio})
    : _tokens = tokens,
      _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 20),
              headers: {'Accept': 'application/json'},
            ),
          );

  final Dio _dio;
  final TokenStorage _tokens;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? query,
    required JsonParser<T> parse,
  }) {
    return _send('GET', path, query: query, parse: parse);
  }

  Future<T> post<T>(String path, {Object? body, required JsonParser<T> parse}) {
    return _send('POST', path, body: body, parse: parse);
  }

  Future<T> _send<T>(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Object? body,
    required JsonParser<T> parse,
  }) async {
    final token = await _tokens.readValid();

    try {
      final response = await _dio.request<Object?>(
        path,
        data: body,
        queryParameters: query,
        options: Options(
          method: method,
          headers: token == null ? null : {'Authorization': 'Bearer $token'},
        ),
      );
      return parse(response.data);
    } on DioException catch (error) {
      // Backend menolak token yang kita kirim (misalnya kunci JWT berubah):
      // buang token supaya aplikasi menganggap pengguna sudah keluar.
      if (token != null && error.response?.statusCode == 401) {
        await _tokens.clear();
      }
      throw _toApiException(error);
    }
  }

  ApiException _toApiException(DioException error) {
    final response = error.response;
    if (response == null) return const ApiException(networkErrorMessage);
    return ApiException(
      messageFromErrorBody(response.data, response.statusCode),
      statusCode: response.statusCode,
    );
  }
}
