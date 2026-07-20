import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../shared/checkerboard.dart';
import '../models/story_document.dart';
import '../models/text_layer.dart';
import '../state/editor_controller.dart';
import 'text_layer_view.dart';

/// The editable document surface.
///
/// Layering, outermost first:
///   InteractiveViewer  — zoom & pan (chrome, never exported)
///     AspectRatio      — locks the document's aspect ratio
///       Stack
///         checkerboard — transparency indicator, OUTSIDE the boundary
///         RepaintBoundary(exportKey) — exactly what gets exported
///           background + visible text layers
class StoryCanvas extends StatelessWidget {
  const StoryCanvas({
    super.key,
    this.interactive = true,
    this.transformationController,
  });

  final bool interactive;
  final TransformationController? transformationController;

  @override
  Widget build(BuildContext context) {
    final EditorController c = context.watch<EditorController>();
    final StoryDocument doc = c.doc;

    final Widget canvas = Center(
      child: AspectRatio(
        aspectRatio: doc.aspectRatio,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints cons) {
            final double displayW = cons.maxWidth;
            final double displayH = cons.maxHeight;
            final double k = displayW / doc.pixels.width;

            return Stack(
              fit: StackFit.expand,
              children: <Widget>[
                // Outside the boundary on purpose: never exported.
                if (doc.isTransparent)
                  const CustomPaint(painter: CheckerboardPainter(dark: true)),
                RepaintBoundary(
                  key: c.exportKey,
                  child: Stack(
                    fit: StackFit.expand,
                    children: <Widget>[
                      _background(doc),
                      for (final TextLayer layer in doc.visibleLayers)
                        _positioned(context, c, layer, displayW, displayH, k),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );

    if (!interactive) return canvas;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => c.select(null),
      child: InteractiveViewer(
        transformationController: transformationController,
        minScale: 0.3,
        maxScale: 6,
        boundaryMargin: const EdgeInsets.all(360),
        clipBehavior: Clip.none,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: canvas,
        ),
      ),
    );
  }

  Widget _background(StoryDocument doc) {
    switch (doc.backgroundKind) {
      case BackgroundKind.transparent:
        // Paints nothing: the exported PNG keeps alpha 0 here.
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

    Widget child = TextLayerView(layer: layer, k: k);

    if (selected) {
      child = Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.all(4),
        child: child,
      );
    } else {
      child = Padding(padding: const EdgeInsets.all(4), child: child);
    }

    if (interactive && !layer.locked) {
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
