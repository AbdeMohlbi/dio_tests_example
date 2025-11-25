import 'package:dio/dio.dart';

class ApiService {
  final Dio dio;

  ApiService(this.dio);

  Future<String> fetchMessage() async {
    final res = await dio.get("/hello");
    return res.data["message"]; 
  }
}