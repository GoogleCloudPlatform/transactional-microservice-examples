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

part of 'customer.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;
Customer _$CustomerFromJson(Map<String, dynamic> json) {
  return _Customer.fromJson(json);
}

/// @nodoc
class _$CustomerTearOff {
  const _$CustomerTearOff();

// ignore: unused_element
  _Customer call(
      {@JsonKey(name: 'customer_id') String customerId,
      int credit,
      int limit}) {
    return _Customer(
      customerId: customerId,
      credit: credit,
      limit: limit,
    );
  }

// ignore: unused_element
  Customer fromJson(Map<String, Object> json) {
    return Customer.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $Customer = _$CustomerTearOff();

/// @nodoc
mixin _$Customer {
  @JsonKey(name: 'customer_id')
  String get customerId;
  int get credit;
  int get limit;

  Map<String, dynamic> toJson();
  $CustomerCopyWith<Customer> get copyWith;
}

/// @nodoc
abstract class $CustomerCopyWith<$Res> {
  factory $CustomerCopyWith(Customer value, $Res Function(Customer) then) =
      _$CustomerCopyWithImpl<$Res>;
  $Res call(
      {@JsonKey(name: 'customer_id') String customerId, int credit, int limit});
}

/// @nodoc
class _$CustomerCopyWithImpl<$Res> implements $CustomerCopyWith<$Res> {
  _$CustomerCopyWithImpl(this._value, this._then);

  final Customer _value;
  // ignore: unused_field
  final $Res Function(Customer) _then;

  @override
  $Res call({
    Object customerId = freezed,
    Object credit = freezed,
    Object limit = freezed,
  }) {
    return _then(_value.copyWith(
      customerId:
          customerId == freezed ? _value.customerId : customerId as String,
      credit: credit == freezed ? _value.credit : credit as int,
      limit: limit == freezed ? _value.limit : limit as int,
    ));
  }
}

/// @nodoc
abstract class _$CustomerCopyWith<$Res> implements $CustomerCopyWith<$Res> {
  factory _$CustomerCopyWith(_Customer value, $Res Function(_Customer) then) =
      __$CustomerCopyWithImpl<$Res>;
  @override
  $Res call(
      {@JsonKey(name: 'customer_id') String customerId, int credit, int limit});
}

/// @nodoc
class __$CustomerCopyWithImpl<$Res> extends _$CustomerCopyWithImpl<$Res>
    implements _$CustomerCopyWith<$Res> {
  __$CustomerCopyWithImpl(_Customer _value, $Res Function(_Customer) _then)
      : super(_value, (v) => _then(v as _Customer));

  @override
  _Customer get _value => super._value as _Customer;

  @override
  $Res call({
    Object customerId = freezed,
    Object credit = freezed,
    Object limit = freezed,
  }) {
    return _then(_Customer(
      customerId:
          customerId == freezed ? _value.customerId : customerId as String,
      credit: credit == freezed ? _value.credit : credit as int,
      limit: limit == freezed ? _value.limit : limit as int,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_Customer implements _Customer {
  const _$_Customer(
      {@JsonKey(name: 'customer_id') this.customerId, this.credit, this.limit});

  factory _$_Customer.fromJson(Map<String, dynamic> json) =>
      _$_$_CustomerFromJson(json);

  @override
  @JsonKey(name: 'customer_id')
  final String customerId;
  @override
  final int credit;
  @override
  final int limit;

  @override
  String toString() {
    return 'Customer(customerId: $customerId, credit: $credit, limit: $limit)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _Customer &&
            (identical(other.customerId, customerId) ||
                const DeepCollectionEquality()
                    .equals(other.customerId, customerId)) &&
            (identical(other.credit, credit) ||
                const DeepCollectionEquality().equals(other.credit, credit)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(customerId) ^
      const DeepCollectionEquality().hash(credit) ^
      const DeepCollectionEquality().hash(limit);

  @override
  _$CustomerCopyWith<_Customer> get copyWith =>
      __$CustomerCopyWithImpl<_Customer>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_CustomerToJson(this);
  }
}

abstract class _Customer implements Customer {
  const factory _Customer(
      {@JsonKey(name: 'customer_id') String customerId,
      int credit,
      int limit}) = _$_Customer;

  factory _Customer.fromJson(Map<String, dynamic> json) = _$_Customer.fromJson;

  @override
  @JsonKey(name: 'customer_id')
  String get customerId;
  @override
  int get credit;
  @override
  int get limit;
  @override
  _$CustomerCopyWith<_Customer> get copyWith;
}

CustomerDto _$CustomerDtoFromJson(Map<String, dynamic> json) {
  return _CustomerDto.fromJson(json);
}

/// @nodoc
class _$CustomerDtoTearOff {
  const _$CustomerDtoTearOff();

// ignore: unused_element
  _CustomerDto call(
      {@JsonKey(name: 'customer_id', includeIfNull: false) String customerId,
      @JsonKey(includeIfNull: false) int number,
      @JsonKey(includeIfNull: false) int limit}) {
    return _CustomerDto(
      customerId: customerId,
      number: number,
      limit: limit,
    );
  }

// ignore: unused_element
  CustomerDto fromJson(Map<String, Object> json) {
    return CustomerDto.fromJson(json);
  }
}

/// @nodoc
// ignore: unused_element
const $CustomerDto = _$CustomerDtoTearOff();

/// @nodoc
mixin _$CustomerDto {
  @JsonKey(name: 'customer_id', includeIfNull: false)
  String get customerId;
  @JsonKey(includeIfNull: false)
  int get number;
  @JsonKey(includeIfNull: false)
  int get limit;

  Map<String, dynamic> toJson();
  $CustomerDtoCopyWith<CustomerDto> get copyWith;
}

/// @nodoc
abstract class $CustomerDtoCopyWith<$Res> {
  factory $CustomerDtoCopyWith(
          CustomerDto value, $Res Function(CustomerDto) then) =
      _$CustomerDtoCopyWithImpl<$Res>;
  $Res call(
      {@JsonKey(name: 'customer_id', includeIfNull: false) String customerId,
      @JsonKey(includeIfNull: false) int number,
      @JsonKey(includeIfNull: false) int limit});
}

/// @nodoc
class _$CustomerDtoCopyWithImpl<$Res> implements $CustomerDtoCopyWith<$Res> {
  _$CustomerDtoCopyWithImpl(this._value, this._then);

  final CustomerDto _value;
  // ignore: unused_field
  final $Res Function(CustomerDto) _then;

  @override
  $Res call({
    Object customerId = freezed,
    Object number = freezed,
    Object limit = freezed,
  }) {
    return _then(_value.copyWith(
      customerId:
          customerId == freezed ? _value.customerId : customerId as String,
      number: number == freezed ? _value.number : number as int,
      limit: limit == freezed ? _value.limit : limit as int,
    ));
  }
}

/// @nodoc
abstract class _$CustomerDtoCopyWith<$Res>
    implements $CustomerDtoCopyWith<$Res> {
  factory _$CustomerDtoCopyWith(
          _CustomerDto value, $Res Function(_CustomerDto) then) =
      __$CustomerDtoCopyWithImpl<$Res>;
  @override
  $Res call(
      {@JsonKey(name: 'customer_id', includeIfNull: false) String customerId,
      @JsonKey(includeIfNull: false) int number,
      @JsonKey(includeIfNull: false) int limit});
}

/// @nodoc
class __$CustomerDtoCopyWithImpl<$Res> extends _$CustomerDtoCopyWithImpl<$Res>
    implements _$CustomerDtoCopyWith<$Res> {
  __$CustomerDtoCopyWithImpl(
      _CustomerDto _value, $Res Function(_CustomerDto) _then)
      : super(_value, (v) => _then(v as _CustomerDto));

  @override
  _CustomerDto get _value => super._value as _CustomerDto;

  @override
  $Res call({
    Object customerId = freezed,
    Object number = freezed,
    Object limit = freezed,
  }) {
    return _then(_CustomerDto(
      customerId:
          customerId == freezed ? _value.customerId : customerId as String,
      number: number == freezed ? _value.number : number as int,
      limit: limit == freezed ? _value.limit : limit as int,
    ));
  }
}

@JsonSerializable()

/// @nodoc
class _$_CustomerDto implements _CustomerDto {
  const _$_CustomerDto(
      {@JsonKey(name: 'customer_id', includeIfNull: false) this.customerId,
      @JsonKey(includeIfNull: false) this.number,
      @JsonKey(includeIfNull: false) this.limit});

  factory _$_CustomerDto.fromJson(Map<String, dynamic> json) =>
      _$_$_CustomerDtoFromJson(json);

  @override
  @JsonKey(name: 'customer_id', includeIfNull: false)
  final String customerId;
  @override
  @JsonKey(includeIfNull: false)
  final int number;
  @override
  @JsonKey(includeIfNull: false)
  final int limit;

  @override
  String toString() {
    return 'CustomerDto(customerId: $customerId, number: $number, limit: $limit)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other is _CustomerDto &&
            (identical(other.customerId, customerId) ||
                const DeepCollectionEquality()
                    .equals(other.customerId, customerId)) &&
            (identical(other.number, number) ||
                const DeepCollectionEquality().equals(other.number, number)) &&
            (identical(other.limit, limit) ||
                const DeepCollectionEquality().equals(other.limit, limit)));
  }

  @override
  int get hashCode =>
      runtimeType.hashCode ^
      const DeepCollectionEquality().hash(customerId) ^
      const DeepCollectionEquality().hash(number) ^
      const DeepCollectionEquality().hash(limit);

  @override
  _$CustomerDtoCopyWith<_CustomerDto> get copyWith =>
      __$CustomerDtoCopyWithImpl<_CustomerDto>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$_$_CustomerDtoToJson(this);
  }
}

abstract class _CustomerDto implements CustomerDto {
  const factory _CustomerDto(
      {@JsonKey(name: 'customer_id', includeIfNull: false) String customerId,
      @JsonKey(includeIfNull: false) int number,
      @JsonKey(includeIfNull: false) int limit}) = _$_CustomerDto;

  factory _CustomerDto.fromJson(Map<String, dynamic> json) =
      _$_CustomerDto.fromJson;

  @override
  @JsonKey(name: 'customer_id', includeIfNull: false)
  String get customerId;
  @override
  @JsonKey(includeIfNull: false)
  int get number;
  @override
  @JsonKey(includeIfNull: false)
  int get limit;
  @override
  _$CustomerDtoCopyWith<_CustomerDto> get copyWith;
}
