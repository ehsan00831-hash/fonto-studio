import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/strings.dart';
import '../../shared/controls.dart';
import 'models/story_document.dart';
import 'state/editor_controller.dart';
import 'widgets/inspector_panel.dart';
import 'widgets/layers_panel.dart';
import 'widgets/story_canvas.dart';

/// v0.2 editor: the canvas owns the screen, and every tool opens in a
/// draggable sheet over it instead of permanently stealing height.
class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  final TransformationController _tc = TransformationController();
  final TextEditingController _wCtl = TextEditingController();
  final TextEditingController _hCtl = TextEditingController();

  @override
  void dispose() {
    _tc.dispose();
    _wCtl.dispose();
    _hCtl.dispose();
    super.dispose();
  }

  double get _zoom => _tc.value.getMaxScaleOnAxis();

  void _zoomBy(double factor) {
    final double next = (_zoom * factor).clamp(0.3, 6.0);
    _tc.value = Matrix4.diagonal3Values(next, next, 1);
    setState(() {});
  }

  void _fit() {
    _tc.value = Matrix4.identity();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final EditorController c = context.watch<EditorController>();
    final S s = S.of(context);

    return Column(
      children: <Widget>[
        _topBar(context, c, s),
        Expanded(
          child: ColoredBox(
            color: const Color(0xFF0A0C12),
            child: StoryCanvas(transformationController: _tc),
          ),
        ),
        _toolBar(context, c, s),
      ],
    );
  }

  // ---- top bar: doc info, zoom, history --------------------------------------

  Widget _topBar(BuildContext context, EditorController c, S s) {
    final Size px = c.doc.exportPixels;
    return Material(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(c.doc.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis),
                  // Forced LTR: in a Persian (RTL) paragraph the neutral
                  // "1080×1920" run gets bidi-reordered and reads backwards.
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      '${px.width.toInt()}×${px.height.toInt()} • ${c.doc.exportScale}x'
                      '${c.doc.isTransparent ? ' • alpha' : ''}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: s.zoomOut,
              icon: const Icon(Icons.zoom_out),
              onPressed: () => _zoomBy(1 / 1.25),
            ),
            InkWell(
              onTap: _fit,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                child: Text('${(_zoom * 100).round()}%',
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            ),
            IconButton(
              tooltip: s.zoomIn,
              icon: const Icon(Icons.zoom_in),
              onPressed: () => _zoomBy(1.25),
            ),
            IconButton(
              tooltip: s.fitToScreen,
              icon: const Icon(Icons.fit_screen),
              onPressed: _fit,
            ),
            IconButton(
              tooltip: s.undo,
              icon: const Icon(Icons.undo),
              onPressed: c.canUndo ? c.undo : null,
            ),
            IconButton(
              tooltip: s.redo,
              icon: const Icon(Icons.redo),
              onPressed: c.canRedo ? c.redo : null,
            ),
          ],
        ),
      ),
    );
  }

  // ---- bottom tool bar --------------------------------------------------------

  Widget _toolBar(BuildContext context, EditorController c, S s) {
    return Material(
      color: Theme.of(context).appBarTheme.backgroundColor,
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          key: const ValueKey<String>('editor-toolbar'),
          scrollDirection: Axis.horizontal,
          child: Row(
            children: <Widget>[
              _tool(context, Icons.add, s.addRtl, () => c.addTextLayer(rtl: true)),
              _tool(context, Icons.translate, s.addLtr, () => c.addTextLayer(rtl: false)),
              _tool(context, Icons.layers, s.layers,
                  () => _sheet(context, s.layers, const LayersPanel())),
              _tool(context, Icons.tune, s.style,
                  () => _sheet(context, s.style, const InspectorPanel())),
              _tool(context, Icons.wallpaper, s.background,
                  () => _sheet(context, s.background, _backgroundSheet(context, c, s))),
              _tool(context, Icons.aspect_ratio, s.canvas,
                  () => _sheet(context, s.canvas, _canvasSheet(context, c, s))),
              _tool(context, Icons.save_outlined, s.saveDraft, () async {
                await c.saveDraft();
                if (context.mounted) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text(s.saveDraft)));
                }
              }),
              _tool(context, Icons.folder_open, s.drafts,
                  () => _draftsSheet(context, c, s)),
              _tool(context, Icons.note_add_outlined, s.newDoc, c.newDocument),
              _tool(context, Icons.ios_share, s.export,
                  () => _sheet(context, s.export, _exportSheet(context, c, s))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tool(BuildContext context, IconData icon, String label, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(icon),
            onPressed: onTap,
            style: IconButton.styleFrom(
              foregroundColor: onTap == null
                  ? Theme.of(context).disabledColor
                  : Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(
            width: 62,
            child: Text(label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelSmall),
          ),
        ],
      ),
    );
  }

  /// Draggable sheet so the canvas stays visible behind the tools.
  void _sheet(BuildContext context, String title, Widget body) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.55,
        minChildSize: 0.3,
        maxChildSize: 0.92,
        builder: (BuildContext ctx, ScrollController sc) => Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(title, style: Theme.of(ctx).textTheme.titleMedium),
              ),
            ),
            const Divider(height: 12),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  // ---- sheets -----------------------------------------------------------------

  Widget _backgroundSheet(BuildContext context, EditorController c, S s) {
    return StatefulBuilder(
      builder: (BuildContext ctx, StateSetter setLocal) {
        final StoryDocument d = c.doc;
        return ListView(
          padding: const EdgeInsets.all(16),
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
                setLocal(() {});
              },
            ),
            const SizedBox(height: 12),
            if (d.isTransparent)
              Text(s.transparentHint, style: Theme.of(ctx).textTheme.bodySmall),
            if (d.backgroundKind == BackgroundKind.solid)
              ColorRow(
                label: s.color,
                value: d.backgroundColorValue,
                onChanged: (int v) {
                  c.setBackground(colorValue: v);
                  setLocal(() {});
                },
              ),
            if (d.backgroundKind == BackgroundKind.gradient) ...<Widget>[
              ColorRow(
                label: s.get('شروع', 'Start'),
                value: d.gradientStartValue,
                onChanged: (int v) {
                  c.setBackground(gradientStart: v);
                  setLocal(() {});
                },
              ),
              ColorRow(
                label: s.get('پایان', 'End'),
                value: d.gradientEndValue,
                onChanged: (int v) {
                  c.setBackground(gradientEnd: v);
                  setLocal(() {});
                },
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _canvasSheet(BuildContext context, EditorController c, S s) {
    return StatefulBuilder(
      builder: (BuildContext ctx, StateSetter setLocal) {
        if (_wCtl.text.isEmpty) {
          _wCtl.text = c.doc.customWidth.toInt().toString();
          _hCtl.text = c.doc.customHeight.toInt().toString();
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            for (final CanvasSize size in CanvasSize.values)
              ListTile(
                dense: true,
                selected: c.doc.size == size,
                title: Text(size.label),
                subtitle: size == CanvasSize.custom
                    ? null
                    : Text('${size.pixels.width.toInt()}×${size.pixels.height.toInt()}'),
                trailing: c.doc.size == size ? const Icon(Icons.check) : null,
                onTap: () {
                  c.setCanvasSize(size);
                  setLocal(() {});
                },
              ),
            if (c.doc.size == CanvasSize.custom)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: _wCtl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: s.widthPx),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _hCtl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(labelText: s.heightPx),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FilledButton(
                      onPressed: () {
                        c.setCanvasSize(
                          CanvasSize.custom,
                          width: double.tryParse(_wCtl.text) ?? c.doc.customWidth,
                          height: double.tryParse(_hCtl.text) ?? c.doc.customHeight,
                        );
                        setLocal(() {});
                      },
                      child: Text(s.apply),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _exportSheet(BuildContext context, EditorController c, S s) {
    return StatefulBuilder(
      builder: (BuildContext ctx, StateSetter setLocal) {
        final Size px = c.doc.exportPixels;
        return ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text(s.resolution, style: Theme.of(ctx).textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const <ButtonSegment<int>>[
                ButtonSegment<int>(value: 1, label: Text('1x')),
                ButtonSegment<int>(value: 2, label: Text('2x')),
                ButtonSegment<int>(value: 3, label: Text('3x')),
                ButtonSegment<int>(value: 4, label: Text('4x')),
              ],
              selected: <int>{c.doc.exportScale},
              onSelectionChanged: (Set<int> v) {
                c.setExportScale(v.first);
                setLocal(() {});
              },
            ),
            const SizedBox(height: 8),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text('${px.width.toInt()} × ${px.height.toInt()} px',
                    style: Theme.of(ctx).textTheme.bodyMedium),
              ),
            ),
            if (c.doc.isTransparent) ...<Widget>[
              const SizedBox(height: 8),
              Text(s.transparentHint, style: Theme.of(ctx).textTheme.bodySmall),
            ],
            const SizedBox(height: 20),
            FilledButton.icon(
              icon: const Icon(Icons.ios_share),
              label: Text(s.sharePng),
              onPressed: () async {
                Navigator.pop(ctx);
                await c.shareExport();
              },
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.download),
              label: Text(s.savePng),
              onPressed: () async {
                final File? f = await c.exportToFile();
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(f == null ? 'Export failed' : '${s.exported}: ${f.path}')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _draftsSheet(BuildContext context, EditorController c, S s) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext ctx) {
        return FutureBuilder<List<StoryDocument>>(
          future: c.loadDrafts(),
          builder: (BuildContext ctx, AsyncSnapshot<List<StoryDocument>> snap) {
            final List<StoryDocument> drafts = snap.data ?? <StoryDocument>[];
            if (drafts.isEmpty) {
              return SizedBox(height: 160, child: Center(child: Text(s.noDrafts)));
            }
            return ListView.builder(
              shrinkWrap: true,
              itemCount: drafts.length,
              itemBuilder: (BuildContext ctx, int i) {
                final StoryDocument d = drafts[i];
                return ListTile(
                  title: Text('${d.name} • ${d.layers.length} ${s.layers}'),
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
