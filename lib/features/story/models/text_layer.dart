import 'package:flutter/material.dart';

/// A single editable text layer on the story canvas.
///
/// Geometry is stored as fractions of the canvas (0..1) so a document renders
/// identically at preview size and at full export resolution.
class TextLayer {
  TextLayer({
    required this.id,
    this.text = 'متن',
    this.isRTL = true,
    this.fontFamily = 'Vazirmatn',
    this.fontSize = 40,
    this.colorValue = 0xFFFFFFFF,
    this.fontWeightIndex = 3, // FontWeight.w400
    this.letterSpacing = 0,
    this.lineHeight = 1.3,
    this.align = TextAlign.center,
    this.dx = 0.5,
    this.dy = 0.5,
    this.rotation = 0,
    this.scale = 1,
    this.opacity = 1,
    this.shadowEnabled = false,
    this.shadowColorValue = 0xFF000000,
    this.shadowBlur = 8,
    this.shadowDx = 2,
    this.shadowDy = 2,
    this.strokeEnabled = false,
    this.strokeColorValue = 0xFF000000,
    this.strokeWidth = 3,
    this.gradientEnabled = false,
    this.gradientStartValue = 0xFFFFD76A,
    this.gradientEndValue = 0xFFFF7AE0,
    this.boxEnabled = false,
    this.boxColorValue = 0x99000000,
    this.boxRadius = 16,
    this.boxPadding = 14,
  });

  final String id;
  String text;
  bool isRTL;
  String fontFamily;
  double fontSize;
  int colorValue;
  int fontWeightIndex;
  double letterSpacing;
  double lineHeight;
  TextAlign align;

  // geometry (fractions of the canvas)
  double dx;
  double dy;
  double rotation;
  double scale;
  double opacity;

  // shadow
  bool shadowEnabled;
  int shadowColorValue;
  double shadowBlur;
  double shadowDx;
  double shadowDy;

  // stroke
  bool strokeEnabled;
  int strokeColorValue;
  double strokeWidth;

  // gradient fill
  bool gradientEnabled;
  int gradientStartValue;
  int gradientEndValue;

  // rounded background box
  bool boxEnabled;
  int boxColorValue;
  double boxRadius;
  double boxPadding;

  static const List<FontWeight> weights = <FontWeight>[
    FontWeight.w100,
    FontWeight.w200,
    FontWeight.w300,
    FontWeight.w400,
    FontWeight.w500,
    FontWeight.w600,
    FontWeight.w700,
    FontWeight.w800,
    FontWeight.w900,
  ];

  Color get color => Color(colorValue);
  FontWeight get fontWeight => weights[fontWeightIndex.clamp(0, weights.length - 1)];

  TextLayer copy() => TextLayer.fromJson(toJson());

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'text': text,
        'isRTL': isRTL,
        'fontFamily': fontFamily,
        'fontSize': fontSize,
        'colorValue': colorValue,
        'fontWeightIndex': fontWeightIndex,
        'letterSpacing': letterSpacing,
        'lineHeight': lineHeight,
        'align': align.index,
        'dx': dx,
        'dy': dy,
        'rotation': rotation,
        'scale': scale,
        'opacity': opacity,
        'shadowEnabled': shadowEnabled,
        'shadowColorValue': shadowColorValue,
        'shadowBlur': shadowBlur,
        'shadowDx': shadowDx,
        'shadowDy': shadowDy,
        'strokeEnabled': strokeEnabled,
        'strokeColorValue': strokeColorValue,
        'strokeWidth': strokeWidth,
        'gradientEnabled': gradientEnabled,
        'gradientStartValue': gradientStartValue,
        'gradientEndValue': gradientEndValue,
        'boxEnabled': boxEnabled,
        'boxColorValue': boxColorValue,
        'boxRadius': boxRadius,
        'boxPadding': boxPadding,
      };

  factory TextLayer.fromJson(Map<String, dynamic> j) {
    double d(String k, double fallback) => (j[k] as num?)?.toDouble() ?? fallback;
    int i(String k, int fallback) => (j[k] as num?)?.toInt() ?? fallback;
    return TextLayer(
      id: j['id'] as String,
      text: j['text'] as String? ?? '',
      isRTL: j['isRTL'] as bool? ?? true,
      fontFamily: j['fontFamily'] as String? ?? 'Vazirmatn',
      fontSize: d('fontSize', 40),
      colorValue: i('colorValue', 0xFFFFFFFF),
      fontWeightIndex: i('fontWeightIndex', 3),
      letterSpacing: d('letterSpacing', 0),
      lineHeight: d('lineHeight', 1.3),
      align: TextAlign.values[i('align', TextAlign.center.index)],
      dx: d('dx', 0.5),
      dy: d('dy', 0.5),
      rotation: d('rotation', 0),
      scale: d('scale', 1),
      opacity: d('opacity', 1),
      shadowEnabled: j['shadowEnabled'] as bool? ?? false,
      shadowColorValue: i('shadowColorValue', 0xFF000000),
      shadowBlur: d('shadowBlur', 8),
      shadowDx: d('shadowDx', 2),
      shadowDy: d('shadowDy', 2),
      strokeEnabled: j['strokeEnabled'] as bool? ?? false,
      strokeColorValue: i('strokeColorValue', 0xFF000000),
      strokeWidth: d('strokeWidth', 3),
      gradientEnabled: j['gradientEnabled'] as bool? ?? false,
      gradientStartValue: i('gradientStartValue', 0xFFFFD76A),
      gradientEndValue: i('gradientEndValue', 0xFFFF7AE0),
      boxEnabled: j['boxEnabled'] as bool? ?? false,
      boxColorValue: i('boxColorValue', 0x99000000),
      boxRadius: d('boxRadius', 16),
      boxPadding: d('boxPadding', 14),
    );
  }
}
