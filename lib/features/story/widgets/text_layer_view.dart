import 'package:flutter/material.dart';

import '../models/text_layer.dart';

/// Renders one [TextLayer] with all of its styling. Used identically in the
/// live editor and in the export capture, so what you see is what you get.
///
/// [k] scales document-pixel values (fontSize, stroke, shadow, box) to the
/// current display size; export re-captures this same widget at higher pixel
/// ratio, so no separate export path is needed.
class TextLayerView extends StatelessWidget {
  const TextLayerView({super.key, required this.layer, required this.k});

  final TextLayer layer;
  final double k;

  @override
  Widget build(BuildContext context) {
    final double fontSize = layer.fontSize * layer.scale * k;

    final List<Shadow> shadows = layer.shadowEnabled
        ? <Shadow>[
            Shadow(
              color: Color(layer.shadowColorValue),
              blurRadius: layer.shadowBlur * k,
              offset: Offset(layer.shadowDx * k, layer.shadowDy * k),
            ),
          ]
        : const <Shadow>[];

    TextStyle base(Paint? foreground, Color? color) => TextStyle(
          fontFamily: layer.fontFamily,
          fontSize: fontSize,
          fontWeight: layer.fontWeight,
          letterSpacing: layer.letterSpacing * k,
          height: layer.lineHeight,
          color: color,
          foreground: foreground,
          shadows: shadows,
        );

    Widget fill;
    if (layer.gradientEnabled) {
      fill = ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (Rect rect) => LinearGradient(
          colors: <Color>[Color(layer.gradientStartValue), Color(layer.gradientEndValue)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(rect),
        child: Text(
          layer.text,
          textAlign: layer.align,
          textDirection: layer.isRTL ? TextDirection.rtl : TextDirection.ltr,
          style: base(null, Colors.white),
        ),
      );
    } else {
      fill = Text(
        layer.text,
        textAlign: layer.align,
        textDirection: layer.isRTL ? TextDirection.rtl : TextDirection.ltr,
        style: base(null, layer.color),
      );
    }

    Widget content = fill;
    if (layer.strokeEnabled) {
      final Paint strokePaint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = layer.strokeWidth * k
        ..strokeJoin = StrokeJoin.round
        ..color = Color(layer.strokeColorValue);
      content = Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Text(
            layer.text,
            textAlign: layer.align,
            textDirection: layer.isRTL ? TextDirection.rtl : TextDirection.ltr,
            style: base(strokePaint, null),
          ),
          fill,
        ],
      );
    }

    if (layer.boxEnabled) {
      content = Container(
        padding: EdgeInsets.symmetric(
          horizontal: layer.boxPadding * k * 1.4,
          vertical: layer.boxPadding * k,
        ),
        decoration: BoxDecoration(
          color: Color(layer.boxColorValue),
          borderRadius: BorderRadius.circular(layer.boxRadius * k),
        ),
        child: content,
      );
    }

    return Opacity(
      opacity: layer.opacity,
      child: Transform.rotate(
        angle: layer.rotation,
        child: content,
      ),
    );
  }
}
