/// Resultado del cálculo de la cámara de Neubauer.
class NeubauerResult {
  NeubauerResult({
    required this.totalCells,
    required this.squares,
    required this.average,
    required this.dilution,
    required this.concentration,
  });

  final int totalCells;
  final int squares;
  final double average;
  final double dilution;
  final double concentration;

  /// Formato limpio en células/mL (sin decimales innecesarios).
  String get formattedConcentration => _format(concentration);

  String get formattedAverage => _format(average);

  static String _format(double value) {
    if (value == value.roundToDouble() && value.abs() < 1e15) {
      return value.toInt().toString();
    }
    var text = value.toStringAsFixed(6);
    text = text.replaceAll(RegExp(r'0+$'), '');
    if (text.endsWith('.')) {
      text = text.substring(0, text.length - 1);
    }
    return text;
  }
}

/// Motor de cálculo de la cámara de Neubauer.
///
/// Independiente de la UI para poder probarse de forma aislada.
///
/// Fórmula de trabajo (a revisar en el futuro, según SPEC):
///   Concentración (células/mL) =
///       [totalDeCélulas ÷ (volumenDeUnCuadro × nºCuadros)] × factorDeDilución
///
/// Equivalente a lo estándar:
///   Concentración = (promedio por cuadro × dilución) ÷ volumenDeUnCuadro
class NeubauerCalculator {
  NeubauerCalculator._();

  /// Volumen de un cuadro de la cámara de Neubauer en mililitros.
  ///
  /// Cada cuadro de esquina (1 mm × 1 mm, profundidad 0,1 mm) equivale a
  /// 0,1 µL = 1,0 × 10⁻⁴ mL. Se usa como valor de trabajo configurable.
  static const double volumeOfOneSquareMl = 1.0e-4;

  static NeubauerResult calculate({
    required int totalCells,
    required int squares,
    required double dilution,
  }) {
    if (totalCells < 0) {
      throw ArgumentError.value(totalCells, 'totalCells', 'No puede ser negativo');
    }
    if (squares <= 0) {
      throw ArgumentError.value(squares, 'squares', 'Debe ser mayor que cero');
    }
    if (dilution <= 0) {
      throw ArgumentError.value(dilution, 'dilution', 'Debe ser mayor que cero');
    }

    final average = totalCells / squares;
    final concentration =
        (totalCells / (volumeOfOneSquareMl * squares)) * dilution;

    return NeubauerResult(
      totalCells: totalCells,
      squares: squares,
      average: average,
      dilution: dilution,
      concentration: concentration,
    );
  }
}
