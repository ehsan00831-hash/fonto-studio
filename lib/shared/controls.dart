import 'package:flutter/material.dart';

/// A labelled slider row used throughout the inspector.
class LabeledSlider extends StatelessWidget {
  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.onChangeEnd,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final int? divisions;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 92,
          child: Text(label, style: Theme.of(context).textTheme.bodySmall),
        ),
        Expanded(
          child: Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: divisions,
            label: value.toStringAsFixed(divisions == null ? 2 : 0),
            onChanged: onChanged,
            onChangeEnd: onChangeEnd,
          ),
        ),
      ],
    );
  }
}

/// A compact swatch palette that reports the picked ARGB int.
class ColorRow extends StatelessWidget {
  const ColorRow({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.allowAlpha = false,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final bool allowAlpha;

  static const List<int> _palette = <int>[
    0xFFFFFFFF, 0xFF000000, 0xFFFFD76A, 0xFFFF7AE0, 0xFF4F8BFF,
    0xFF2FE07D, 0xFFFF5A3C, 0xFFC05AFF, 0xFF22E0E0, 0xFFFFAB2E,
    0xFF0E1016, 0xFFB0B7C3,
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 92,
            child: Text(label, style: Theme.of(context).textTheme.bodySmall),
          ),
          Expanded(
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: <Widget>[
                for (final int c in _palette)
                  GestureDetector(
                    onTap: () => onChanged(c),
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        color: Color(c),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: (value == c)
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white24,
                          width: (value == c) ? 2.5 : 1,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A titled expandable section for grouping inspector controls.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.children,
    this.trailing,
    this.initiallyExpanded = false,
  });

  final String title;
  final List<Widget> children;
  final Widget? trailing;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          title: Text(title, style: Theme.of(context).textTheme.titleSmall),
          trailing: trailing,
          childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
          children: children,
        ),
      ),
    );
  }
}
