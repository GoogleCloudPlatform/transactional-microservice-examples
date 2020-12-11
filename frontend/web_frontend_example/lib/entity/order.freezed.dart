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

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies

part of 'order.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
Order _$OrderFromJson(Map<String, dynamic> json) {
  return _Order.fromJson(json);
}

/// @nodoc
class _$OrderTearOff {
  const _$OrderTearOff();

// ignore: unused_element
  _Order call(
      {@JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'customer_id') String customerId,
      int number,
      String status}) {
    return _Order(
      orderId: orderId,
      customerId: customerId,
      number: number,
      status: status,
    );
  }

// ignore: unused_element
  Order fromJson(Map<String, Object> json) {
    return Order.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $Order = _$OrderTearOff();

/// @nodoc
mixin _$Order {
  @JsonKey(name: 'order_id')
  String get orderId;
  @JsonKey(name: 'customer_id')
  String get customerId;
  int get number;
  String get status;

  Map<String, dynamic> toJson();
  $OrderCopyWith<Order> get copyWith;
}

/// @nodoc
abstract class $OrderCopyWith<$Res> {
  factory $OrderCopyWith(Order value, $Res Function(Order) then) =
      _$OrderCopyWithImpl<$Res>;
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'customer_id') String customerId,
      int number,
      String status});
}

/// @nodoc
class _$OrderCopyWithImpl<$Res> implements $OrderCopyWith<$Res> {
  _$OrderCopyWithImpl(this._value, this._then);

  final Order _value;
  // ignore: unused_field
  final $Res Function(Order) _then;

  @override
  $Res call({
    Object orderId = freezed,
    Object customerId = freezed,
    Object number = freezed,
    Object status = freezed,
  }) {
    return _then(_value.copyWith(
      orderId: orderId == freezed ? _value.orderId : orderId as String,
      customerId:
          customerId == freezed ? _value.customerId : customerId as String,
      number: number == freezed ? _value.number : number as int,
      status: status == freezed ? _value.status : status as String,
    ));
  }
}

/// @nodoc
abstract class _$OrderCopyWith<$Res> implements $OrderCopyWith<$Res> {
  factory _$OrderCopyWith(_Order value, $Res Function(_Order) then) =
      __$OrderCopyWithImpl<$Res>;
  @override
  $Res call(
      {@JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'customer_id') String customerId,
      int number,
      String status});
}

