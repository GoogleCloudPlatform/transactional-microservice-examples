import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../entity/customer.dart';
import '../entity/order.dart';
import '../provider/saga_frontend_providers.dart';

class RequestJson extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final selectedMenu = useProvider(selectedMenuProvider).state;
    const encoder = JsonEncoder.withIndent('    ');
    SelectableText _text;
    if (selectedMenu == 'Customer') {
      final dto = useProvider(dtoProvider).state as CustomerDto;
      _text = SelectableText(
        encoder.convert(dto.toJson()),
        style: TextStyle(
          fontSize: 18.0,
          color: Theme.of(context).textTheme.headline4.color,
        ),
      );
    } else {
      final dto = useProvider(dtoProvider).state as OrderDto;
      _text = SelectableText(
        encoder.convert(dto.toJson()),
        style: TextStyle(
          fontSize: 18.0,
          color: Theme.of(context).textTheme.headline4.color,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Theme.of(context).backgroundColor,
            width: 1,
          ),
          top: BorderSide(
            color: Theme.of(context).backgroundColor,
            width: 1,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            SelectableText(
              'Request JSON',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headline4.color,
              ),
            ),
            const SizedBox(
              height: 10.0,
            ),
            _text,
          ],
        ),
      ),
    );
  }
}
