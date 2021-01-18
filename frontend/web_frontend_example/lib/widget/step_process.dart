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
import 'usecase_stepper.dart';

class StepProcess extends HookWidget {
  final notSignedInSnackBar = SnackBar(
    backgroundColor: Colors.red,
    content: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(
          Icons.thumb_down,
          color: Colors.white,
        ),
        SizedBox(width: 20),
        Text('Sign in with Google', style: TextStyle(fontSize: 18)),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
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
                            'Select process',
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
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: FlatButton.icon(
                              icon: const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                              color: Colors.blue,
                              onPressed: () {
                                _proceed(context, false);
                              },
                              label: const Text(
                                'Sync',
                                style: TextStyle(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          SizedBox(
                            width: 200,
                            height: 40,
                            child: FlatButton.icon(
                              icon: const Icon(
                                Icons.double_arrow_outlined,
                                color: Colors.white,
                              ),
                              color: Colors.blue,
                              onPressed: () {
                                _proceed(context, true);
                              },
                              label: const Text(
                                'Async',
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

  void _proceed(BuildContext context, bool isAsync) {
    if (!context.read(orderUsecaseViewControllerProvider).isSignedIn()) {
      ScaffoldMessenger.of(context).showSnackBar(notSignedInSnackBar);
      return;
    }
    context
        .read(orderUsecaseViewControllerProvider)
        .setCurrentAsyncProcess(isAsync);
    context.read(orderUsecaseViewControllerProvider).proceedStep('customer');
  }
}
