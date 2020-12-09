import 'package:freezed_annotation/freezed_annotation.dart';

part 'customer.freezed.dart';
part 'customer.g.dart';

@freezed
abstract class Customer with _$Customer {
  const factory Customer(
      {@JsonKey(name: 'customer_id') String customerId,
      int credit,
      int limit}) = _Customer;
  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
}

@freezed
abstract class CustomerDto with _$CustomerDto {
  const factory CustomerDto({
    @JsonKey(name: 'customer_id', includeIfNull: false) String customerId,
    @JsonKey(includeIfNull: false) int number,
    @JsonKey(includeIfNull: false) int limit,
  }) = _CustomerDto;
  factory CustomerDto.fromJson(Map<String, dynamic> json) =>
      _$CustomerDtoFromJson(json);
}
