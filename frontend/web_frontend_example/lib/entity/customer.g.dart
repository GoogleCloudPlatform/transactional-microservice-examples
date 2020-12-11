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

part of 'customer.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_Customer _$_$_CustomerFromJson(Map json) {
  return _$_Customer(
    customerId: json['customer_id'] as String,
    credit: json['credit'] as int,
    limit: json['limit'] as int,
  );
}

Map<String, dynamic> _$_$_CustomerToJson(_$_Customer instance) =>
    <String, dynamic>{
      'customer_id': instance.customerId,
      'credit': instance.credit,
      'limit': instance.limit,
    };

_$_CustomerDto _$_$_CustomerDtoFromJson(Map json) {
  return _$_CustomerDto(
    customerId: json['customer_id'] as String,
    number: json['number'] as int,
    limit: json['limit'] as int,
  );
}

Map<String, dynamic> _$_$_CustomerDtoToJson(_$_CustomerDto instance) {
  final val = <String, dynamic>{};

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('customer_id', instance.customerId);
  writeNotNull('number', instance.number);
  writeNotNull('limit', instance.limit);
  return val;
}
