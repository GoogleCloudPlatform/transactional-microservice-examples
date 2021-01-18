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
import '../view/order_usecase.dart';
import '../view/web_frontend.dart';

class WebFrontendBar extends HookWidget implements PreferredSizeWidget {
  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    final googleAuth = useProvider(googleAuthenticationProvider).state;
    final isUsecase = useProvider(isUsecaseProvider).state;

    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.arrow_forward),
          const SizedBox(
            width: 10.0,
          ),
          const Expanded(
            child: SelectableText('Web Frontend Example'),
          ),
          if (isUsecase)
            FlatButton(
              height: 38,
              color: Colors.white,
              onPressed: () {
                _toggleView(context);
              },
              child: Text(
                'To Admin',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            )
          else
            FlatButton(
              height: 38,
              color: Theme.of(context).buttonColor,
              onPressed: () {
                _toggleView(context);
              },
              child: const Text(
                'To Usecase',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
          const SizedBox(
            width: 10,
          ),
          if (googleAuth == null)
            SizedBox(
              height: 40,
              width: 140,
              child: IconButton(
                padding: const EdgeInsets.all(0.0),
                icon: isUsecase
                    ? Image.asset(
                        'assets/images/btn_google_signin_light_normal_web@2x.png')
                    : Image.asset(
                        'assets/images/btn_google_signin_dark_normal_web@2x.png'),
                onPressed: () async {
                  context
                      .read(webFrontendViewControllerProvider)
                      .googleSignIn();
                },
              ),
            )
          else
            FlatButton(
              color: Theme.of(context).buttonColor,
              height: 38,
              onPressed: () async {
                context.read(webFrontendViewControllerProvider).googleSignOut();
              },
              child: const Text(
                'Signout from Google',
                style: TextStyle(
                  fontSize: 11,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _toggleView(BuildContext context) {
    final isUsecase = context.read(isUsecaseProvider).state;
    if (isUsecase) {
      context.read(isUsecaseProvider).state = false;
      Navigator.pushReplacementNamed(context, WebFrontend.id);
    } else {
      context.read(isUsecaseProvider).state = true;
      Navigator.pushReplacementNamed(context, OrderUsecase.id);
    }
  }
}