/// @nodoc
class __$OrderCopyWithImpl<$Res> extends _$OrderCopyWithImpl<$Res>
    implements _$OrderCopyWith<$Res> {
  __$OrderCopyWithImpl(_Order _value, $Res Function(_Order) _then)
      : super(_value, (v) => _then(v as _Order));

  @override
  _Order get _value => super._value as _Order;

  @override
  $Res call({
    Object orderId = freezed,
    Object customerId = freezed,
    Object number = freezed,
    Object status = freezed,
  }) {
    return _then(_Order(
      orderId: orderId == freezed ? _value.orderId : orderId as String,
      customerId:
          customerId == freezed ? _value.customerId : customerId as String,
      number: number == freezed ? _value.number : number as int,
      status: status == freezed ? _value.status : status as String,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_Order implements _Order {
  const _$_Order(
      {@JsonKey(name: 'order_id') this.orderId,
      @JsonKey(name: 'customer_id') this.customerId,
      this.number,
      this.status});

  factory _$_Order.fromJson(Map<String, dynamic> json) =>
      _$_$_OrderFromJson(json);

  @override
  @JsonKey(name: 'order_id')
  final String orderId;
  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  @override
  final int number;
  @override
  final String status;

  @override
  String toString() {
    return 'Order(orderId: $orderId, customerId: $customerId, number: $number, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Order &&
            (identical(other.orderId, orderId) ||
                const DeepCollectionEquality()
                    .equals(other.orderId, orderId)) &&
            (identical(other.customerId, customerId) ||
                const DeepCollectionEquality()
                    .equals(other.customerId, customerId)) &&
            (identical(other.number, number) ||
                const DeepCollectionEquality().equals(other.number, number)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(orderId) ^
      const DeepCollectionEquality().hash(customerId) ^
      const DeepCollectionEquality().hash(number) ^
      const DeepCollectionEquality().hash(status);

  @override
  _$OrderCopyWith<_Order> get copyWith =>
      __$OrderCopyWithImpl<_Order>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_OrderToJson(this);
  }
}

abstract class _Order implements Order {
  const factory _Order(
      {@JsonKey(name: 'order_id') String orderId,
      @JsonKey(name: 'customer_id') String customerId,
      int number,
      String status}) = _$_Order;

  factory _Order.fromJson(Map<String, dynamic> json) = _$_Order.fromJson;

  @override
  @JsonKey(name: 'order_id')
  String get orderId;
  @override
  @JsonKey(name: 'customer_id')
  String get customerId;
  @override
  int get number;
  @override
  String get status;
  @override
  _$OrderCopyWith<_Order> get copyWith;
}

OrderDto _$OrderDtoFromJson(Map<String, dynamic> json) {
  return _OrderDto.fromJson(json);
}

/// @nodoc
class _$OrderDtoTearOff {
  const _$OrderDtoTearOff();

// ignore: unused_element
  _OrderDto call(
      {@JsonKey(name: 'order_id', includeIfNull: false) String orderId,
      @JsonKey(name: 'customer_id', includeIfNull: false) String customerId,
      @JsonKey(includeIfNull: false) int number,
      @JsonKey(includeIfNull: false) String status}) {
    return _OrderDto(
      orderId: orderId,
      customerId: customerId,
      number: number,
      status: status,
    );
  }

// ignore: unused_element
  OrderDto fromJson(Map<String, Object> json) {
    return OrderDto.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $OrderDto = _$OrderDtoTearOff();

/// @nodoc
mixin _$OrderDto {
  @JsonKey(name: 'order_id', includeIfNull: false)
  String get orderId;
  @JsonKey(name: 'customer_id', includeIfNull: false)
  String get customerId;
  @JsonKey(includeIfNull: false)
  int get number;
  @JsonKey(includeIfNull: false)
  String get status;

  Map<String, dynamic> toJson();
  $OrderDtoCopyWith<OrderDto> get copyWith;
}

/// @nodoc
abstract class $OrderDtoCopyWith<$Res> {
  factory $OrderDtoCopyWith(OrderDto value, $Res Function(OrderDto) then) =
      _$OrderDtoCopyWithImpl<$Res>;
  $Res call(
      {@JsonKey(name: 'order_id', includeIfNull: false) String orderId,
      @JsonKey(name: 'customer_id', includeIfNull: false) String customerId,
      @JsonKey(includeIfNull: false) int number,
      @JsonKey(includeIfNull: false) String status});
}

/// @nodoc
class _$OrderDtoCopyWithImpl<$Res> implements $OrderDtoCopyWith<$Res> {
  _$OrderDtoCopyWithImpl(this._value, this._then);

  final OrderDto _value;
  // ignore: unused_field
  final $Res Function(OrderDto) _then;

  @override
  $Res call({
    Object orderId = freezed,
    Object customerId = freezed,
    Object number = freezed,
    Object status = freezed,
  }) {
    return _then(_value.copyWith(
      orderId: orderId == freezed ? _value.orderId : orderId as String,
      customerId:
          customerId == freezed ? _value.customerId : customerId as String,
      number: number == freezed ? _value.number : number as int,
      status: status == freezed ? _value.status : status as String,
    ));
  }
}

/// @nodoc
abstract class _$OrderDtoCopyWith<$Res> implements $OrderDtoCopyWith<$Res> {
  factory _$OrderDtoCopyWith(_OrderDto value, $Res Function(_OrderDto) then) =
      __$OrderDtoCopyWithImpl<$Res>;
  @override
  $Res call(
      {@JsonKey(name: 'order_id', includeIfNull: false) String orderId,
      @JsonKey(name: 'customer_id', includeIfNull: false) String customerId,
      @JsonKey(includeIfNull: false) int number,
      @JsonKey(includeIfNull: false) String status});
}

/// @nodoc
class __$OrderDtoCopyWithImpl<$Res> extends _$OrderDtoCopyWithImpl<$Res>
    implements _$OrderDtoCopyWith<$Res> {
  __$OrderDtoCopyWithImpl(_OrderDto _value, $Res Function(_OrderDto) _then)
      : super(_value, (v) => _then(v as _OrderDto));

  @override
  _OrderDto get _value => super._value as _OrderDto;

  @override
  $Res call({
    Object orderId = freezed,
    Object customerId = freezed,
    Object number = freezed,
    Object status = freezed,
  }) {
    return _then(_OrderDto(
      orderId: orderId == freezed ? _value.orderId : orderId as String,
      customerId:
          customerId == freezed ? _value.customerId : customerId as String,
      number: number == freezed ? _value.number : number as int,
      status: status == freezed ? _value.status : status as String,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_OrderDto implements _OrderDto {
  const _$_OrderDto(
      {@JsonKey(name: 'order_id', includeIfNull: false) this.orderId,
      @JsonKey(name: 'customer_id', includeIfNull: false) this.customerId,
      @JsonKey(includeIfNull: false) this.number,
      @JsonKey(includeIfNull: false) this.status});

  factory _$_OrderDto.fromJson(Map<String, dynamic> json) =>
      _$_$_OrderDtoFromJson(json);

  @override
  @JsonKey(name: 'order_id', includeIfNull: false)
  final String orderId;
  @override
  @JsonKey(name: 'customer_id', includeIfNull: false)
  final String customerId;
  @override
  @JsonKey(includeIfNull: false)
  final int number;
  @override
  @JsonKey(includeIfNull: false)
  final String status;

  @override
  String toString() {
    return 'OrderDto(orderId: $orderId, customerId: $customerId, number: $number, status: $status)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _OrderDto &&
            (identical(other.orderId, orderId) ||
                const DeepCollectionEquality()
                    .equals(other.orderId, orderId)) &&
            (identical(other.customerId, customerId) ||
                const DeepCollectionEquality()
                    .equals(other.customerId, customerId)) &&
            (identical(other.number, number) ||
                const DeepCollectionEquality().equals(other.number, number)) &&
            (identical(other.status, status) ||
                const DeepCollectionEquality().equals(other.status, status)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(orderId) ^
      const DeepCollectionEquality().hash(customerId) ^
      const DeepCollectionEquality().hash(number) ^
      const DeepCollectionEquality().hash(status);

  @override
  _$OrderDtoCopyWith<_OrderDto> get copyWith =>
      __$OrderDtoCopyWithImpl<_OrderDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_OrderDtoToJson(this);
  }
}

abstract class _OrderDto implements OrderDto {
  const factory _OrderDto(
      {@JsonKey(name: 'order_id', includeIfNull: false) String orderId,
      @JsonKey(name: 'customer_id', includeIfNull: false) String customerId,
      @JsonKey(includeIfNull: false) int number,
      @JsonKey(includeIfNull: false) String status}) = _$_OrderDto;

  factory _OrderDto.fromJson(Map<String, dynamic> json) = _$_OrderDto.fromJson;

  @override
  @JsonKey(name: 'order_id', includeIfNull: false)
  String get orderId;
  @override
  @JsonKey(name: 'customer_id', includeIfNull: false)
  String get customerId;
  @override
  @JsonKey(includeIfNull: false)
  int get number;
  @override
  @JsonKey(includeIfNull: false)
  String get status;
  @override
  _$OrderDtoCopyWith<_OrderDto> get copyWith;
}
