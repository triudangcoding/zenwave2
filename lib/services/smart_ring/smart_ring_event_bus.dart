import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:yc_product_plugin/yc_product_plugin.dart';

class SmartRingEventBus {
  SmartRingEventBus._();

  static final SmartRingEventBus instance = SmartRingEventBus._();

  final StreamController<Map<dynamic, dynamic>> _controller =
      StreamController<Map<dynamic, dynamic>>.broadcast();

  bool _isListening = false;

  Stream<Map<dynamic, dynamic>> get events => _controller.stream;

  void ensureListening() {
    if (_isListening) {
      return;
    }

    _isListening = true;
    YcProductPlugin().onListening((event) {
      if (event is Map) {
        _controller.add(event);
      } else {
        debugPrint('[SmartRingEventBus] Ignored non-map event: $event');
      }
    });
  }

  void dispose() {
    if (_isListening) {
      YcProductPlugin().cancelListening();
      _isListening = false;
    }
    _controller.close();
  }
}
