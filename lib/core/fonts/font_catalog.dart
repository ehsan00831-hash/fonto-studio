import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// One font available to the editor — either bundled (OFL) or user-imported.
class FontEntry {
  const FontEntry({
    required this.family,
    required this.category,
    this.bundled = true,
    this.filePath,
  });

  final String family;
  final String category; // 'Sans', 'Display', 'Naskh', 'Imported'
  final bool bundled;
  final String? filePath; // for imported fonts

  Map<String, dynamic> toJson() => <String, dynamic>{
        'family': family,
        'category': category,
        'filePath': filePath,
      };

  factory FontEntry.imported(Map<String, dynamic> j) => FontEntry(
        family: j['family'] as String,
        category: 'Imported',
        bundled: false,
        filePath: j['filePath'] as String?,
      );
}

/// The bundled OFL font families, declared in pubspec.yaml.
const List<FontEntry> kBundledFonts = <FontEntry>[
  FontEntry(family: 'Vazirmatn', category: 'Sans'),
  FontEntry(family: 'Shabnam', category: 'Sans'),
  FontEntry(family: 'Sahel', category: 'Sans'),
  FontEntry(family: 'Samim', category: 'Sans'),
  FontEntry(family: 'Lalezar', category: 'Display'),
  FontEntry(family: 'Noto Sans Arabic', category: 'Sans'),
  FontEntry(family: 'Noto Naskh Arabic', category: 'Naskh'),
];

/// Holds the merged list of bundled + imported fonts and handles importing
/// a TTF/OTF at runtime (so users can bring their own licensed families).
class FontCatalog extends ChangeNotifier {
  final List<FontEntry> _imported = <FontEntry>[];
  final Set<String> _favorites = <String>{};
  final List<String> _recent = <String>[];

  List<FontEntry> get all => <FontEntry>[...kBundledFonts, ..._imported];
  List<FontEntry> get imported => List<FontEntry>.unmodifiable(_imported);
  Set<String> get favorites => _favorites;
  List<String> get recent => List<String>.unmodifiable(_recent);

  List<String> get categories {
    final Set<String> c = <String>{for (final FontEntry f in all) f.category};
    return c.toList()..sort();
  }

  List<FontEntry> search(String query, {String? category, bool favoritesOnly = false}) {
    final String q = query.trim().toLowerCase();
    return all.where((FontEntry f) {
      if (category != null && f.category != category) return false;
      if (favoritesOnly && !_favorites.contains(f.family)) return false;
      if (q.isEmpty) return true;
      return f.family.toLowerCase().contains(q);
    }).toList();
  }

  bool isFavorite(String family) => _favorites.contains(family);

  void toggleFavorite(String family) {
    if (!_favorites.remove(family)) _favorites.add(family);
    _persist();
    notifyListeners();
  }

  void markUsed(String family) {
    _recent.remove(family);
    _recent.insert(0, family);
    if (_recent.length > 12) _recent.removeLast();
    _persist();
    notifyListeners();
  }

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _favorites
      ..clear()
      ..addAll(prefs.getStringList('font_favorites') ?? const <String>[]);
    _recent
      ..clear()
      ..addAll(prefs.getStringList('font_recent') ?? const <String>[]);
    final List<String> raw = prefs.getStringList('font_imported') ?? const <String>[];
    _imported.clear();
    for (final String s in raw) {
      final FontEntry e = FontEntry.imported(jsonDecode(s) as Map<String, dynamic>);
      if (e.filePath != null && File(e.filePath!).existsSync()) {
        await _register(e);
      }
    }
    notifyListeners();
  }

  Future<void> _persist() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('font_favorites', _favorites.toList());
    await prefs.setStringList('font_recent', _recent);
    await prefs.setStringList(
      'font_imported',
      _imported.map((FontEntry e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> _register(FontEntry e) async {
    final File f = File(e.filePath!);
    final FontLoader loader = FontLoader(e.family)
      ..addFont(Future<ByteData>.value(ByteData.view(f.readAsBytesSync().buffer)));
    await loader.load();
  }

  /// Copies the picked font file into app storage, registers it, and persists.
  Future<FontEntry> importFont(String sourcePath, String rawName) async {
    final Directory dir = await getApplicationSupportDirectory();
    final Directory fontsDir = Directory('${dir.path}/imported_fonts')..createSync(recursive: true);
    final String family = _familyFromName(rawName);
    final String ext = sourcePath.toLowerCase().endsWith('.otf') ? 'otf' : 'ttf';
    final String dest = '${fontsDir.path}/$family.$ext';
    File(sourcePath).copySync(dest);

    final FontEntry entry = FontEntry(
      family: family,
      category: 'Imported',
      bundled: false,
      filePath: dest,
    );
    await _register(entry);
    _imported.removeWhere((FontEntry e) => e.family == family);
    _imported.add(entry);
    await _persist();
    notifyListeners();
    return entry;
  }

  Future<void> removeImported(String family) async {
    final int idx = _imported.indexWhere((FontEntry e) => e.family == family);
    if (idx == -1) return;
    final String? p = _imported[idx].filePath;
    if (p != null) {
      final File f = File(p);
      if (f.existsSync()) f.deleteSync();
    }
    _imported.removeAt(idx);
    _favorites.remove(family);
    await _persist();
    notifyListeners();
  }

  String _familyFromName(String rawName) {
    String base = rawName.split('/').last.split('\\').last;
    base = base.replaceAll(RegExp(r'\.(ttf|otf|TTF|OTF)$'), '');
    base = base.replaceAll(RegExp(r'[_\-]+'), ' ').trim();
    return base.isEmpty ? 'Imported Font' : base;
  }
}
