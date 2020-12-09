import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import '../widget/endpoint_bar.dart';
import '../widget/left_menu.dart';
import '../widget/request_json.dart';
import '../widget/result_json.dart';
import '../widget/saga_bar.dart';
import '../widget/text_fields.dart';

class SagaFrontend extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final customerIdController = useTextEditingController();
    final limitController = useTextEditingController();
    final numberController = useTextEditingController();
    final orderIdController = useTextEditingController();
    final orderStatusController = useTextEditingController();

    return Scaffold(
      appBar: SagaBar(),
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
