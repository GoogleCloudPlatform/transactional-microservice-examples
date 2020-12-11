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
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../entity/customer.dart';
import '../entity/memu.dart';
import '../entity/order.dart';
import '../repository/customer_repository.dart';
import '../repository/order_repository.dart';

final menusProvider = Provider.autoDispose<List<Menu>>((ref) {
  final _menus = <Menu>[];
  _menus.add(const Menu(name: 'Customer', icon: Icon(Icons.people)));
  _menus.add(const Menu(name: 'Order', icon: Icon(Icons.shopping_cart)));
  return _menus;
});

final selectedMenuProvider =
    StateProvider.autoDispose<String>((ref) => 'Customer');

final webFrontendViewControllerProvider =
    Provider.autoDispose((ref) => WebFrontendViewController(ref.read));

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

final googleAuthenticationProvider =
    StateProvider<GoogleSignInAuthentication>((ref) => null);

final selectedMethodProvider = StateProvider.autoDispose<String>((ref) {
  final methods = ref.watch(methodsProvider);
  return methods[0];
});

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
      print('Successfully retrieved a token: ' +
          read(googleAuthenticationProvider).state.idToken);
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
