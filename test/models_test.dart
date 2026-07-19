import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fonto_studio/features/story/models/story_document.dart';
import 'package:fonto_studio/features/story/models/text_layer.dart';
import 'package:fonto_studio/features/story/widgets/text_layer_view.dart';

void main() {
  test('TextLayer survives a JSON round-trip', () {
    final TextLayer original = TextLayer(
      id: 'a',
      text: 'سلام',
      isRTL: true,
      fontFamily: 'Vazirmatn',
      fontSize: 48,
      gradientEnabled: true,
      strokeEnabled: true,
      shadowEnabled: true,
      boxEnabled: true,
      rotation: 0.5,
      scale: 1.3,
    );
    final TextLayer restored = TextLayer.fromJson(original.toJson());

    expect(restored.text, original.text);
    expect(restored.isRTL, original.isRTL);
    expect(restored.fontFamily, original.fontFamily);
    expect(restored.fontSize, original.fontSize);
    expect(restored.gradientEnabled, isTrue);
    expect(restored.strokeEnabled, isTrue);
    expect(restored.shadowEnabled, isTrue);
    expect(restored.boxEnabled, isTrue);
    expect(restored.rotation, closeTo(0.5, 1e-9));
    expect(restored.scale, closeTo(1.3, 1e-9));
  });

  test('StoryDocument round-trips with its layers', () {
    final StoryDocument doc = StoryDocument(
      id: 'doc1',
      name: 'Test',
      size: CanvasSize.square,
      backgroundKind: BackgroundKind.gradient,
      layers: <TextLayer>[
        TextLayer(id: '1', text: 'یک'),
        TextLayer(id: '2', text: 'دو', isRTL: false),
      ],
    );
    final StoryDocument restored = StoryDocument.fromJson(doc.toJson());

    expect(restored.name, 'Test');
    expect(restored.size, CanvasSize.square);
    expect(restored.backgroundKind, BackgroundKind.gradient);
    expect(restored.layers.length, 2);
    expect(restored.layers[1].isRTL, isFalse);
  });

  testWidgets('TextLayerView renders a styled layer without error',
      (WidgetTester tester) async {
    final TextLayer layer = TextLayer(
      id: 'x',
      text: 'نمونه',
      gradientEnabled: true,
      strokeEnabled: true,
      shadowEnabled: true,
      boxEnabled: true,
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(child: TextLayerView(layer: layer, k: 1)),
        ),
      ),
    );
    expect(find.text('نمونه'), findsWidgets);
  });
}
