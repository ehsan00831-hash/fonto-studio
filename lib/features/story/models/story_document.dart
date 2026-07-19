import 'package:flutter/material.dart';

import 'text_layer.dart';

/// Named canvas sizes, matching the common social formats.
enum CanvasSize { story, post45, square, landscape }

extension CanvasSizeInfo on CanvasSize {
  Size get pixels {
    switch (this) {
      case CanvasSize.story:
        return const Size(1080, 1920);
      case CanvasSize.post45:
        return const Size(1080, 1350);
      case CanvasSize.square:
        return const Size(1080, 1080);
      case CanvasSize.landscape:
        return const Size(1920, 1080);
    }
  }

  String get label {
    switch (this) {
      case CanvasSize.story:
        return 'Story 9:16';
      case CanvasSize.post45:
        return 'Post 4:5';
      case CanvasSize.square:
        return 'Square 1:1';
      case CanvasSize.landscape:
        return 'Landscape 16:9';
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
  BackgroundKind backgroundKind;
  int backgroundColorValue;
  int gradientStartValue;
  int gradientEndValue;
  List<TextLayer> layers;
  DateTime updatedAt;

  Color get backgroundColor => Color(backgroundColorValue);
  Color get gradientStart => Color(gradientStartValue);
  Color get gradientEnd => Color(gradientEndValue);

  StoryDocument copy() => StoryDocument.fromJson(toJson());

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'size': size.index,
        'backgroundKind': backgroundKind.index,
        'backgroundColorValue': backgroundColorValue,
        'gradientStartValue': gradientStartValue,
        'gradientEndValue': gradientEndValue,
        'updatedAt': updatedAt.toIso8601String(),
        'layers': layers.map((TextLayer l) => l.toJson()).toList(),
      };

  factory StoryDocument.fromJson(Map<String, dynamic> j) {
    int i(String k, int fallback) => (j[k] as num?)?.toInt() ?? fallback;
    return StoryDocument(
      id: j['id'] as String,
      name: j['name'] as String? ?? 'Untitled',
      size: CanvasSize.values[i('size', 0)],
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
