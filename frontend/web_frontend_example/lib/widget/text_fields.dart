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

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../constants.dart';
import '../entity/customer.dart';
import '../entity/order.dart';
import '../provider/web_frontend_providers.dart';
import '../utils.dart';

class TextFields extends HookWidget {
  const TextFields({
    this.customerIdController,
    this.limitController,
    this.numberController,
    this.orderIdController,
    this.orderStatusController,
  });

  final TextEditingController customerIdController;
  final TextEditingController limitController;
  final TextEditingController numberController;
  final TextEditingController orderIdController;
  final TextEditingController orderStatusController;

  @override
  Widget build(BuildContext context) {
    final textFields = <TextField>[];
    final menu = useProvider(selectedMenuProvider).state;

    if (menu == 'Customer') {
      final dto = useProvider(dtoProvider).state as CustomerDto;
      if (dto.customerId != null) {
        textFields.add(
          TextField(
            decoration: kTextInputDecoration.copyWith(
              hintText: 'xxxxxxxx (String)',
              labelText: 'customer_id',
            ),
            controller: customerIdController,
            onChanged: (String value) {
              context.read(dtoProvider).state = dto.copyWith(customerId: value);
            },
          ),
        );
      }
      if (dto.limit != null) {
        textFields.add(
          TextField(
            decoration: kTextInputDecoration.copyWith(
              hintText: 'xxxx (Number)',
              labelText: 'limit',
            ),
            controller: limitController,
            onChanged: (String value) {
              if (isNumeric(value)) {
                context.read(dtoProvider).state =
                    dto.copyWith(limit: int.parse(value));
              }
            },
          ),
        );
      }
      if (dto.number != null) {
        textFields.add(
          TextField(
            decoration: kTextInputDecoration.copyWith(
              hintText: 'xxxx (Number)',
              labelText: 'number',
            ),
            controller: numberController,
            onChanged: (String value) {
              if (isNumeric(value)) {
                context.read(dtoProvider).state =
                    dto.copyWith(number: int.parse(value));
              }
            },
          ),
        );
      }
    } else {
      final dto = useProvider(dtoProvider).state as OrderDto;
      if (dto.customerId != null) {
        textFields.add(
          TextField(
            decoration: kTextInputDecoration.copyWith(
              hintText: 'xxxxxxxx (String)',
              labelText: 'customer_id',
            ),
            controller: customerIdController,
            onChanged: (String value) {
              context.read(dtoProvider).state = dto.copyWith(customerId: value);
            },
          ),
        );
      }
      if (dto.number != null) {
        textFields.add(
          TextField(
            decoration: kTextInputDecoration.copyWith(
              hintText: 'xxxxx (Number)',
              labelText: 'number',
            ),
            controller: numberController,
            onChanged: (String value) {
              if (isNumeric(value)) {
                context.read(dtoProvider).state =
                    dto.copyWith(number: int.parse(value));
              }
            },
          ),
        );
      }
      if (dto.orderId != null) {
        textFields.add(
          TextField(
            decoration: kTextInputDecoration.copyWith(
              hintText: 'xxxxxxxx (String)',
              labelText: 'order_id',
            ),
            controller: orderIdController,
            onChanged: (String value) {
              context.read(dtoProvider).state = dto.copyWith(orderId: value);
            },
          ),
        );
      }
      if (dto.status != null) {
        textFields.add(
          TextField(
            decoration: kTextInputDecoration.copyWith(
              hintText: 'xxxxxx (String)',
              labelText: 'status',
            ),
            controller: orderStatusController,
            onChanged: (String value) {
              context.read(dtoProvider).state = dto.copyWith(status: value);
            },
          ),
        );
      }
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: textFields,
      ),
    );
  }
}
