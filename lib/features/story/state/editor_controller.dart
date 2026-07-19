import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/story_document.dart';
import '../models/text_layer.dart';

/// Owns the current story document, the selection, and the undo/redo history.
///
/// History is a stack of full JSON snapshots — simple and correct for a
/// document this size, and it survives any edit (geometry, style, add/remove).
class EditorController extends ChangeNotifier {
  EditorController() {
    _doc = _blankDocument();
    _pushHistory();
  }

  late StoryDocument _doc;
  String? _selectedId;
  final List<String> _undo = <String>[];
  final List<String> _redo = <String>[];

  /// Key on the RepaintBoundary that wraps the export canvas.
  final GlobalKey exportKey = GlobalKey();

  StoryDocument get doc => _doc;
  String? get selectedId => _selectedId;
  bool get canUndo => _undo.length > 1;
  bool get canRedo => _redo.isNotEmpty;

  TextLayer? get selected {
    if (_selectedId == null) return null;
    for (final TextLayer l in _doc.layers) {
      if (l.id == _selectedId) return l;
    }
    return null;
  }

  StoryDocument _blankDocument() => StoryDocument(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        layers: <TextLayer>[],
      );

  String _newId() => DateTime.now().microsecondsSinceEpoch.toString();

  // ---- history --------------------------------------------------------------

  void _pushHistory() {
    _undo.add(jsonEncode(_doc.toJson()));
    if (_undo.length > 80) _undo.removeAt(0);
    _redo.clear();
  }

  /// Call after any mutation that should be undoable.
  void _commit() {
    _doc.updatedAt = DateTime.now();
    _pushHistory();
    notifyListeners();
  }

  void undo() {
    if (!canUndo) return;
    _redo.add(_undo.removeLast());
    _doc = StoryDocument.fromJson(jsonDecode(_undo.last) as Map<String, dynamic>);
    _clampSelection();
    notifyListeners();
  }

  void redo() {
    if (_redo.isEmpty) return;
    final String snap = _redo.removeLast();
    _undo.add(snap);
    _doc = StoryDocument.fromJson(jsonDecode(snap) as Map<String, dynamic>);
    _clampSelection();
    notifyListeners();
  }

  void _clampSelection() {
    if (_selectedId != null && !_doc.layers.any((TextLayer l) => l.id == _selectedId)) {
      _selectedId = null;
    }
  }

  // ---- document ops ---------------------------------------------------------

  void newDocument() {
    _doc = _blankDocument();
    _selectedId = null;
    _undo.clear();
    _redo.clear();
    _pushHistory();
    notifyListeners();
  }

  void setCanvasSize(CanvasSize s) {
    _doc.size = s;
    _commit();
  }

  void setBackground({
    BackgroundKind? kind,
    int? colorValue,
    int? gradientStart,
    int? gradientEnd,
  }) {
    if (kind != null) _doc.backgroundKind = kind;
    if (colorValue != null) _doc.backgroundColorValue = colorValue;
    if (gradientStart != null) _doc.gradientStartValue = gradientStart;
    if (gradientEnd != null) _doc.gradientEndValue = gradientEnd;
    _commit();
  }

  void addTextLayer({String? text, bool rtl = true}) {
    final TextLayer layer = TextLayer(
      id: _newId(),
      text: text ?? (rtl ? 'متن جدید' : 'New text'),
      isRTL: rtl,
      dy: 0.35 + _doc.layers.length * 0.08,
    );
    _doc.layers.add(layer);
    _selectedId = layer.id;
    _commit();
  }

  void select(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  void deleteSelected() {
    if (_selectedId == null) return;
    _doc.layers.removeWhere((TextLayer l) => l.id == _selectedId);
    _selectedId = null;
    _commit();
  }

  void bringToFront() {
    final TextLayer? l = selected;
    if (l == null) return;
    _doc.layers.remove(l);
    _doc.layers.add(l);
    _commit();
  }

  /// Live drag/rotate/scale: mutate without a history entry, then [commitGesture].
  void dragSelected(double ddx, double ddy) {
    final TextLayer? l = selected;
    if (l == null) return;
    l.dx = (l.dx + ddx).clamp(0.0, 1.0);
    l.dy = (l.dy + ddy).clamp(0.0, 1.0);
    notifyListeners();
  }

  void transformSelected({double? rotation, double? scale}) {
    final TextLayer? l = selected;
    if (l == null) return;
    if (rotation != null) l.rotation = rotation;
    if (scale != null) l.scale = scale.clamp(0.2, 6.0);
    notifyListeners();
  }

  void commitGesture() => _commit();

  /// Style edits from the inspector — each is its own undo step.
  void editSelected(void Function(TextLayer l) change) {
    final TextLayer? l = selected;
    if (l == null) return;
    change(l);
    _commit();
  }

  // ---- drafts ---------------------------------------------------------------

  Future<void> saveDraft() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> drafts = prefs.getStringList('drafts') ?? <String>[];
    final String encoded = jsonEncode(_doc.toJson());
    // replace an existing draft with the same id, else append
    final int idx = drafts.indexWhere((String s) {
      final Map<String, dynamic> m = jsonDecode(s) as Map<String, dynamic>;
      return m['id'] == _doc.id;
    });
    if (idx >= 0) {
      drafts[idx] = encoded;
    } else {
      drafts.add(encoded);
    }
    await prefs.setStringList('drafts', drafts);
  }

  Future<List<StoryDocument>> loadDrafts() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> drafts = prefs.getStringList('drafts') ?? <String>[];
    return drafts
        .map((String s) => StoryDocument.fromJson(jsonDecode(s) as Map<String, dynamic>))
        .toList()
      ..sort((StoryDocument a, StoryDocument b) => b.updatedAt.compareTo(a.updatedAt));
  }

  Future<void> deleteDraft(String id) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> drafts = prefs.getStringList('drafts') ?? <String>[];
    drafts.removeWhere((String s) {
      final Map<String, dynamic> m = jsonDecode(s) as Map<String, dynamic>;
      return m['id'] == id;
    });
    await prefs.setStringList('drafts', drafts);
  }

  void openDocument(StoryDocument d) {
    _doc = d.copy();
    _selectedId = null;
    _undo.clear();
    _redo.clear();
    _pushHistory();
    notifyListeners();
  }

  // ---- export ---------------------------------------------------------------

  /// Renders the canvas to PNG bytes at full document resolution.
  Future<Uint8List?> renderPng() async {
    final RenderRepaintBoundary? boundary =
        exportKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final Size shown = boundary.size;
    final double pixelRatio = _doc.size.pixels.width / shown.width;
    final ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
    final ByteData? data = await image.toByteData(format: ui.ImageByteFormat.png);
    return data?.buffer.asUint8List();
  }

  Future<File?> exportToFile() async {
    final Uint8List? bytes = await renderPng();
    if (bytes == null) return null;
    final Directory dir = await getTemporaryDirectory();
    final String safe = _doc.name.replaceAll(RegExp(r'\s+'), '_');
    final File f = File('${dir.path}/${safe}_${_doc.size.pixels.width.toInt()}.png');
    await f.writeAsBytes(bytes);
    return f;
  }

  Future<void> shareExport() async {
    final File? f = await exportToFile();
    if (f == null) return;
    await Share.shareXFiles(<XFile>[XFile(f.path)], text: _doc.name);
  }
}
