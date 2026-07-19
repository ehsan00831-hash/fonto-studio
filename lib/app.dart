import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/settings_controller.dart';
import 'core/strings.dart';
import 'core/theme.dart';
import 'features/gallery/gallery_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/story/editor_screen.dart';

class FontoApp extends StatelessWidget {
  const FontoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = context.watch<SettingsController>();
    return MaterialApp(
      title: 'Fonto Studio',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(settings.workspaceColor, Brightness.light),
      darkTheme: buildTheme(settings.workspaceColor, Brightness.dark),
      themeMode: settings.themeMode,
      locale: settings.locale,
      supportedLocales: const <Locale>[Locale('fa'), Locale('en')],
      localizationsDelegates: const <LocalizationsDelegate<dynamic>>[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const HomeShell(),
    );
  }
}

/// Bottom-navigation shell hosting the three sections.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<Widget> pages = <Widget>[
      const EditorScreen(),
      GalleryScreen(goToEditor: () => setState(() => _index = 0)),
      const SettingsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(<String>[s.tabStory, s.tabGallery, s.tabSettings][_index]),
        centerTitle: true,
      ),
      body: SafeArea(child: IndexedStack(index: _index, children: pages)),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (int i) => setState(() => _index = i),
        destinations: <NavigationDestination>[
          NavigationDestination(icon: const Icon(Icons.edit_outlined), label: s.tabStory),
          NavigationDestination(icon: const Icon(Icons.grid_view_outlined), label: s.tabGallery),
          NavigationDestination(icon: const Icon(Icons.settings_outlined), label: s.tabSettings),
        ],
      ),
    );
  }
}
