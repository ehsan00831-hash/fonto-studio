import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/fonts/font_catalog.dart';
import '../../../core/strings.dart';
import '../../../shared/controls.dart';
import '../models/text_layer.dart';
import '../state/editor_controller.dart';
import '../../gallery/font_picker_sheet.dart';

/// The per-layer property editor shown for the selected text layer.
class InspectorPanel extends StatelessWidget {
  const InspectorPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final EditorController c = context.watch<EditorController>();
    final S s = S.of(context);
    final TextLayer? l = c.selected;

    if (l == null) {
      return Center(
        child: Text(s.nothingSelected, style: Theme.of(context).textTheme.bodyMedium),
      );
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        SectionCard(
          title: s.text,
          initiallyExpanded: true,
          children: <Widget>[
            TextFormField(
              initialValue: l.text,
              maxLines: null,
              textDirection: l.isRTL ? TextDirection.rtl : TextDirection.ltr,
              decoration: InputDecoration(hintText: s.text),
              onChanged: (String v) => c.editSelected((TextLayer x) => x.text = v),
            ),
            const SizedBox(height: 8),
            Row(
              children: <Widget>[
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.font_download_outlined),
                    label: Text(l.fontFamily, overflow: TextOverflow.ellipsis),
                    onPressed: () async {
                      final String? fam = await showFontPicker(context, current: l.fontFamily);
                      if (fam != null) {
                        c.editSelected((TextLayer x) => x.fontFamily = fam);
                        if (context.mounted) context.read<FontCatalog>().markUsed(fam);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SegmentedButton<bool>(
                  segments: <ButtonSegment<bool>>[
                    ButtonSegment<bool>(value: true, label: Text(s.get('راست', 'RTL'))),
                    ButtonSegment<bool>(value: false, label: Text(s.get('چپ', 'LTR'))),
                  ],
                  selected: <bool>{l.isRTL},
                  onSelectionChanged: (Set<bool> v) =>
                      c.editSelected((TextLayer x) => x.isRTL = v.first),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _alignRow(context, c, l, s),
          ],
        ),
        SectionCard(
          title: '${s.size} • ${s.color} • ${s.weight}',
          initiallyExpanded: true,
          children: <Widget>[
            LabeledSlider(
              label: s.size,
              value: l.fontSize,
              min: 10,
              max: 160,
              onChanged: (double v) => c.editSelected((TextLayer x) => x.fontSize = v),
            ),
            LabeledSlider(
              label: s.weight,
              value: l.fontWeightIndex.toDouble(),
              min: 0,
              max: 8,
              divisions: 8,
              onChanged: (double v) =>
                  c.editSelected((TextLayer x) => x.fontWeightIndex = v.round()),
            ),
            LabeledSlider(
              label: s.letterSpacing,
              value: l.letterSpacing,
              min: -5,
              max: 20,
              onChanged: (double v) => c.editSelected((TextLayer x) => x.letterSpacing = v),
            ),
            LabeledSlider(
              label: s.lineHeight,
              value: l.lineHeight,
              min: 0.8,
              max: 2.4,
              onChanged: (double v) => c.editSelected((TextLayer x) => x.lineHeight = v),
            ),
            ColorRow(
              label: s.color,
              value: l.colorValue,
              onChanged: (int v) => c.editSelected((TextLayer x) => x.colorValue = v),
            ),
          ],
        ),
        SectionCard(
          title: '${s.rotation} • ${s.scale} • ${s.opacity}',
          children: <Widget>[
            LabeledSlider(
              label: s.rotation,
              value: l.rotation,
              min: -3.14159,
              max: 3.14159,
              onChanged: (double v) => c.transformSelected(rotation: v),
              onChangeEnd: (_) => c.commitGesture(),
            ),
            LabeledSlider(
              label: s.scale,
              value: l.scale,
              min: 0.2,
              max: 4,
              onChanged: (double v) => c.transformSelected(scale: v),
              onChangeEnd: (_) => c.commitGesture(),
            ),
            LabeledSlider(
              label: s.opacity,
              value: l.opacity,
              min: 0,
              max: 1,
              onChanged: (double v) => c.editSelected((TextLayer x) => x.opacity = v),
            ),
          ],
        ),
        SectionCard(
          title: s.shadow,
          trailing: Switch(
            value: l.shadowEnabled,
            onChanged: (bool v) => c.editSelected((TextLayer x) => x.shadowEnabled = v),
          ),
          children: <Widget>[
            LabeledSlider(
              label: s.blur,
              value: l.shadowBlur,
              min: 0,
              max: 40,
              onChanged: (double v) => c.editSelected((TextLayer x) => x.shadowBlur = v),
            ),
            LabeledSlider(
              label: 'X',
              value: l.shadowDx,
              min: -30,
              max: 30,
              onChanged: (double v) => c.editSelected((TextLayer x) => x.shadowDx = v),
            ),
            LabeledSlider(
              label: 'Y',
              value: l.shadowDy,
              min: -30,
              max: 30,
              onChanged: (double v) => c.editSelected((TextLayer x) => x.shadowDy = v),
            ),
            ColorRow(
              label: s.color,
              value: l.shadowColorValue,
              onChanged: (int v) => c.editSelected((TextLayer x) => x.shadowColorValue = v),
            ),
          ],
        ),
        SectionCard(
          title: s.stroke,
          trailing: Switch(
            value: l.strokeEnabled,
            onChanged: (bool v) => c.editSelected((TextLayer x) => x.strokeEnabled = v),
          ),
          children: <Widget>[
            LabeledSlider(
              label: s.width,
              value: l.strokeWidth,
              min: 0.5,
              max: 16,
              onChanged: (double v) => c.editSelected((TextLayer x) => x.strokeWidth = v),
            ),
            ColorRow(
              label: s.color,
              value: l.strokeColorValue,
              onChanged: (int v) => c.editSelected((TextLayer x) => x.strokeColorValue = v),
            ),
          ],
        ),
        SectionCard(
          title: s.gradient,
          trailing: Switch(
            value: l.gradientEnabled,
            onChanged: (bool v) => c.editSelected((TextLayer x) => x.gradientEnabled = v),
          ),
          children: <Widget>[
            ColorRow(
              label: s.get('شروع', 'Start'),
              value: l.gradientStartValue,
              onChanged: (int v) => c.editSelected((TextLayer x) => x.gradientStartValue = v),
            ),
            ColorRow(
              label: s.get('پایان', 'End'),
              value: l.gradientEndValue,
              onChanged: (int v) => c.editSelected((TextLayer x) => x.gradientEndValue = v),
            ),
          ],
        ),
        SectionCard(
          title: s.box,
          trailing: Switch(
            value: l.boxEnabled,
            onChanged: (bool v) => c.editSelected((TextLayer x) => x.boxEnabled = v),
          ),
          children: <Widget>[
            LabeledSlider(
              label: s.radius,
              value: l.boxRadius,
              min: 0,
              max: 60,
              onChanged: (double v) => c.editSelected((TextLayer x) => x.boxRadius = v),
            ),
            LabeledSlider(
              label: s.padding,
              value: l.boxPadding,
              min: 0,
              max: 60,
              onChanged: (double v) => c.editSelected((TextLayer x) => x.boxPadding = v),
            ),
            ColorRow(
              label: s.color,
              value: l.boxColorValue,
              onChanged: (int v) => c.editSelected((TextLayer x) => x.boxColorValue = v),
            ),
          ],
        ),
      ],
    );
  }

  Widget _alignRow(BuildContext context, EditorController c, TextLayer l, S s) {
    return SegmentedButton<TextAlign>(
      segments: const <ButtonSegment<TextAlign>>[
        ButtonSegment<TextAlign>(value: TextAlign.right, icon: Icon(Icons.format_align_right)),
        ButtonSegment<TextAlign>(value: TextAlign.center, icon: Icon(Icons.format_align_center)),
        ButtonSegment<TextAlign>(value: TextAlign.left, icon: Icon(Icons.format_align_left)),
      ],
      selected: <TextAlign>{_normAlign(l.align)},
      onSelectionChanged: (Set<TextAlign> v) =>
          c.editSelected((TextLayer x) => x.align = v.first),
    );
  }

  TextAlign _normAlign(TextAlign a) {
    if (a == TextAlign.right || a == TextAlign.center || a == TextAlign.left) return a;
    return TextAlign.center;
  }
}
