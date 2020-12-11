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

class WebFrontendBar extends HookWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final googleAuth = useProvider(googleAuthenticationProvider).state;
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.arrow_forward),
          const SizedBox(
            width: 10.0,
          ),
          const SelectableText('Web Frontend Example'),
          const Spacer(),
          if (googleAuth == null)
            IconButton(
              icon: Image.asset(
                  'assets/images/btn_google_signin_light_normal_web@2x.png'),
              iconSize: 150.0,
              onPressed: () async {
                context.read(webFrontendViewControllerProvider).googleSignIn();
              },
            )
          else
            RaisedButton(
              onPressed: () async {
                context.read(webFrontendViewControllerProvider).googleSignOut();
              },
              child: const Text('Signout from Google'),
            ),
        ],
      ),
    );
  }
}
