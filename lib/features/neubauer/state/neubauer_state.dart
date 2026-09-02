import 'package:flutter/foundation.dart';

import '../../../logic/neubauer_calculator.dart';

enum NeubauerSquares { four, eight }

class NeubauerState extends ChangeNotifier {
  int _totalCells = 0;
  NeubauerSquares _squares = NeubauerSquares.four;
  double _dilution = 1;

  int get totalCells => _totalCells;
  NeubauerSquares get squares => _squares;
  double get dilution => _dilution;

  int get squaresCount => _squares == NeubauerSquares.four ? 4 : 8;

  double get average => _totalCells / squaresCount;
  bool get canCalculate => _totalCells > 0;

  void incrementCell() {
    _totalCells++;
    notifyListeners();
  }

  void decrementCell() {
    if (_totalCells > 0) {
      _totalCells--;
      notifyListeners();
    }
  }

  void setTotalCells(int value) {
    _totalCells = value < 0 ? 0 : value;
    notifyListeners();
  }

  void setSquares(NeubauerSquares value) {
    _squares = value;
    notifyListeners();
  }

  void setDilution(double value) {
    _dilution = value;
    notifyListeners();
  }

  void reset() {
    _totalCells = 0;
    _dilution = 1;
    notifyListeners();
  }

  NeubauerResult? calculate() {
    if (!canCalculate) {
      return null;
    }
    return NeubauerCalculator.calculate(
      totalCells: _totalCells,
      squares: squaresCount,
      dilution: _dilution,
    );
  }
}
