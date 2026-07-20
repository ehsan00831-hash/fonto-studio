import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fonto_studio/features/story/models/story_document.dart';
import 'package:fonto_studio/features/story/state/editor_controller.dart';
import 'package:fonto_studio/features/story/widgets/story_canvas.dart';
import 'package:provider/provider.dart';

/// Proves the exported PNG is *actually* transparent: renders the real canvas
/// through the real export path and inspects the alpha channel.
void main() {
  Future<ui.Image> renderCanvas(
    WidgetTester tester,
    EditorController c, {
    Size surface = const Size(400, 711),
  }) async {
    await tester.binding.setSurfaceSize(surface);
    await tester.pumpWidget(
      ChangeNotifierProvider<EditorController>.value(
        value: c,
        child: const MaterialApp(
          home: Scaffold(
            backgroundColor: Colors.black,
            body: StoryCanvas(interactive: false),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    late ui.Image img;
    await tester.runAsync(() async {
      img = (await c.renderImage())!;
    });
    return img;
  }

  Future<Uint8List> rawRgba(ui.Image img) async {
    final ByteData? d = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
    return d!.buffer.asUint8List();
  }

  testWidgets('transparent background exports with alpha = 0', (WidgetTester tester) async {
    final EditorController c = EditorController();
    c.setBackground(kind: BackgroundKind.transparent);
    c.addTextLayer(text: 'شفاف', rtl: true);

    final ui.Image img = await renderCanvas(tester, c);
    late Uint8List px;
    await tester.runAsync(() async => px = await rawRgba(img));

    // Corners are background-only; they must be fully transparent.
    int alphaAt(int x, int y) => px[((y * img.width) + x) * 4 + 3];
    expect(alphaAt(2, 2), 0, reason: 'top-left corner must be transparent');
    expect(alphaAt(img.width - 3, 2), 0, reason: 'top-right corner must be transparent');
    expect(alphaAt(2, img.height - 3), 0, reason: 'bottom-left corner must be transparent');

    // And the layer itself must still have painted something opaque.
    int opaque = 0;
    for (int i = 3; i < px.length; i += 4) {
      if (px[i] > 200) opaque++;
    }
    expect(opaque, greaterThan(0), reason: 'text should be painted');

    img.dispose();
  });

  testWidgets('solid background exports fully opaque', (WidgetTester tester) async {
    final EditorController c = EditorController();
    c.setBackground(kind: BackgroundKind.solid, colorValue: 0xFF102030);

    final ui.Image img = await renderCanvas(tester, c);
    late Uint8List px;
    await tester.runAsync(() async => px = await rawRgba(img));

    int transparent = 0;
    for (int i = 3; i < px.length; i += 4) {
      if (px[i] < 255) transparent++;
    }
    expect(transparent, 0, reason: 'a solid background must leave no alpha holes');
    img.dispose();
  });

  testWidgets('export honours the resolution multiplier', (WidgetTester tester) async {
    final EditorController c = EditorController();
    c.setCanvasSize(CanvasSize.square); // 1080x1080
    c.setExportScale(2);

    final ui.Image img = await renderCanvas(tester, c, surface: const Size(400, 700));
    expect(img.width, 2160, reason: '1080 * 2x');
    img.dispose();
  });

  testWidgets('writes a sample transparent PNG artifact', (WidgetTester tester) async {
    final EditorController c = EditorController();
    c.setBackground(kind: BackgroundKind.transparent);
    c.setCanvasSize(CanvasSize.square);
    c.addTextLayer(text: 'شفاف • Alpha 0', rtl: true);
    c.editSelected((dynamic l) {
      l.fontSize = 64.0;
      l.colorValue = 0xFFFFD76A;
    });

    final ui.Image img = await renderCanvas(tester, c);
    await tester.runAsync(() async {
      final ByteData? png = await img.toByteData(format: ui.ImageByteFormat.png);
      final Directory out = Directory('artifacts')..createSync(recursive: true);
      File('${out.path}/sample_transparent.png')
          .writeAsBytesSync(png!.buffer.asUint8List());
    });
    img.dispose();
  });
}
