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
import '../provider/web_frontend_providers.dart';

class LeftMenu extends HookWidget {
  const LeftMenu({
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
    final menus = useProvider(menusProvider);
    final selectedMenu = useProvider(selectedMenuProvider).state;

    return ListView.builder(
      itemCount: menus.length,
      itemBuilder: (BuildContext context, int index) {
        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                width: 1.0,
                color: Theme.of(context).backgroundColor,
              ),
            ),
          ),
          child: ListTile(
            leading: menus[index].icon,
            title: Text(
              menus[index].name,
              style: const TextStyle(
                fontSize: 18.0,
              ),
            ),
            onTap: () {
              if (context
                  .read(webFrontendViewControllerProvider)
                  .willUpdateMethod(menus[index].name)) {
                context
                    .read(webFrontendViewControllerProvider)
                    .updateMenu(menus[index].name);
                customerIdController.clear();
                limitController.clear();
                numberController.clear();
                orderIdController.clear();
                orderStatusController.clear();
              }
            },
            selected: menus[index].name == selectedMenu,
          ),
        );
      },
    );
  }
}
