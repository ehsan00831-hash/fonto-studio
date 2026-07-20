import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fonto_studio/app.dart';
import 'package:fonto_studio/core/fonts/font_catalog.dart';
import 'package:fonto_studio/core/settings_controller.dart';
import 'package:fonto_studio/features/story/models/story_document.dart';
import 'package:fonto_studio/features/story/state/editor_controller.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Renders the real app UI and writes PNGs to artifacts/ so the redesign can be
/// reviewed without a device.
void main() {
  // The test harness ships no fonts, so glyphs would render as tofu boxes.
  // Load the bundled families and Material icons for a readable screenshot.
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    Future<void> load(String family, String path) async {
      final File f = File(path);
      if (!f.existsSync()) return;
      final FontLoader loader = FontLoader(family)
        ..addFont(Future<ByteData>.value(ByteData.view(f.readAsBytesSync().buffer)));
      await loader.load();
    }

    await load('Vazirmatn', 'assets/fonts/Vazirmatn-Regular.ttf');
    await load('Lalezar', 'assets/fonts/Lalezar-Regular.ttf');
    await load('Shabnam', 'assets/fonts/Shabnam.ttf');
    await load('Sahel', 'assets/fonts/Sahel.ttf');
    final String? root = Platform.environment['FLUTTER_ROOT'];
    if (root != null) {
      await load('MaterialIcons',
          '$root/bin/cache/artifacts/material_fonts/MaterialIcons-Regular.otf');
      await load('Roboto', '$root/bin/cache/artifacts/material_fonts/Roboto-Regular.ttf');
    }
  });

  testWidgets('capture editor UI screenshots', (WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(430, 932));

    final EditorController editor = EditorController();
    editor.setBackground(
      kind: BackgroundKind.gradient,
      gradientStart: 0xFF4A1B8C,
      gradientEnd: 0xFFFF7AE0,
    );
    editor.addTextLayer(text: 'کاری را انجام بده\nکه تو را زنده می‌کند', rtl: true);
    editor.editSelected((dynamic l) {
      l.fontSize = 46.0;
      l.fontFamily = 'Lalezar';
      l.colorValue = 0xFFFFD76A;
      l.dy = 0.34;
      l.shadowEnabled = true;
    });
    editor.addTextLayer(text: 'Do What Makes You Feel Alive', rtl: false);
    editor.editSelected((dynamic l) {
      l.fontSize = 30.0;
      l.fontFamily = 'Vazirmatn';
      l.dy = 0.56;
      l.strokeEnabled = true;
    });

    final GlobalKey shotKey = GlobalKey();

    await tester.pumpWidget(
      MultiProvider(
        providers: <SingleChildWidget>[
          ChangeNotifierProvider<SettingsController>(create: (_) => SettingsController()),
          ChangeNotifierProvider<FontCatalog>(create: (_) => FontCatalog()),
          ChangeNotifierProvider<EditorController>.value(value: editor),
        ],
        child: RepaintBoundary(key: shotKey, child: const FontoApp()),
      ),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    Future<void> shot(String name) async {
      await tester.runAsync(() async {
        final RenderRepaintBoundary b =
            shotKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final ui.Image img = await b.toImage(pixelRatio: 2);
        final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
        final Directory out = Directory('artifacts')..createSync(recursive: true);
        File('${out.path}/$name.png').writeAsBytesSync(png!.buffer.asUint8List());
        img.dispose();
      });
    }

    await shot('ui_editor');

    // Layers panel
    await tester.tap(find.byIcon(Icons.layers));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    await shot('ui_layers');
    expect(find.byIcon(Icons.visibility), findsWidgets);
    await tester.tapAt(const Offset(215, 40)); // dismiss sheet via barrier
    await tester.pumpAndSettle();

    // The toolbar scrolls horizontally, so scroll the export button into view
    // before tapping it.
    await tester.ensureVisible(find.byIcon(Icons.ios_share));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.ios_share));
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
    await shot('ui_export');
    expect(find.text('2x'), findsOneWidget);
  });
}
