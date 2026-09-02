import 'package:flutter/material.dart';

/// Definición conceptual de una herramienta de SCIKIT.
///
/// Cada herramienta tiene:
/// - ID único
/// - Nombre
/// - Icono
/// - Descripción
/// - Ruta / pantalla
/// - Estado de si está agregada al dashboard
abstract class ToolDefinition {
  const ToolDefinition();

  String get id;
  String get name;
  String get description;
  IconData get icon;

  /// Construye la pantalla principal de la herramienta.
  Widget buildScreen(BuildContext context);
}
