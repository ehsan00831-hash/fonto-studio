import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/story_document.dart';
import '../models/text_layer.dart';
import '../state/editor_controller.dart';
import 'text_layer_view.dart';

/// The editable canvas: background + text layers, wrapped in a RepaintBoundary
/// so it can be captured to PNG. Handles selection, drag, pinch-scale and
/// rotate on the selected layer.
class StoryCanvas extends StatelessWidget {
  const StoryCanvas({super.key, this.interactive = true});

  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final EditorController c = context.watch<EditorController>();
    final StoryDocument doc = c.doc;
    final Size docSize = doc.size.pixels;

    return Center(
      child: AspectRatio(
        aspectRatio: docSize.width / docSize.height,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints cons) {
            final double displayW = cons.maxWidth;
            final double displayH = cons.maxHeight;
            final double k = displayW / docSize.width;

            return RepaintBoundary(
              key: c.exportKey,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: interactive ? () => c.select(null) : null,
                child: Stack(
                  fit: StackFit.expand,
                  children: <Widget>[
                    _background(doc),
                    for (final TextLayer layer in doc.layers)
                      _positioned(context, c, layer, displayW, displayH, k),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _background(StoryDocument doc) {
    switch (doc.backgroundKind) {
      case BackgroundKind.transparent:
        return const SizedBox.expand();
      case BackgroundKind.solid:
        return ColoredBox(color: doc.backgroundColor);
      case BackgroundKind.gradient:
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: <Color>[doc.gradientStart, doc.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
    }
  }

  Widget _positioned(
    BuildContext context,
    EditorController c,
    TextLayer layer,
    double displayW,
    double displayH,
    double k,
  ) {
    final bool selected = interactive && c.selectedId == layer.id;

    Widget child = Container(
      decoration: selected
          ? BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.primary,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(4),
            )
          : null,
      padding: const EdgeInsets.all(6),
      child: TextLayerView(layer: layer, k: k),
    );

    if (interactive) {
      double baseScale = 1;
      double baseRotation = 0;
      child = GestureDetector(
        behavior: HitTestBehavior.deferToChild,
        onTap: () => c.select(layer.id),
        onScaleStart: (_) {
          c.select(layer.id);
          baseScale = layer.scale;
          baseRotation = layer.rotation;
        },
        onScaleUpdate: (ScaleUpdateDetails d) {
          c.dragSelected(d.focalPointDelta.dx / displayW, d.focalPointDelta.dy / displayH);
          if (d.pointerCount >= 2) {
            c.transformSelected(
              scale: baseScale * d.scale,
              rotation: baseRotation + d.rotation,
            );
          }
        },
        onScaleEnd: (_) => c.commitGesture(),
        child: child,
      );
    }

    return Align(
      alignment: Alignment(layer.dx * 2 - 1, layer.dy * 2 - 1),
      child: child,
    );
  }
}
