import 'package:flutter/material.dart';

import '../features/neubauer/screens/neubauer_calculator_screen.dart';
import 'tool_definition.dart';

/// Herramienta de SCIKIT: Calculadora de Cámara de Neubauer.
class NeubauerTool extends ToolDefinition {
  const NeubauerTool();

  static const _id = 'neubauer';

  @override
  String get id => _id;

  @override
  String get name => 'Cámara de Neubauer';

  @override
  String get description =>
      'Calcula la concentración de células en células/mL a partir del conteo en una cámara de Neubauer.';

  @override
  IconData get icon => Icons.grain;

  @override
  Widget buildScreen(BuildContext context) =>
      const NeubauerCalculatorScreen();
}
