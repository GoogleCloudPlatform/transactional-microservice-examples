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

import '../provider/web_frontend_providers.dart';

class UsecaseStepper extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final currentStep = useProvider(currentStepProvider).state;
    final currentAsyncProcess = useProvider(currentAsyncProcessProvider).state;

    return Card(
      child: Container(
        color: Colors.white,
        height: 70,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _showProcess(currentStep, currentAsyncProcess),
            Center(
              child: Container(
                width: 370,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: (currentStep == 'process')
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.alt_route,
                                  color: Colors.blueAccent,
                                ),
                                SelectableText(
                                  'Process',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.alt_route,
                                ),
                                SelectableText(
                                  'Process',
                                ),
                              ],
                            ),
                    ),
                    const Expanded(
                      child: Divider(
                        thickness: 2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: (currentStep == 'customer')
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.people,
                                  color: Colors.blueAccent,
                                ),
                                SelectableText(
                                  'Customer',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.people,
                                ),
                                SelectableText(
                                  'Customer',
                                ),
                              ],
                            ),
                    ),
                    const Expanded(
                      child: Divider(
                        thickness: 2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: (currentStep == 'cart')
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.shopping_cart,
                                  color: Colors.blueAccent,
                                ),
                                SelectableText(
                                  'Cart',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.shopping_cart,
                                ),
                                SelectableText(
                                  'Cart',
                                ),
                              ],
                            ),
                    ),
                    const Expanded(
                      child: Divider(
                        thickness: 2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: (currentStep == 'confirm')
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.payment,
                                  color: Colors.blueAccent,
                                ),
                                SelectableText(
                                  'Confirm',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.payment,
                                ),
                                SelectableText(
                                  'Confirm',
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Container(),
          ],
        ),
      ),
    );
  }

  Widget _showProcess(String step, bool isAsync) {
    if (step == 'process') {
      return const SizedBox.shrink();
    }
    if (isAsync) {
      return Card(
        child: Container(
          height: 50,
          width: 80,
          color: Colors.green,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(
                Icons.double_arrow,
                color: Colors.white,
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                'Async',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return Card(
      child: Container(
        height: 50,
        width: 80,
        color: Colors.green,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.white,
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              'Sync',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
