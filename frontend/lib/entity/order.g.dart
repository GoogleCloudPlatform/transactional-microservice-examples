// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Order _$_$_OrderFromJson(Map json) {
  return _$_Order(
    orderId: json['order_id'] as String,
    customerId: json['customer_id'] as String,
    number: json['number'] as int,
    status: json['status'] as String,
  );
}

Map<String, dynamic> _$_$_OrderToJson(_$_Order instance) => <String, dynamic>{
      'order_id': instance.orderId,
      'customer_id': instance.customerId,
      'number': instance.number,
      'status': instance.status,
    };

_$_OrderDto _$_$_OrderDtoFromJson(Map json) {
  return _$_OrderDto(
    orderId: json['order_id'] as String,
    customerId: json['customer_id'] as String,
    number: json['number'] as int,
    status: json['status'] as String,
  );
}

Map<String, dynamic> _$_$_OrderDtoToJson(_$_OrderDto instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('order_id', instance.orderId);
  writeNotNull('customer_id', instance.customerId);
  writeNotNull('number', instance.number);
  writeNotNull('status', instance.status);
  return val;
}
