import 'package:flutter_test/flutter_test.dart';
import 'package:scikit/logic/preparation_calculator.dart';
import 'package:scikit/models/component.dart';
import 'package:scikit/models/measurement_unit.dart';

void main() {
  group('PreparationCalculator.calculate', () {
    test('Ejemplo 1: base 1 L, preparar 100 mL', () {
      final result = PreparationCalculator.calculate(
        baseVolumeMl: 1000,
        components: [
          Component(name: 'Agar', amount: 100, unit: ComponentUnit.g),
          Component(name: 'NaCl', amount: 5, unit: ComponentUnit.g),
        ],
        desiredVolume: 100,
        desiredUnit: VolumeUnit.ml,
      );

      expect(result.length, 2);
      expect(result[0].amount, closeTo(10, 1e-9));
      expect(result[1].amount, closeTo(0.5, 1e-9));
    });

    test('Ejemplo 2: base 1 L, preparar 900 mL → Agar 90 g', () {
      final result = PreparationCalculator.calculate(
        baseVolumeMl: 1000,
        components: [
          Component(name: 'Agar', amount: 100, unit: ComponentUnit.g),
        ],
        desiredVolume: 900,
        desiredUnit: VolumeUnit.ml,
      );

      expect(result.single.amount, closeTo(90, 1e-9));
    });

    test('Conversión de unidades: base 1 L, preparar 500 mL = 0.5 L', () {
      final result = PreparationCalculator.calculate(
        baseVolumeMl: 1000,
        components: [
          Component(name: 'Agar', amount: 100, unit: ComponentUnit.g),
        ],
        desiredVolume: 500,
        desiredUnit: VolumeUnit.ml,
      );

      expect(result.single.amount, closeTo(50, 1e-9));
    });

    test('Volumen deseado en litros (desiredUnit L)', () {
      final result = PreparationCalculator.calculate(
        baseVolumeMl: 1000,
        components: [
          Component(name: 'Agar', amount: 100, unit: ComponentUnit.g),
        ],
        desiredVolume: 2,
        desiredUnit: VolumeUnit.l,
      );

      expect(result.single.amount, closeTo(200, 1e-9));
    });

    test('Componente líquido en mL: base 1 L, preparar 500 mL', () {
      final result = PreparationCalculator.calculate(
        baseVolumeMl: 1000,
        components: [
          Component(name: 'Componente líquido', amount: 100, unit: ComponentUnit.ml),
        ],
        desiredVolume: 500,
        desiredUnit: VolumeUnit.ml,
      );

      expect(result.single.amount, closeTo(50, 1e-9));
    });

    test('Base volumen en L almacenado (baseVolumeMl convierte)', () {
      // base 1 L = 1000 mL
      final result = PreparationCalculator.calculate(
        baseVolumeMl: 1 * 1000,
        components: [
          Component(name: 'NaCl', amount: 5, unit: ComponentUnit.g),
        ],
        desiredVolume: 100,
        desiredUnit: VolumeUnit.ml,
      );

      expect(result.single.amount, closeTo(0.5, 1e-9));
    });

    test('Masa en mg se mantiene en mg', () {
      final result = PreparationCalculator.calculate(
        baseVolumeMl: 1000,
        components: [
          Component(name: 'Vitamina', amount: 100, unit: ComponentUnit.mg),
        ],
        desiredVolume: 500,
        desiredUnit: VolumeUnit.ml,
      );

      expect(result.single.amount, closeTo(50, 1e-9));
      expect(result.single.unitLabel, 'mg');
    });

    test('Volumen base inválido devuelve lista vacía', () {
      final result = PreparationCalculator.calculate(
        baseVolumeMl: 0,
        components: [
          Component(name: 'Agar', amount: 100, unit: ComponentUnit.g),
        ],
        desiredVolume: 100,
        desiredUnit: VolumeUnit.ml,
      );

      expect(result, isEmpty);
    });

    test('Volumen deseado inválido devuelve lista vacía', () {
      final result = PreparationCalculator.calculate(
        baseVolumeMl: 1000,
        components: [
          Component(name: 'Agar', amount: 100, unit: ComponentUnit.g),
        ],
        desiredVolume: 0,
        desiredUnit: VolumeUnit.ml,
      );

      expect(result, isEmpty);
    });

    test('Varios componentes, todos calculados individualmente', () {
      final components = List.generate(
        10,
        (i) => Component(
            name: 'Comp $i', amount: i + 1, unit: ComponentUnit.g),
      );
      final result = PreparationCalculator.calculate(
        baseVolumeMl: 1000,
        components: components,
        desiredVolume: 500,
        desiredUnit: VolumeUnit.ml,
      );

      expect(result.length, 10);
      for (var i = 0; i < 10; i++) {
        expect(result[i].amount, closeTo((i + 1) / 2, 1e-9));
      }
    });
  });

  group('PreparationCalculator.formatAmount', () {
    test('10.000000 → "10"', () {
      expect(PreparationCalculator.formatAmount(10.0), '10');
    });

    test('0.25 → "0.25"', () {
      expect(PreparationCalculator.formatAmount(0.25), '0.25');
    });

    test('0.5 → "0.5"', () {
      expect(PreparationCalculator.formatAmount(0.5), '0.5');
    });

    test('90.0 → "90"', () {
      expect(PreparationCalculator.formatAmount(90.0), '90');
    });
  });
}
