import 'api_serveice.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dio/dio.dart';

import 'fake_http_adapter.dart';


void main() {
  group("ApiService tests", () {
    test("returns message on success", () async {
      final adapter = FakeHttpClientAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final api = ApiService(dio);

      adapter.onGet("/hello", (options) {
        return ResponseBody.fromString(
          '{"message":"Hello World"}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });

      final message = await api.fetchMessage();
      expect(message, "Hello World");
    });

    test("throws DioException on server error (500)", () async {
      final adapter = FakeHttpClientAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final api = ApiService(dio);

      adapter.onGet("/hello", (options) {
        return ResponseBody.fromString(
          '{"error":"server"}',
          500,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });

      expect(() => api.fetchMessage(), throwsA(isA<DioException>()));
    });

    test("simulates a timeout error", () async {
      final adapter = FakeHttpClientAdapter();
      final dio = Dio(
        BaseOptions(receiveTimeout: const Duration(milliseconds: 100)),
      )..httpClientAdapter = adapter;

      final api = ApiService(dio);

      adapter.onGet("/hello", (options) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
          error: "Simulated timeout",
        );
      });

      expect(() => api.fetchMessage(), throwsA(isA<DioException>()));
    });

    test("handles unexpected JSON structure", () async {
      final adapter = FakeHttpClientAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final api = ApiService(dio);

      adapter.onGet("/hello", (options) {
        return ResponseBody.fromString(
          '{"undefined_key":"value"}',
          200,
          headers: {
            Headers.contentTypeHeader: ['application/json'],
          },
        );
      });

      expect(() => api.fetchMessage(), throwsA(anything));
      expect(() => api.fetchMessage(), throwsA(isA<TypeError>()),);
    });
  });
}
