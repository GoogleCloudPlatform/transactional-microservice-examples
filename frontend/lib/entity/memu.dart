import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'memu.freezed.dart';

@freezed
abstract class Menu with _$Menu {
  const factory Menu({String name, Icon icon}) = _Menu;
}
