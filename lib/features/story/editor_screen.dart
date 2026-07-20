import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/strings.dart';
import '../../shared/controls.dart';
import 'models/story_document.dart';
import 'state/editor_controller.dart';
import 'widgets/inspector_panel.dart';
import 'widgets/story_canvas.dart';

/// The Story editor: canvas on top, action bar, and the layer inspector below.
class EditorScreen extends StatelessWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final EditorController c = context.watch<EditorController>();
    final S s = S.of(context);

    return Column(
      children: <Widget>[
        Expanded(
          flex: 5,
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.all(12),
            child: const StoryCanvas(),
          ),
        ),
        _actionBar(context, c, s),
        const Expanded(
          flex: 4,
          child: InspectorPanel(),
        ),
      ],
    );
  }

  Widget _actionBar(BuildContext context, EditorController c, S s) {
    return Material(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            _btn(context, Icons.add, s.addRtl, () => c.addTextLayer(rtl: true)),
            _btn(context, Icons.abc, s.addLtr, () => c.addTextLayer(rtl: false)),
            _btn(context, Icons.undo, s.undo, c.canUndo ? c.undo : null),
            _btn(context, Icons.redo, s.redo, c.canRedo ? c.redo : null),
            _btn(context, Icons.flip_to_front, s.bringFront,
                c.selected != null ? c.bringToFront : null),
            _btn(context, Icons.delete_outline, s.delete,
                c.selected != null ? c.deleteSelected : null),
            _btn(context, Icons.wallpaper, s.background, () => _backgroundSheet(context, c, s)),
            _btn(context, Icons.aspect_ratio, s.canvas, () => _sizeSheet(context, c, s)),
            _btn(context, Icons.save_outlined, s.saveDraft, () async {
              await c.saveDraft();
              if (context.mounted) {
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(s.saveDraft)));
              }
            }),
            _btn(context, Icons.folder_open, s.drafts, () => _draftsSheet(context, c, s)),
            _btn(context, Icons.note_add_outlined, s.newDoc, c.newDocument),
            _btn(context, Icons.ios_share, s.export, () async {
              await c.shareExport();
            }),
          ],
        ),
      ),
    );
  }

  Widget _btn(BuildContext context, IconData icon, String tip, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
      child: Tooltip(
        message: tip,
        child: IconButton(
          icon: Icon(icon),
          onPressed: onTap,
          style: IconButton.styleFrom(
            foregroundColor: onTap == null
                ? Theme.of(context).disabledColor
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }

  void _backgroundSheet(BuildContext context, EditorController c, S s) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) {
        return StatefulBuilder(
          builder: (BuildContext ctx, StateSetter setState) {
            final StoryDocument d = c.doc;
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SegmentedButton<BackgroundKind>(
                    segments: <ButtonSegment<BackgroundKind>>[
                      ButtonSegment<BackgroundKind>(
                          value: BackgroundKind.transparent, label: Text(s.transparent)),
                      ButtonSegment<BackgroundKind>(
                          value: BackgroundKind.solid, label: Text(s.solid)),
                      ButtonSegment<BackgroundKind>(
                          value: BackgroundKind.gradient, label: Text(s.gradient)),
                    ],
                    selected: <BackgroundKind>{d.backgroundKind},
                    onSelectionChanged: (Set<BackgroundKind> v) {
                      c.setBackground(kind: v.first);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 12),
                  if (d.backgroundKind == BackgroundKind.solid)
                    ColorRow(
                      label: s.color,
                      value: d.backgroundColorValue,
                      onChanged: (int v) {
                        c.setBackground(colorValue: v);
                        setState(() {});
                      },
                    ),
                  if (d.backgroundKind == BackgroundKind.gradient) ...<Widget>[
                    ColorRow(
                      label: s.get('شروع', 'Start'),
                      value: d.gradientStartValue,
                      onChanged: (int v) {
                        c.setBackground(gradientStart: v);
                        setState(() {});
                      },
                    ),
                    ColorRow(
                      label: s.get('پایان', 'End'),
                      value: d.gradientEndValue,
                      onChanged: (int v) {
                        c.setBackground(gradientEnd: v);
                        setState(() {});
                      },
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _sizeSheet(BuildContext context, EditorController c, S s) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext ctx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final CanvasSize size in CanvasSize.values)
            ListTile(
              title: Text(size.label),
              trailing: c.doc.size == size ? const Icon(Icons.check) : null,
              onTap: () {
                c.setCanvasSize(size);
                Navigator.pop(ctx);
              },
            ),
        ],
      ),
    );
  }

  void _draftsSheet(BuildContext context, EditorController c, S s) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        return FutureBuilder<List<StoryDocument>>(
          future: c.loadDrafts(),
          builder: (BuildContext ctx, AsyncSnapshot<List<StoryDocument>> snap) {
            final List<StoryDocument> drafts = snap.data ?? <StoryDocument>[];
            if (drafts.isEmpty) {
              return SizedBox(
                height: 160,
                child: Center(child: Text(s.noDrafts)),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: drafts.length,
              itemBuilder: (BuildContext ctx, int i) {
                final StoryDocument d = drafts[i];
                return ListTile(
                  title: Text('${d.name} • ${d.layers.length} ${s.text}'),
                  subtitle: Text(d.updatedAt.toString().split('.').first),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await c.deleteDraft(d.id);
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                  ),
                  onTap: () {
                    c.openDocument(d);
                    Navigator.pop(ctx);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
