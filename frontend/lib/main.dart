import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'view/saga_frontend.dart';

void main() {
  runApp(
    ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Saga Frontend Demo',
        theme: ThemeData.dark(),
        home: SagaFrontend(),
      ),
    ),
  );
}
