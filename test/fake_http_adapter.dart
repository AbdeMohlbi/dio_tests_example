import 'dart:async';
import 'dart:typed_data';
import 'package:dio/dio.dart';

typedef FakeResponseBuilder = FutureOr<ResponseBody> Function(
  RequestOptions options,
);

class FakeHttpClientAdapter implements HttpClientAdapter {
  final Map<String, FakeResponseBuilder> _handlers = {};

  void onGet(String path, FakeResponseBuilder handler) {
    _handlers["GET $path"] = handler;
  }

  void onPost(String path, FakeResponseBuilder handler) {
    _handlers["POST $path"] = handler;
  }

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final key = "${options.method} ${options.path}";
    final handler = _handlers[key];

    if (handler == null) {
      throw DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        error: "No fake handler defined for $key",
      );
    }

    return await handler(options);
  }
}
