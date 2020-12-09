import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../provider/saga_frontend_providers.dart';

class EndpointBar extends HookWidget {
  const EndpointBar({
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
    final methods = useProvider(methodsProvider);
    final selectedMethod = useProvider(selectedMethodProvider).state;
    final isAsync = useProvider(isAsyncProvider).state;

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).backgroundColor,
            width: 1,
          ),
          bottom: BorderSide(
            color: Theme.of(context).backgroundColor,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            const Text(
              'Sync',
              style: TextStyle(fontSize: 16),
            ),
            Switch(
              value: isAsync,
              onChanged: (value) {
                context
                    .read(sagaFrontendViewControllerProvider)
                    .updateAsyncOrSync(value);
                customerIdController.clear();
                limitController.clear();
                numberController.clear();
                orderIdController.clear();
                orderStatusController.clear();
              },
            ),
            const Text(
              'Async',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(
              width: 30,
            ),
            Container(
              child: DropdownButton<String>(
                value: selectedMethod,
                onChanged: (String method) {
                  context
                      .read(sagaFrontendViewControllerProvider)
                      .updateMethod(method);
                  customerIdController.clear();
                  limitController.clear();
                  numberController.clear();
                  orderIdController.clear();
                  orderStatusController.clear();
                },
                icon: const Icon(Icons.arrow_drop_down),
                items: methods.map<DropdownMenuItem<String>>(
                  (String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  },
                ).toList(),
              ),
            ),
            const SizedBox(
              width: 30,
            ),
            FlatButton(
              color: Theme.of(context).buttonColor,
              child: const Text(
                'Send!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                context
                    .read(sagaFrontendViewControllerProvider)
                    .updateResultJson();
              },
            ),
          ],
        ),
      ),
    );
  }
}
