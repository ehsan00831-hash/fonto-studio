import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'app.dart';
import 'core/fonts/font_catalog.dart';
import 'core/settings_controller.dart';
import 'features/story/state/editor_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SettingsController settings = SettingsController();
  final FontCatalog fonts = FontCatalog();
  await settings.load();
  await fonts.load();

  runApp(
    MultiProvider(
      providers: <SingleChildWidget>[
        ChangeNotifierProvider<SettingsController>.value(value: settings),
        ChangeNotifierProvider<FontCatalog>.value(value: fonts),
        ChangeNotifierProvider<EditorController>(create: (_) => EditorController()),
      ],
      child: const FontoApp(),
    ),
  );
}
