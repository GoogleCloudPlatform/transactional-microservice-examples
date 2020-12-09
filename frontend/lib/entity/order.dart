import 'package:freezed_annotation/freezed_annotation.dart';

part 'order.freezed.dart';
part 'order.g.dart';

@freezed
abstract class Order with _$Order {
  const factory Order({
    @JsonKey(name: 'order_id') String orderId,
    @JsonKey(name: 'customer_id') String customerId,
    int number,
    String status,
  }) = _Order;
  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
}

@freezed
abstract class OrderDto with _$OrderDto {
  const factory OrderDto({
    @JsonKey(name: 'order_id', includeIfNull: false) String orderId,
    @JsonKey(name: 'customer_id', includeIfNull: false) String customerId,
    @JsonKey(includeIfNull: false) int number,
    @JsonKey(includeIfNull: false) String status,
  }) = _OrderDto;
  factory OrderDto.fromJson(Map<String, dynamic> json) =>
      _$OrderDtoFromJson(json);
}
