import 'package:flutter/widgets.dart';

/// Tiny hand-rolled localisation (fa/en) — no code-gen, fully offline.
class S {
  const S(this.isFa);
  final bool isFa;

  static S of(BuildContext context) {
    final Locale l = Localizations.localeOf(context);
    return S(l.languageCode == 'fa');
  }

  String get(String fa, String en) => isFa ? fa : en;

  String get appTitle => get('فونتو استودیو', 'Fonto Studio');
  String get tabStory => get('استوری', 'Story');
  String get tabGallery => get('گالری', 'Gallery');
  String get tabSettings => get('تنظیمات', 'Settings');

  String get addText => get('افزودن متن', 'Add text');
  String get addRtl => get('متن فارسی', 'Persian text');
  String get addLtr => get('متن انگلیسی', 'English text');
  String get undo => get('واگرد', 'Undo');
  String get redo => get('ازنو', 'Redo');
  String get delete => get('حذف', 'Delete');
  String get export => get('خروجی', 'Export');
  String get exportPng => get('خروجی PNG شفاف', 'Transparent PNG');
  String get saveDraft => get('ذخیره پیش‌نویس', 'Save draft');
  String get drafts => get('پیش‌نویس‌ها', 'Drafts');
  String get newDoc => get('سند جدید', 'New');
  String get bringFront => get('انتقال به جلو', 'Bring to front');

  String get text => get('متن', 'Text');
  String get font => get('فونت', 'Font');
  String get size => get('اندازه', 'Size');
  String get color => get('رنگ', 'Color');
  String get weight => get('ضخامت', 'Weight');
  String get letterSpacing => get('فاصله حروف', 'Letter spacing');
  String get lineHeight => get('فاصله خطوط', 'Line height');
  String get align => get('چینش', 'Align');
  String get direction => get('جهت', 'Direction');
  String get opacity => get('شفافیت', 'Opacity');
  String get rotation => get('چرخش', 'Rotation');
  String get scale => get('مقیاس', 'Scale');
  String get shadow => get('سایه', 'Shadow');
  String get stroke => get('دور خط', 'Stroke');
  String get gradient => get('گرادیانت', 'Gradient');
  String get box => get('کادر', 'Box');
  String get blur => get('محو', 'Blur');
  String get width => get('پهنا', 'Width');
  String get radius => get('گردی', 'Radius');
  String get padding => get('حاشیه', 'Padding');

  String get background => get('پس‌زمینه', 'Background');
  String get transparent => get('شفاف', 'Transparent');
  String get solid => get('یکرنگ', 'Solid');
  String get canvas => get('اندازه بوم', 'Canvas size');

  String get language => get('زبان', 'Language');
  String get theme => get('پوسته', 'Theme');
  String get light => get('روشن', 'Light');
  String get dark => get('تاریک', 'Dark');
  String get system => get('سیستم', 'System');
  String get workspaceColor => get('رنگ محیط کار', 'Workspace color');
  String get manageFonts => get('مدیریت فونت‌ها', 'Manage fonts');
  String get importFont => get('وارد کردن فونت TTF/OTF', 'Import TTF/OTF font');
  String get about => get('درباره', 'About');

  String get search => get('جستجو', 'Search');
  String get favorites => get('علاقه‌مندی‌ها', 'Favorites');
  String get recent => get('اخیر', 'Recent');
  String get all => get('همه', 'All');
  String get templates => get('قالب‌ها', 'Templates');
  String get backgrounds => get('پس‌زمینه‌ها', 'Backgrounds');
  String get useTemplate => get('استفاده', 'Use');
  String get exported => get('خروجی آماده شد', 'Export ready');
  String get noDrafts => get('پیش‌نویسی نیست', 'No drafts yet');
  String get nothingSelected => get('یک لایه انتخاب کن', 'Select a layer');
}
