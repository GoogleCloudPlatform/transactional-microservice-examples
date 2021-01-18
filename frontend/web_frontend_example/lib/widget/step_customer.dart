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

import '../entity/customer.dart';
import '../provider/web_frontend_providers.dart';
import '../utils.dart';
import 'usecase_stepper.dart';

class StepCustomer extends HookWidget {
  StepCustomer(this.customerIdController, this.initialCreditController);

  final TextEditingController customerIdController;
  final TextEditingController initialCreditController;

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
        Text('Created a customer', style: TextStyle(fontSize: 18)),
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
        Text('Failed to create a customer', style: TextStyle(fontSize: 18)),
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
    final loadingStepCustomer = useProvider(loadingStepCustomerProvider).state;
    return Container(
      color: Colors.grey[300],
      child: Container(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: UsecaseStepper(),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Card(
                  child: Container(
                    width: 300,
                    color: Colors.white,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const SelectableText(
                            'Create a customer',
                            style: TextStyle(
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 200,
                            child: TextField(
                              controller: customerIdController,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.person),
                                labelText: 'Customer ID',
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            width: 200,
                            child: TextField(
                              controller: initialCreditController,
                              decoration: const InputDecoration(
                                icon: Icon(Icons.attach_money),
                                labelText: 'Initial credit',
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: loadingStepCustomer
                                ? const Center(
                                    child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator()),
                                  )
                                : FlatButton.icon(
                                    icon: const Icon(
                                      Icons.people,
                                      color: Colors.white,
                                    ),
                                    color: Colors.blue,
                                    onPressed: () async {
                                      _onPressed(context);
                                    },
                                    label: const Text(
                                      'Create',
                                      style: TextStyle(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
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

    final customerDto = CustomerDto(
      customerId: customerIdController.text,
      limit: int.parse(initialCreditController.text),
    );
    context
        .read(orderUsecaseViewControllerProvider)
        .startLoadingOnStepCustomer();
    Customer customer;
    try {
      customer = await context
          .read(orderUsecaseViewControllerProvider)
          .createCustomer(customerDto);
    } catch (e) {
      print('error');
      ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
      return;
    } finally {
      context
          .read(orderUsecaseViewControllerProvider)
          .stopLoadingOnStepCustomer();
    }
    ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
    context
        .read(orderUsecaseViewControllerProvider)
        .setCurrentCustomer(customer);
    print(context.read(currentCustomerProvider).state);
    _clearTextFields();
    context.read(orderUsecaseViewControllerProvider).proceedStep('cart');
  }

  bool _isValid() {
    final validators = [
      _isValidCustomerId(),
      _isValidInitialCredit(),
    ];
    return validators.every((element) => element == true);
  }

  bool _isValidInitialCredit() {
    final validators = [
      initialCreditController.text.isNotEmpty,
      isInteger(initialCreditController.text),
    ];
    if (isInteger(initialCreditController.text)) {
      validators.add(int.parse(initialCreditController.text) > 0);
    }
    return validators.every((element) => element == true);
  }

  bool _isValidCustomerId() {
    final validators = [
      customerIdController.text.isNotEmpty,
    ];
    return validators.every((element) => element == true);
  }

  void _clearTextFields() {
    customerIdController.clear();
    initialCreditController.clear();
  }
}
