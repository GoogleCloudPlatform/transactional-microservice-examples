/*
  Copyright 2020 Google Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

      http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/

import 'dart:convert';
import 'dart:html' as html;

import 'package:dio/dio.dart';

Future<String> postData(
    String path, String token, Map<String, dynamic> parameter) async {
  final dio = Dio();
  final host =
      html.window.location.protocol + '//' + html.window.location.hostname;
  if (token != null && token.isNotEmpty) {
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
