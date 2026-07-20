import 'package:flutter/material.dart';

import 'text_layer.dart';

/// Named canvas sizes covering the common social formats, plus a free-form
/// custom size driven by [StoryDocument.customWidth]/[customHeight].
enum CanvasSize { story, post45, post34, square, landscape, wide, portrait23, custom }

extension CanvasSizeInfo on CanvasSize {
  /// Base (1x) pixel dimensions. `custom` falls back to story and is overridden
  /// by the document — use [StoryDocument.pixels] rather than this directly.
  Size get pixels {
    switch (this) {
      case CanvasSize.story:
        return const Size(1080, 1920);
      case CanvasSize.post45:
        return const Size(1080, 1350);
      case CanvasSize.post34:
        return const Size(1080, 1440);
      case CanvasSize.square:
        return const Size(1080, 1080);
      case CanvasSize.landscape:
        return const Size(1920, 1080);
      case CanvasSize.wide:
        return const Size(1200, 630);
      case CanvasSize.portrait23:
        return const Size(1080, 1620);
      case CanvasSize.custom:
        return const Size(1080, 1920);
    }
  }

  String get label {
    switch (this) {
      case CanvasSize.story:
        return 'Story / Reels — 9:16';
      case CanvasSize.post45:
        return 'Post — 4:5';
      case CanvasSize.post34:
        return 'Post — 3:4';
      case CanvasSize.square:
        return 'Square — 1:1';
      case CanvasSize.landscape:
        return 'Landscape — 16:9';
      case CanvasSize.wide:
        return 'Link preview — 1.91:1';
      case CanvasSize.portrait23:
        return 'Portrait — 2:3';
      case CanvasSize.custom:
        return 'Custom';
    }
  }
}

/// Background fill for a story: transparent, a solid colour, or a gradient.
enum BackgroundKind { transparent, solid, gradient }

class StoryDocument {
  StoryDocument({
    required this.id,
    this.name = 'Untitled',
    this.size = CanvasSize.story,
    this.customWidth = 1080,
    this.customHeight = 1920,
    this.exportScale = 1,
    this.backgroundKind = BackgroundKind.solid,
    this.backgroundColorValue = 0xFF0B0E1A,
    this.gradientStartValue = 0xFF1B3FA8,
    this.gradientEndValue = 0xFF7FD0FF,
    List<TextLayer>? layers,
    DateTime? updatedAt,
  })  : layers = layers ?? <TextLayer>[],
        updatedAt = updatedAt ?? DateTime.now();

  final String id;
  String name;
  CanvasSize size;
  double customWidth;
  double customHeight;

  /// Export resolution multiplier (1x/2x/3x) applied on top of [pixels].
  int exportScale;

  BackgroundKind backgroundKind;
  int backgroundColorValue;
  int gradientStartValue;
  int gradientEndValue;
  List<TextLayer> layers;
  DateTime updatedAt;

  /// Document pixel size, honouring a custom canvas.
  Size get pixels => size == CanvasSize.custom
      ? Size(customWidth, customHeight)
      : size.pixels;

  /// Final exported pixel size.
  Size get exportPixels =>
      Size(pixels.width * exportScale, pixels.height * exportScale);

  double get aspectRatio => pixels.width / pixels.height;

  bool get isTransparent => backgroundKind == BackgroundKind.transparent;

  Color get backgroundColor => Color(backgroundColorValue);
  Color get gradientStart => Color(gradientStartValue);
  Color get gradientEnd => Color(gradientEndValue);

  /// Layers painted bottom-to-top, skipping hidden ones.
  List<TextLayer> get visibleLayers =>
      layers.where((TextLayer l) => l.visible).toList();

  StoryDocument copy() => StoryDocument.fromJson(toJson());

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'size': size.index,
        'customWidth': customWidth,
        'customHeight': customHeight,
        'exportScale': exportScale,
        'backgroundKind': backgroundKind.index,
        'backgroundColorValue': backgroundColorValue,
        'gradientStartValue': gradientStartValue,
        'gradientEndValue': gradientEndValue,
        'updatedAt': updatedAt.toIso8601String(),
        'layers': layers.map((TextLayer l) => l.toJson()).toList(),
      };

  factory StoryDocument.fromJson(Map<String, dynamic> j) {
    int i(String k, int fallback) => (j[k] as num?)?.toInt() ?? fallback;
    double d(String k, double fallback) => (j[k] as num?)?.toDouble() ?? fallback;
    final int sizeIdx = i('size', 0);
    return StoryDocument(
      id: j['id'] as String,
      name: j['name'] as String? ?? 'Untitled',
      size: CanvasSize.values[
          sizeIdx.clamp(0, CanvasSize.values.length - 1)],
      customWidth: d('customWidth', 1080),
      customHeight: d('customHeight', 1920),
      exportScale: i('exportScale', 1).clamp(1, 4),
      backgroundKind: BackgroundKind.values[i('backgroundKind', 1)],
      backgroundColorValue: i('backgroundColorValue', 0xFF0B0E1A),
      gradientStartValue: i('gradientStartValue', 0xFF1B3FA8),
      gradientEndValue: i('gradientEndValue', 0xFF7FD0FF),
      updatedAt: DateTime.tryParse(j['updatedAt'] as String? ?? '') ?? DateTime.now(),
      layers: ((j['layers'] as List<dynamic>?) ?? <dynamic>[])
          .map((dynamic e) => TextLayer.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}
