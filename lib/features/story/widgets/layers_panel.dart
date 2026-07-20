import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/strings.dart';
import '../models/text_layer.dart';
import '../state/editor_controller.dart';

/// Reorderable layer stack. Shown topmost-first, which is the reverse of paint
/// order — [EditorController.reorderLayers] flips the indices.
class LayersPanel extends StatelessWidget {
  const LayersPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final EditorController c = context.watch<EditorController>();
    final S s = S.of(context);
    final List<TextLayer> top = c.doc.layers.reversed.toList();

    if (top.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(s.noLayers, textAlign: TextAlign.center),
        ),
      );
    }

    return ReorderableListView.builder(
      buildDefaultDragHandles: false,
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: top.length,
      onReorderItem: c.reorderLayers,
      itemBuilder: (BuildContext context, int i) {
        final TextLayer l = top[i];
        final bool sel = c.selectedId == l.id;
        return Material(
          key: ValueKey<String>(l.id),
          color: sel
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.45)
              : Colors.transparent,
          child: ListTile(
            dense: true,
            onTap: () => c.select(l.id),
            leading: ReorderableDragStartListener(
              index: i,
              child: const Icon(Icons.drag_indicator),
            ),
            title: Text(
              l.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textDirection: l.isRTL ? TextDirection.rtl : TextDirection.ltr,
              style: TextStyle(
                fontFamily: l.fontFamily,
                color: l.visible ? null : Theme.of(context).disabledColor,
              ),
            ),
            subtitle: Text(
              '${l.fontFamily} • ${l.fontSize.round()}px${l.locked ? ' • ${s.locked}' : ''}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                IconButton(
                  tooltip: s.visibility,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(l.visible ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => c.toggleVisible(l.id),
                ),
                IconButton(
                  tooltip: s.lock,
                  visualDensity: VisualDensity.compact,
                  icon: Icon(l.locked ? Icons.lock : Icons.lock_open),
                  onPressed: () => c.toggleLock(l.id),
                ),
                PopupMenuButton<String>(
                  onSelected: (String v) {
                    if (v == 'dup') c.duplicateLayer(l.id);
                    if (v == 'del') c.deleteLayer(l.id);
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(value: 'dup', child: Text(s.duplicate)),
                    PopupMenuItem<String>(value: 'del', child: Text(s.delete)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
