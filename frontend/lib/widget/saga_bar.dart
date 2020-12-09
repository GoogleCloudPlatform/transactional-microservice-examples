import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../provider/saga_frontend_providers.dart';

class SagaBar extends HookWidget implements PreferredSizeWidget {
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
          const SelectableText('Saga Frontend Demo'),
          const Spacer(),
          if (googleAuth == null)
            IconButton(
              icon: Image.asset(
                  'assets/images/btn_google_signin_light_normal_web@2x.png'),
              iconSize: 150.0,
              onPressed: () async {
                context.read(sagaFrontendViewControllerProvider).googleSignIn();
              },
            )
          else
            RaisedButton(
              onPressed: () async {
                context
                    .read(sagaFrontendViewControllerProvider)
                    .googleSignOut();
              },
              child: const Text('Signout from Google'),
            ),
        ],
      ),
    );
  }
}
