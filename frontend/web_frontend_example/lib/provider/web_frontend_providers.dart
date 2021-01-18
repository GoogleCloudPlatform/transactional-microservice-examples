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

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../entity/customer.dart';
import '../entity/memu.dart';
import '../entity/order.dart';
import '../repository/customer_repository.dart';
import '../repository/order_repository.dart';
import '../utils.dart';

final menusProvider = Provider.autoDispose<List<Menu>>((ref) {
  final _menus = <Menu>[];
  _menus.add(const Menu(name: 'Customer', icon: Icon(Icons.people)));
  _menus.add(const Menu(name: 'Order', icon: Icon(Icons.shopping_cart)));
  return _menus;
});

final isUsecaseProvider = StateProvider<bool>((ref) => false);

final selectedMenuProvider =
    StateProvider.autoDispose<String>((ref) => 'Customer');

final webFrontendViewControllerProvider =
    Provider.autoDispose((ref) => WebFrontendViewController(ref.read));

final orderUsecaseViewControllerProvider =
    Provider.autoDispose((ref) => OrderUsecaseViewController(ref.read));

final methodsProvider = Provider.autoDispose((ref) {
  final selectedMenu = ref.watch(selectedMenuProvider).state;
  final isAsync = ref.watch(isAsyncProvider).state;
  if (selectedMenu == 'Customer') {
    if (isAsync) {
      return ['get', 'limit'];
    }
    return ['reserve', 'get', 'limit'];
  } else {
    if (isAsync) {
      return ['create', 'get'];
    }
    return ['create', 'get', 'update', 'process'];
  }
});

final isAsyncProvider = StateProvider.autoDispose<bool>((ref) => false);

final isRequestingProvider = StateProvider.autoDispose<bool>((ref) => false);

final currentQuantityProvider = StateProvider.autoDispose<int>((ref) => 0);

final currentCustomerProvider = StateProvider<Customer>((ref) => null);

final currentOrderProvider = StateProvider<Order>((ref) => null);

final googleAuthenticationProvider =
    StateProvider<GoogleSignInAuthentication>((ref) => null);

final selectedMethodProvider = StateProvider.autoDispose<String>((ref) {
  final methods = ref.watch(methodsProvider);
  return methods[0];
});

final currentStepProvider =
    StateProvider.autoDispose<String>((ref) => 'process');

final currentAsyncProcessProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final dtoProvider = StateProvider.autoDispose((ref) {
  final selectedMenu = ref.watch(selectedMenuProvider).state;
  final selectedMethod = ref.watch(selectedMethodProvider).state;
  if (selectedMenu == 'Customer') {
    switch (selectedMethod) {
      case 'reserve':
        return const CustomerDto(customerId: '', number: 0);
      case 'get':
        return const CustomerDto(customerId: '');
      case 'limit':
        return const CustomerDto(customerId: '', limit: 0);
    }
  } else {
    switch (selectedMethod) {
      case 'create':
        return const OrderDto(customerId: '', number: 0);
      case 'get':
        return const OrderDto(customerId: '', orderId: '');
      case 'update':
        return const OrderDto(customerId: '', orderId: '', status: '');
      case 'process':
        return const OrderDto(customerId: '', number: 0);
    }
  }
  return '';
});

final resultJsonProvider = StateProvider.autoDispose<String>((ref) => '');

final loadingStepCustomerProvider =
    StateProvider.autoDispose<bool>((ref) => false);

final loadingStepCartProvider = StateProvider.autoDispose<bool>((ref) => false);

final loadingStepConfirmRefreshProvider =
    StateProvider.autoDispose<bool>((ref) => false);

class WebFrontendViewController {
  WebFrontendViewController(this.read);

  final Reader read;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  void updateMenu(String menu) {
    read(selectedMenuProvider).state = menu;
  }

  void updateMethod(String method) {
    read(selectedMethodProvider).state = method;
  }

  void updateAsyncOrSync(bool value) {
    read(isAsyncProvider).state = value;
  }

  bool willUpdateMethod(String method) {
    return read(selectedMethodProvider).state != method;
  }

  Future<String> getResultJson() async {
    final selectedMenu = read(selectedMenuProvider).state;
    final selectedMethod = read(selectedMethodProvider).state;
    final auth = read(googleAuthenticationProvider).state;
    final isAsync = read(isAsyncProvider).state;

    var token = '';
    if (auth != null) {
      token = auth.idToken;
    }

    if (selectedMenu == 'Customer') {
      final dto = read(dtoProvider).state as CustomerDto;
      final repository = read(customerRepository);
      switch (selectedMethod) {
        case 'reserve':
          return repository.reserveCustomer(token, dto);
        case 'get':
          return repository.getCustomer(isAsync, token, dto);
        case 'limit':
          return repository.limitCustomer(isAsync, token, dto);
      }
    } else {
      final dto = read(dtoProvider).state as OrderDto;
      final repository = read(orderRepository);
      switch (selectedMethod) {
        case 'create':
          return repository.createOrder(isAsync, token, dto);
        case 'get':
          return repository.getOrder(isAsync, token, dto);
        case 'update':
          return repository.updateOrder(token, dto);
        case 'process':
          return repository.processOrder(token, dto);
      }
    }
    return '';
  }

