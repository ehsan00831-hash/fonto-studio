import '../story/models/story_document.dart';
import '../story/models/text_layer.dart';

/// A background preset: a solid colour (gradient=false) or a two-stop gradient.
class BackgroundPreset {
  const BackgroundPreset(this.name, this.a, this.b, {this.gradient = true});
  final String name;
  final int a;
  final int b;
  final bool gradient;
}

const List<BackgroundPreset> kBackgroundPresets = <BackgroundPreset>[
  BackgroundPreset('Galaxy Blue', 0xFF1B3FA8, 0xFF7FD0FF),
  BackgroundPreset('Aurora Green', 0xFF0B6B4F, 0xFF7DFFCF),
  BackgroundPreset('Ember Red', 0xFF8C1616, 0xFFFFB36B),
  BackgroundPreset('Nebula Purple', 0xFF4A1B8C, 0xFFFF7AE0),
  BackgroundPreset('Cyan Deep', 0xFF0B5C6B, 0xFF9FFCFF),
  BackgroundPreset('Golden Hour', 0xFF6B4A0B, 0xFFFFD97A),
  BackgroundPreset('Midnight', 0xFF0E1016, 0xFF232842),
  BackgroundPreset('Sunset', 0xFFFF5A3C, 0xFFC05AFF),
  BackgroundPreset('Ink', 0xFF000000, 0xFF000000, gradient: false),
  BackgroundPreset('Paper', 0xFFF4EFE6, 0xFFF4EFE6, gradient: false),
  BackgroundPreset('Slate', 0xFF1E2430, 0xFF1E2430, gradient: false),
  BackgroundPreset('Rose', 0xFFEC407A, 0xFFF48FB1),
];

/// A full template: reproduces a layout, not any proprietary asset.
class TemplatePreset {
  const TemplatePreset(this.name, this.build);
  final String name;
  final StoryDocument Function() build;
}

String _id() => DateTime.now().microsecondsSinceEpoch.toString();

final List<TemplatePreset> kTemplatePresets = <TemplatePreset>[
  TemplatePreset('Quote — Gold', () {
    final String id = _id();
    return StoryDocument(
      id: id,
      name: 'Quote Gold',
      backgroundKind: BackgroundKind.gradient,
      gradientStartValue: 0xFF1C1204,
      gradientEndValue: 0xFF120B03,
      layers: <TextLayer>[
        TextLayer(
          id: '${id}a',
          text: 'عنوان اینجا',
          fontFamily: 'Lalezar',
          fontSize: 64,
          colorValue: 0xFFFFD76A,
          dy: 0.32,
        ),
        TextLayer(
          id: '${id}b',
          text: 'متن توضیح این‌جا قرار می‌گیرد و قابل ویرایش است.',
          fontFamily: 'Vazirmatn',
          fontSize: 34,
          dy: 0.52,
        ),
      ],
    );
  }),
  TemplatePreset('Neon Story', () {
    final String id = _id();
    return StoryDocument(
      id: id,
      name: 'Neon Story',
      backgroundKind: BackgroundKind.gradient,
      gradientStartValue: 0xFF12051F,
      gradientEndValue: 0xFF4A1B8C,
      layers: <TextLayer>[
        TextLayer(
          id: '${id}a',
          text: 'FONTO',
          isRTL: false,
          fontFamily: 'Noto Sans Arabic',
          fontSize: 90,
          fontWeightIndex: 8,
          gradientEnabled: true,
          gradientStartValue: 0xFFFF7AE0,
          gradientEndValue: 0xFF7FD0FF,
          dy: 0.4,
        ),
        TextLayer(
          id: '${id}b',
          text: 'داستان شبانه',
          fontFamily: 'Vazirmatn',
          fontSize: 40,
          strokeEnabled: true,
          strokeColorValue: 0xFF000000,
          dy: 0.6,
        ),
      ],
    );
  }),
  TemplatePreset('Clean Caption', () {
    final String id = _id();
    return StoryDocument(
      id: id,
      name: 'Clean Caption',
      backgroundKind: BackgroundKind.solid,
      backgroundColorValue: 0xFF0E1016,
      layers: <TextLayer>[
        TextLayer(
          id: '${id}a',
          text: 'یک جملهٔ کوتاه و خوانا',
          fontFamily: 'Shabnam',
          fontSize: 44,
          boxEnabled: true,
          boxColorValue: 0xCC000000,
          dy: 0.5,
        ),
      ],
    );
  }),
];
