import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/scikit_app.dart';
import 'features/lab_timers/state/lab_timers_state.dart';
import 'features/media_library/state/media_library_state.dart';
import 'features/neubauer/state/neubauer_state.dart';
import 'state/dashboard_state.dart';
import 'state/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final themeController = ThemeController();
  final dashboardState = DashboardState();
  final mediaLibraryState = MediaLibraryState();
  final labTimersState = LabTimersState();
  final neubauerState = NeubauerState();

  await themeController.load();
  await dashboardState.load();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: themeController),
        ChangeNotifierProvider.value(value: dashboardState),
        ChangeNotifierProvider.value(value: mediaLibraryState),
        ChangeNotifierProvider.value(value: labTimersState),
        ChangeNotifierProvider.value(value: neubauerState),
      ],
      child: const ScikitApp(),
    ),
  );
}
