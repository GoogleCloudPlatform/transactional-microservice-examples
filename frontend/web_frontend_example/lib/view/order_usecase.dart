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
import 'package:hooks_riverpod/all.dart';

import '../provider/web_frontend_providers.dart';
import '../widget/step_cart.dart';
import '../widget/step_confirm.dart';
import '../widget/step_customer.dart';
import '../widget/step_process.dart';
import '../widget/web_frontend_bar.dart';

class OrderUsecase extends HookWidget {
  static String id = '/usecase';

  @override
  Widget build(BuildContext context) {
    final quantityController = useTextEditingController();
    final customerIdController = useTextEditingController();
    final initialCreditController = useTextEditingController();
    final currentStep = useProvider(currentStepProvider).state;
    return Scaffold(
      appBar: WebFrontendBar(),
      body: _getCurrentStepWidget(currentStep, customerIdController,
          initialCreditController, quantityController),
    );
  }

  Widget _getCurrentStepWidget(
      String currentStep,
      TextEditingController customerIdController,
      TextEditingController initialCreditController,
      TextEditingController quantityController) {
    switch (currentStep) {
      case 'process':
        return StepProcess();
      case 'customer':
        return StepCustomer(customerIdController, initialCreditController);
      case 'cart':
        return StepCart(quantityController);
      case 'confirm':
        return StepConfirm(quantityController);
    }
    return StepCustomer(customerIdController, initialCreditController);
  }
}
