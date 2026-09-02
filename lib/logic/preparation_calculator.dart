import '../models/component.dart';
import '../models/measurement_unit.dart';

double _unitToBaseMl(VolumeUnit unit, double value) =>
    unit == VolumeUnit.ml ? value : value * 1000;

/// Resultado calculado para un componente concreto.
class ComponentResult {
  ComponentResult(this.component, this.amount);

  final Component component;
  final double amount;

  String get unitLabel => component.unit.label;
}

/// Resultado de una preparación de medio.
class PreparationResult {
  PreparationResult(this.desiredVolumeMl, this.results);

  final double desiredVolumeMl;
  final List<ComponentResult> results;
}

/// Motor de cálculo de preparación de medios.
///
/// Independiente de la UI para poder probarse de forma aislada.
class PreparationCalculator {
  /// Calcula la cantidad necesaria de cada componente para preparar
  /// [desiredVolume] de un medio con volumen base [baseVolumeMl].
  ///
  /// Fórmula: cantidad necesaria = cantidad base × (volumen deseado / volumen base)
  static List<ComponentResult> calculate({
    required double baseVolumeMl,
    required List<Component> components,
    required double desiredVolume,
    required VolumeUnit desiredUnit,
  }) {
    final desiredMl = _unitToBaseMl(desiredUnit, desiredVolume);
    if (baseVolumeMl <= 0 || desiredMl <= 0) {
      return const [];
    }
    final factor = desiredMl / baseVolumeMl;

    return components.map((component) {
      // Mantener la cantidad en la misma unidad que el componente,
      // sin redondear durante el cálculo interno.
      final amount = component.amount * factor;
      return ComponentResult(component, amount);
    }).toList();
  }

  /// Formatea una cantidad con precisión limpia, eliminando decimales
  /// innecesarios (p. ej. 10.000 → "10", 0.2500 → "0.25").
  static String formatAmount(double amount) {
    if (amount == amount.roundToDouble() && amount.abs() < 1e15) {
      return amount.toInt().toString();
    }
    var text = amount.toStringAsFixed(6);
    text = text.replaceAll(RegExp(r'0+$'), '');
    if (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
    if (text == '-0') {
      text = '0';
    }
    return text;
  }
}
