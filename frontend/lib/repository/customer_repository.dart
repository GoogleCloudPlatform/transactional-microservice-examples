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
