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
  String get formattedConcentration => _formatConcentration(concentration);

  String get formattedAverage => _format(average);

  /// Formatea un valor insertando un espacio cada 3 cifras en la parte entera
  /// (p. ej. `1 000 000`), conservando los decimales si los hay.
  static String _formatConcentration(double value) {
    final text = _format(value);
    final dot = text.indexOf('.');
    final intPart = dot < 0 ? text : text.substring(0, dot);
    final decPart = dot < 0 ? '' : text.substring(dot);
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(intPart[i]);
    }
    return '$buffer$decPart';
  }

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
/// Fórmula usada (según SPEC):
///   Promedio = totalDeCélulas ÷ nºCuadros
///   Concentración (células/mL) = promedio × 10⁴ × factorDeDilución
///   (cada cuadro de esquina equivale a 1,0 × 10⁻⁴ mL = 10⁴ por mL)
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

    // Promedio = total de células contadas ÷ número de cuadros contados
    final average = totalCells / squares;
    // Concentración (células/mL) = promedio × 10⁴ × factor de dilución
    final concentration = average * 1.0e4 * dilution;

    return NeubauerResult(
      totalCells: totalCells,
      squares: squares,
      average: average,
      dilution: dilution,
      concentration: concentration,
    );
  }
}
