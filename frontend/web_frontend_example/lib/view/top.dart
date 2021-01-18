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
import 'order_usecase.dart';
import 'web_frontend.dart';

class Top extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final isUsecase = useProvider(isUsecaseProvider).state;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saga Frontend Demo',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isUsecase ? ThemeMode.light : ThemeMode.dark,
      initialRoute: WebFrontend.id,
      routes: {
        WebFrontend.id: (_) => WebFrontend(),
        OrderUsecase.id: (_) => OrderUsecase(),
      },
    );
  }
}
