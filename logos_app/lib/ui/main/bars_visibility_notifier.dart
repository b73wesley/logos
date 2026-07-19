import 'package:flutter/foundation.dart';

/// Shared state controlling whether the bottom navigation bars are visible.
/// Driven by scroll events in the reader ([HomeScreen]) and consumed by
/// [MainScreen] to animate the shell bottom nav in/out.
class BarsVisibilityNotifier extends ChangeNotifier {
  bool _visible = true;

  bool get visible => _visible;

  void show() {
    if (_visible) return;
    _visible = true;
    notifyListeners();
  }

  void hide() {
    if (!_visible) return;
    _visible = false;
    notifyListeners();
  }
}
