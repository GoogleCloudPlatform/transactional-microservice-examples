/*
  Copyright 2021 Google Inc.

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
import 'package:web_frontend_example/entity/order.dart';

import '../provider/web_frontend_providers.dart';
import '../utils.dart';

class Subtotal extends HookWidget {
  Subtotal(this.quantityController);
  final TextEditingController quantityController;

  final successSnackBar = SnackBar(
    backgroundColor: Colors.green,
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.thumb_up,
          color: Colors.white,
        ),
        SizedBox(width: 20),
        Text('Submitted an order', style: TextStyle(fontSize: 18)),
      ],
    ),
  );

  final failureSnackBar = SnackBar(
    backgroundColor: Colors.red,
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.thumb_down,
          color: Colors.white,
        ),
        SizedBox(width: 20),
        Text('Failed to submit an order', style: TextStyle(fontSize: 18)),
      ],
    ),
  );

  final invalidSnackBar = SnackBar(
    backgroundColor: Colors.red,
    duration: const Duration(seconds: 2),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.thumb_down,
          color: Colors.white,
        ),
        SizedBox(width: 20),
        Text('Input correct values', style: TextStyle(fontSize: 18)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final currentQuantity = useProvider(currentQuantityProvider).state;
    final loadingStepCart = useProvider(loadingStepCartProvider).state;
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Card(
        child: Container(
          width: 200,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SelectableText(
                  'Subtotal:',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
                SelectableText(
                  r'$' '${currentQuantity * 100}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
                Container(
                  height: 100,
                  child: Center(
                    child: SizedBox(
                      width: double.infinity,
                      height: 40,
                      child: loadingStepCart
                          ? const Center(
                              child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: CircularProgressIndicator()),
                            )
                          : FlatButton.icon(
                              icon: const Icon(
                                Icons.card_giftcard,
                                color: Colors.white,
                              ),
                              color: Colors.blue,
                              onPressed: () {
                                _onPressed(context);
                              },
                              label: const Text(
                                'Submit order',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    if (!_isValid()) {
      ScaffoldMessenger.of(context).showSnackBar(invalidSnackBar);
      return;
    }
    print(context.read(currentCustomerProvider).state);
    final orderDto = OrderDto(
      customerId: context.read(currentCustomerProvider).state.customerId,
      number: int.parse(quantityController.text),
    );
    context.read(orderUsecaseViewControllerProvider).startLoadingOnStepCart();
    Order order;
    try {
      order = await context
          .read(orderUsecaseViewControllerProvider)
          .submitOrder(orderDto);
    } catch (e) {
      print('error');
      ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
      return;
    } finally {
      context.read(orderUsecaseViewControllerProvider).stopLoadingOnStepCart();
    }
    ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
    _clearTextFields();
    context.read(orderUsecaseViewControllerProvider).setCurrentOrder(order);
    context.read(orderUsecaseViewControllerProvider).proceedStep('confirm');
  }

  bool _isValid() {
    final validators = [
      _isValidQuantity(),
    ];
    return validators.every((element) => element == true);
  }

  bool _isValidQuantity() {
    final validators = [
      quantityController.text.isNotEmpty,
      isInteger(quantityController.text),
    ];
    if (isInteger(quantityController.text)) {
      validators.add(int.parse(quantityController.text) > 0);
    }
    return validators.every((element) => element == true);
  }

  void _clearTextFields() {
    quantityController.clear();
  }
}
