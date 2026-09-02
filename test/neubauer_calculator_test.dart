import 'package:flutter_test/flutter_test.dart';
import 'package:scikit/logic/neubauer_calculator.dart';

void main() {
  group('NeubauerCalculator.calculate', () {
    test('concentración básica con 4 cuadros y dilución 1', () {
      final r = NeubauerCalculator.calculate(
        totalCells: 100,
        squares: 4,
        dilution: 1,
      );
      // promedio = 100/4 = 25 células/cuadro
      expect(r.average, closeTo(25, 1e-9));
      // conc = promedio / volumen(1e-4 mL) * dilución
      expect(r.concentration, closeTo(25 / 1.0e-4, 1e-6));
      expect(r.formattedConcentration, '250000');
    });

    test('promedio con 8 cuadros', () {
      final r = NeubauerCalculator.calculate(
        totalCells: 200,
        squares: 8,
        dilution: 1,
      );
      expect(r.average, closeTo(25, 1e-9));
    });

    test('factor de dilución multiplica el resultado', () {
      final r = NeubauerCalculator.calculate(
        totalCells: 100,
        squares: 4,
        dilution: 10,
      );
      expect(r.concentration, closeTo(25 / 1.0e-4 * 10, 1e-6));
    });

    test('formula equivalente a promedio/volumen*dilución', () {
      final cells = 320;
      final squares = 8;
      final dilution = 2.0;
      final avg = cells / squares;
      final expected = (avg / NeubauerCalculator.volumeOfOneSquareMl) * dilution;
      final r = NeubauerCalculator.calculate(
        totalCells: cells,
        squares: squares,
        dilution: dilution,
      );
      expect(r.concentration, closeTo(expected, 1e-6));
    });

    test('lanza error con dilución <= 0', () {
      expect(
        () => NeubauerCalculator.calculate(
            totalCells: 10, squares: 4, dilution: 0),
        throwsArgumentError,
      );
    });

    test('lanza error con cuadros <= 0', () {
      expect(
        () => NeubauerCalculator.calculate(
            totalCells: 10, squares: 0, dilution: 1),
        throwsArgumentError,
      );
    });

    test('lanza error con conteo negativo', () {
      expect(
        () => NeubauerCalculator.calculate(
            totalCells: -1, squares: 4, dilution: 1),
        throwsArgumentError,
      );
    });
  });

  group('NeubauerResult.formatting', () {
    test('concentración sin decimales si es entera', () {
      final r = NeubauerCalculator.calculate(
        totalCells: 100,
        squares: 4,
        dilution: 1,
      );
      expect(r.formattedConcentration, '250000');
    });

    test('promedio muestra decimales cuando es necesario', () {
      final r = NeubauerCalculator.calculate(
        totalCells: 100,
        squares: 8,
        dilution: 1,
      );
      expect(r.formattedAverage, '12.5');
    });
  });
}
