import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/strings.dart';
import '../story/models/story_document.dart';
import '../story/models/text_layer.dart';
import '../story/state/editor_controller.dart';
import 'gallery_data.dart';

/// The Gallery: ready-made backgrounds and full templates that apply to the
/// editor. Every item is functional — tapping applies it and jumps to Story.
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key, required this.goToEditor});

  final VoidCallback goToEditor;

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  int _tab = 0;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final EditorController c = context.read<EditorController>();

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: s.search,
              border: const OutlineInputBorder(),
            ),
            onChanged: (String v) => setState(() => _query = v),
          ),
        ),
        SegmentedButton<int>(
          segments: <ButtonSegment<int>>[
            ButtonSegment<int>(value: 0, label: Text(s.backgrounds)),
            ButtonSegment<int>(value: 1, label: Text(s.templates)),
          ],
          selected: <int>{_tab},
          onSelectionChanged: (Set<int> v) => setState(() => _tab = v.first),
        ),
        const SizedBox(height: 8),
        Expanded(child: _tab == 0 ? _backgrounds(c) : _templates(c)),
      ],
    );
  }

  Widget _backgrounds(EditorController c) {
    final List<BackgroundPreset> items = kBackgroundPresets
        .where((BackgroundPreset p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 0.62,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int i) {
        final BackgroundPreset p = items[i];
        return GestureDetector(
          onTap: () {
            if (p.gradient) {
              c.setBackground(
                kind: BackgroundKind.gradient,
                gradientStart: p.a,
                gradientEnd: p.b,
              );
            } else {
              c.setBackground(kind: BackgroundKind.solid, colorValue: p.a);
            }
            widget.goToEditor();
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: p.gradient ? null : Color(p.a),
                gradient: p.gradient
                    ? LinearGradient(
                        colors: <Color>[Color(p.a), Color(p.b)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  color: Colors.black45,
                  padding: const EdgeInsets.all(4),
                  child: Text(p.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 10, color: Colors.white)),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _templates(EditorController c) {
    final List<TemplatePreset> items = kTemplatePresets
        .where((TemplatePreset p) => p.name.toLowerCase().contains(_query.toLowerCase()))
        .toList();
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (BuildContext context, int i) {
        final TemplatePreset p = items[i];
        final StoryDocument preview = p.build();
        return Card(
          child: ListTile(
            leading: SizedBox(
              width: 44,
              height: 78,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: _templateThumb(preview),
              ),
            ),
            title: Text(p.name),
            subtitle: Text('${preview.layers.length} ${S.of(context).text}'),
            trailing: FilledButton(
              onPressed: () {
                c.openDocument(p.build());
                widget.goToEditor();
              },
              child: Text(S.of(context).useTemplate),
            ),
          ),
        );
      },
    );
  }

  Widget _templateThumb(StoryDocument d) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: d.backgroundKind == BackgroundKind.solid ? d.backgroundColor : null,
        gradient: d.backgroundKind == BackgroundKind.gradient
            ? LinearGradient(colors: <Color>[d.gradientStart, d.gradientEnd])
            : null,
      ),
      child: Stack(
        children: <Widget>[
          for (final TextLayer l in d.layers)
            Align(
              alignment: Alignment(l.dx * 2 - 1, l.dy * 2 - 1),
              child: Text('آ',
                  style: TextStyle(
                      color: l.color, fontSize: 10, fontFamily: l.fontFamily)),
            ),
        ],
      ),
    );
  }
}
