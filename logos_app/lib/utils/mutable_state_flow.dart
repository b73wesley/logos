import 'package:flutter/foundation.dart';
import 'response.dart';

typedef StateAction<T> = Future<Response<T>> Function();
typedef StateActionFor<T, A> = Future<Response<T>> Function(A);

/// Handles async actions in view models with typed results.
///
/// Use [ApplyState] for actions without arguments.
/// Use [ApplyStateFor] for actions with one argument.
abstract class MutableStateFlow<T> extends ChangeNotifier {
  bool _running = false;
  Response<T>? _response;

  bool get isRunning => _running;
  bool get failure => _response is Failure<T>;
  bool get success => _response is Success<T>;

  /// Typed access to the last response.
  Response<T>? get result => _response;

  /// Shortcut: data on success, null otherwise.
  T? get data => _response?.dataOrNull;

  /// Shortcut: error on failure, null otherwise.
  Object? get error => switch (_response) {
    Failure<T> f => f.error,
    _ => null,
  };

  void clearResult() {
    _response = null;
    notifyListeners();
  }

  Future<void> _execute(StateAction<T> action) async {
    if (_running) return;
    _running = true;
    _response = null;
    notifyListeners();
    try {
      _response = await action();
    } finally {
      _running = false;
      notifyListeners();
    }
  }
}

class ApplyState<T> extends MutableStateFlow<T> {
  ApplyState(this._action);
  final StateAction<T> _action;
  Future<void> execute() => _execute(_action);
}

class ApplyStateFor<T, A> extends MutableStateFlow<T> {
  ApplyStateFor(this._action);
  final StateActionFor<T, A> _action;
  Future<void> execute(A argument) => _execute(() => _action(argument));
}
