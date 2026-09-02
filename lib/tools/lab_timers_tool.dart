import 'package:flutter/material.dart';

import '../features/lab_timers/screens/lab_timers_screen.dart';
import 'tool_definition.dart';

/// Herramienta de SCIKIT: Temporizador de Laboratorio.
class LabTimersTool extends ToolDefinition {
  const LabTimersTool();

  static const _id = 'lab_timers';

  @override
  String get id => _id;

  @override
  String get name => 'Temporizador';

  @override
  String get description =>
      'Crea y utiliza varios temporizadores simultáneos para controlar tiempos de incubación, sedimentación, tinciones y tratamientos.';

  @override
  IconData get icon => Icons.timer_outlined;

  @override
  Widget buildScreen(BuildContext context) => const LabTimersScreen();
}
