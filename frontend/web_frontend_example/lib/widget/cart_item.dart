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
import '../utils.dart';

class CartItem extends HookWidget {
  const CartItem(this.quantityController);
  final TextEditingController quantityController;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SelectableText(
                  'Shopping cart',
                  style: TextStyle(
                    fontSize: 28,
                  ),
                ),
                const Divider(
                  thickness: 1,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Container(
                        child: Center(
                          child: Image.network(
                              'https://cdn.pixabay.com/photo/2015/09/24/12/05/ear-phone-955352_960_720.png'),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 4,
                      child: Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              child: SelectableText(
                                'High Quality Ear Phone (2021 model)',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.blue[900],
                                ),
                              ),
                            ),
                            Container(
                              child: SelectableText(
                                'Category: Audio / Equipments',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ),
                            const Divider(
                              thickness: 1,
                            ),
                            Container(
                              child: const SelectableText(
                                'In Stock',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: 100,
                              height: 50,
                              child: TextField(
                                controller: quantityController,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  labelText: 'Qty',
                                ),
                                onChanged: (value) {
                                  if (value.isEmpty) {
                                    context
                                        .read(
                                            orderUsecaseViewControllerProvider)
                                        .updateQuantity(0);
                                  } else if (isInteger(value)) {
                                    context
                                        .read(
                                            orderUsecaseViewControllerProvider)
                                        .updateQuantity(int.parse(value));
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        child: const SelectableText(
                          r'$100',
                          textAlign: TextAlign.end,
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
