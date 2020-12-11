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

class ResultJson extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final resultJson = useProvider(resultJsonProvider).state;
    final isRequesting = useProvider(isRequestingProvider).state;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).backgroundColor,
            width: 1,
          ),
          top: BorderSide(
            color: Theme.of(context).backgroundColor,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text(
              'Response',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline4.color,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            if (isRequesting)
              Center(
                child: Container(
                  child: const CircularProgressIndicator(),
                ),
              )
            else
              SelectableText(
                resultJson,
                style: TextStyle(
                  fontSize: 18.0,
                  color: Theme.of(context).textTheme.headline4.color,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
