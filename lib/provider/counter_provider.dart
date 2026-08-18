import 'package:flutter/foundation.dart';

class CounterProvider extends ChangeNotifier {
  int _counter = 0;

  int get counter => _counter;

  // +1
  void increment() {
    _counter++;
    notifyListeners();
  }

  // -1
  void decrement() {
      _counter--;
      notifyListeners();

  }

  // +5
  void incrementByFive() {
    _counter += 5;
    notifyListeners();
  }

  // ×7
  void multiplyBySeven() {
    _counter = _counter * 7;
    notifyListeners();
  }

  // Reset
  void reset() {
    _counter = 0;
    notifyListeners();
  }
}