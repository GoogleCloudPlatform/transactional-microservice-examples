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

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../client/http_client.dart';
import '../entity/customer.dart';

final customerRepository = Provider.autoDispose<CustomerRepository>(
    (ref) => CustomerRepositoryImpl(ref.read));

abstract class CustomerRepository {
  Future<String> reserveCustomer(String token, CustomerDto customerDto);
  Future<String> getCustomer(
      bool isAsync, String token, CustomerDto customerDto);
  Future<String> limitCustomer(
      bool isAsync, String token, CustomerDto customerDto);
}

class CustomerRepositoryImpl implements CustomerRepository {
  CustomerRepositoryImpl(this.read);

  final Reader read;

  String _getPrefix(bool isAsync) {
    return isAsync ? '/customer-service-async' : '/customer-service-sync';
  }

  @override
  Future<String> reserveCustomer(String token, CustomerDto customerDto) async {
    const _service = '/customer-service-sync';
    const _path = '/api/v1/customer/reserve';
    return postData(_service + _path, token, customerDto.toJson());
  }

  @override
  Future<String> getCustomer(
      bool isAsync, String token, CustomerDto customerDto) async {
    const _path = '/api/v1/customer/get';
    return postData(_getPrefix(isAsync) + _path, token, customerDto.toJson());
  }

  @override
  Future<String> limitCustomer(
      bool isAsync, String token, CustomerDto customerDto) async {
    const _path = '/api/v1/customer/limit';
    return postData(_getPrefix(isAsync) + _path, token, customerDto.toJson());
  }
}
