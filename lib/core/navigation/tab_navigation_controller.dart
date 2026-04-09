import 'package:flutter/material.dart';

class TabNavigationController {
  TabNavigationController._();

  static final ValueNotifier<int> selectedIndex = ValueNotifier<int>(0);
}