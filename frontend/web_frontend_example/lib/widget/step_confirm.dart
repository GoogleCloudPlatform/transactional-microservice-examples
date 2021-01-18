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

import '../entity/order.dart';
import '../provider/web_frontend_providers.dart';
import 'usecase_stepper.dart';

class StepConfirm extends HookWidget {
  StepConfirm(this.quantityController);
  final TextEditingController quantityController;

  final failureRefreshSnackBar = SnackBar(
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

  @override
  Widget build(BuildContext context) {
    final currentAsyncProcess = useProvider(currentAsyncProcessProvider).state;
    final currentOrder = useProvider(currentOrderProvider).state;
    final loadingStepConfirmRefresh =
        useProvider(loadingStepConfirmRefreshProvider).state;

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
                            'Order details',
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
                            alignment: Alignment.bottomLeft,
                            width: 170,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SelectableText(
                                  'Quantity:',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const Spacer(),
                                SelectableText(
                                  currentOrder.number.toString(),
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            alignment: Alignment.bottomLeft,
                            width: 170,
                            height: 40,
                            decoration: BoxDecoration(
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                const SelectableText(
                                  'Status:',
                                  style: TextStyle(fontSize: 18),
                                ),
                                const Spacer(),
                                SelectableText(
                                  currentOrder.status,
                                  style: const TextStyle(fontSize: 18),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 40,
                          ),
                          if (currentAsyncProcess)
                            SizedBox(
                              width: 200,
                              height: 40,
                              child: loadingStepConfirmRefresh
                                  ? const Center(
                                      child: SizedBox(
                                        height: 40,
                                        width: 40,
                                        child: CircularProgressIndicator(),
                                      ),
                                    )
                                  : FlatButton.icon(
                                      icon: const Icon(
                                        Icons.refresh,
                                        color: Colors.white,
                                      ),
                                      color: Colors.green,
                                      onPressed: () async {
                                        _refreshOrder(context);
                                      },
                                      label: const Text(
                                        'Refresh',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                            )
                          else
                            const SizedBox.shrink(),
                          const SizedBox(
                            height: 30,
                          ),
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: FlatButton.icon(
                              icon: const Icon(
                                Icons.keyboard_return,
                                color: Colors.white,
                              ),
                              color: Colors.blue,
                              onPressed: () {
                                _startOver(context);
                              },
                              label: const Text(
                                'Start over',
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

  void _startOver(BuildContext context) {
    context.read(orderUsecaseViewControllerProvider).resetState();
    context.read(orderUsecaseViewControllerProvider).proceedStep('process');
  }

  Future<void> _refreshOrder(BuildContext context) async {
    final orderDto = OrderDto(
      customerId: context.read(currentCustomerProvider).state.customerId,
      orderId: context.read(currentOrderProvider).state.orderId,
    );
    context
        .read(orderUsecaseViewControllerProvider)
        .startLoadingOnStepConfirmRefresh();
    Order order;
    try {
      order = await context
          .read(orderUsecaseViewControllerProvider)
          .getOrder(orderDto);
    } catch (e) {
      print('error');
      ScaffoldMessenger.of(context).showSnackBar(failureRefreshSnackBar);
      return;
    } finally {
      context
          .read(orderUsecaseViewControllerProvider)
          .stopLoadingOnStepConfirmRefresh();
    }
    context.read(orderUsecaseViewControllerProvider).setCurrentOrder(order);
  }
}
