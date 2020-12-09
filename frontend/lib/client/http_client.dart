import 'dart:convert';
import 'dart:html' as html;

import 'package:dio/dio.dart';

Future<String> postData(
    String path, String token, Map<String, dynamic> parameter) async {
  final dio = Dio();
  print('Sending request: $path');
  print('Parameter: $parameter');
  final host =
      html.window.location.protocol + '//' + html.window.location.hostname;
  if (token != null && token.isNotEmpty) {
    print('With token: $token');
    dio.options.headers['Authorization'] = 'Bearer $token';
  }
  Response response;
  try {
    response = await dio.post<Response>(host + path, data: parameter);
  } on DioError catch (e) {
    if (e.response != null) {
      print('Error occurred: got response');
      return e.response.data.toString();
    }
    print('Error occurred: no response');
    return e.message;
  }
  const encoder = JsonEncoder.withIndent('    ');
  return encoder.convert(response.data);
}
