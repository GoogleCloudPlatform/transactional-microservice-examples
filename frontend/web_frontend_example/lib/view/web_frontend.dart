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

import '../widget/endpoint_bar.dart';
import '../widget/left_menu.dart';
import '../widget/request_json.dart';
import '../widget/result_json.dart';
import '../widget/text_fields.dart';
import '../widget/web_frontend_bar.dart';

class WebFrontend extends HookWidget {
  static String id = '/admin';

  @override
  Widget build(BuildContext context) {
    final customerIdController = useTextEditingController();
    final limitController = useTextEditingController();
    final numberController = useTextEditingController();
    final orderIdController = useTextEditingController();
    final orderStatusController = useTextEditingController();

    return Scaffold(
      appBar: WebFrontendBar(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 1,
            child: LeftMenu(
              customerIdController: customerIdController,
              limitController: limitController,
              numberController: numberController,
              orderIdController: orderIdController,
              orderStatusController: orderStatusController,
            ),
          ),
          Expanded(
            flex: 4,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 1,
                  child: EndpointBar(
                    customerIdController: customerIdController,
                    limitController: limitController,
                    numberController: numberController,
                    orderIdController: orderIdController,
                    orderStatusController: orderStatusController,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: Theme.of(context).backgroundColor,
                          width: 1,
                        ),
                      ),
                    ),
                    child: TextFields(
                      customerIdController: customerIdController,
                      numberController: numberController,
                      limitController: limitController,
                      orderIdController: orderIdController,
                      orderStatusController: orderStatusController,
                    ),
                  ),
                ),
                Expanded(
                  flex: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Container(
                          child: RequestJson(),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          child: ResultJson(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