  Future<void> updateResultJson() async {
    read(isRequestingProvider).state = true;
    read(resultJsonProvider).state = await getResultJson();
    read(isRequestingProvider).state = false;
  }

  Future<void> googleSignIn() async {
    try {
      final account = await _googleSignIn.signIn();
      read(googleAuthenticationProvider).state = await account.authentication;
    } catch (error) {
      print(error);
    }
  }

  Future<void> googleSignOut() async {
    await _googleSignIn.signOut();
    await _googleSignIn.disconnect();
    read(googleAuthenticationProvider).state = null;
  }
}

class OrderUsecaseViewController {
  OrderUsecaseViewController(this.read);

  final Reader read;

  void resetCurrentCustomer() {
    read(currentCustomerProvider).state = null;
  }

  void resetCurrentOrder() {
    read(currentOrderProvider).state = null;
  }

  void resetCurrentQuantity() {
    read(currentQuantityProvider).state = 0;
  }

  void proceedStep(String step) {
    read(currentStepProvider).state = step;
  }

  void updateQuantity(int quantity) {
    read(currentQuantityProvider).state = quantity;
  }

  void setCurrentAsyncProcess(bool isAsync) {
    read(currentAsyncProcessProvider).state = isAsync;
  }

  void setCurrentCustomer(Customer customer) {
    read(currentCustomerProvider).state = customer;
  }

  void setCurrentOrder(Order order) {
    read(currentOrderProvider).state = order;
  }

  bool isSignedIn() {
    return read(googleAuthenticationProvider).state != null;
  }

  bool shouldShowProcess() {
    return read(currentStepProvider).state != 'process';
  }

  void startLoadingOnStepCustomer() {
    read(loadingStepCustomerProvider).state = true;
  }

  void stopLoadingOnStepCustomer() {
    read(loadingStepCustomerProvider).state = false;
  }

  void startLoadingOnStepCart() {
    read(loadingStepCartProvider).state = true;
  }

  void stopLoadingOnStepCart() {
    read(loadingStepCartProvider).state = false;
  }

  void startLoadingOnStepConfirmRefresh() {
    read(loadingStepConfirmRefreshProvider).state = true;
  }

  void stopLoadingOnStepConfirmRefresh() {
    read(loadingStepConfirmRefreshProvider).state = false;
  }

  Future<Customer> createCustomer(CustomerDto customerDto) async {
    final currentAsyncProcess = read(currentAsyncProcessProvider).state;
    final repository = read(customerRepository);
    final auth = read(googleAuthenticationProvider).state;
    var token = '';
    if (auth != null) {
      token = auth.idToken;
    }
    final result =
        await repository.limitCustomer(currentAsyncProcess, token, customerDto);
    if (!isValidJson(result)) {
      throw Error();
    }
    final customerJson = json.decode(result) as Map<String, dynamic>;
    if (!_isValidCustomerJson(customerJson)) {
      throw Error();
    }
    return Customer.fromJson(customerJson);
  }

  Future<Order> submitOrder(OrderDto orderDto) async {
    final currentAsyncProcess = read(currentAsyncProcessProvider).state;
    final repository = read(orderRepository);
    final auth = read(googleAuthenticationProvider).state;
    var token = '';
    if (auth != null) {
      token = auth.idToken;
    }
    String result;
    if (currentAsyncProcess) {
      result = await repository.createOrder(true, token, orderDto);
    } else {
      result = await repository.processOrder(token, orderDto);
    }
    if (!isValidJson(result)) {
      throw Error();
    }
    final orderJson = json.decode(result) as Map<String, dynamic>;
    if (!_isValidOrderJson(orderJson)) {
      throw Error();
    }
    return Order.fromJson(orderJson);
  }

  Future<Order> getOrder(OrderDto orderDto) async {
    final repository = read(orderRepository);
    final auth = read(googleAuthenticationProvider).state;
    var token = '';
    if (auth != null) {
      token = auth.idToken;
    }
    String result;
    result = await repository.getOrder(true, token, orderDto);
    if (!isValidJson(result)) {
      throw Error();
    }
    final orderJson = json.decode(result) as Map<String, dynamic>;
    if (!_isValidOrderJson(orderJson)) {
      throw Error();
    }
    return Order.fromJson(orderJson);
  }

  bool _isValidCustomerJson(Map<String, dynamic> customerJson) {
    return customerJson.values.every((dynamic element) => element != null);
  }

  bool _isValidOrderJson(Map<String, dynamic> orderJson) {
    return orderJson.values.every((dynamic element) => element != null);
  }

  void resetState() {
    setCurrentAsyncProcess(false);
    stopLoadingOnStepCustomer();
    stopLoadingOnStepCart();
    resetCurrentCustomer();
    resetCurrentOrder();
    resetCurrentQuantity();
  }
}
