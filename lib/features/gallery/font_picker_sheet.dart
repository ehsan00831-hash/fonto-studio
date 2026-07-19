import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/fonts/font_catalog.dart';
import '../../core/strings.dart';

/// A bottom-sheet font library: search, categories, favorites, recent, and a
/// live preview of every family. Returns the chosen family name.
Future<String?> showFontPicker(BuildContext context, {String? current}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    builder: (BuildContext ctx) => FractionallySizedBox(
      heightFactor: 0.85,
      child: _FontPicker(current: current),
    ),
  );
}

class _FontPicker extends StatefulWidget {
  const _FontPicker({this.current});
  final String? current;

  @override
  State<_FontPicker> createState() => _FontPickerState();
}

class _FontPickerState extends State<_FontPicker> {
  String _query = '';
  String? _category;
  bool _favoritesOnly = false;
  final String _sample = 'نمونهٔ متن فارسی ۱۲۳ Aa';

  @override
  Widget build(BuildContext context) {
    final FontCatalog catalog = context.watch<FontCatalog>();
    final S s = S.of(context);
    final List<FontEntry> results =
        catalog.search(_query, category: _category, favoritesOnly: _favoritesOnly);

    return Column(
      children: <Widget>[
        const SizedBox(height: 8),
        Container(width: 40, height: 4, color: Colors.white24),
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            autofocus: false,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              hintText: s.search,
              border: const OutlineInputBorder(),
            ),
            onChanged: (String v) => setState(() => _query = v),
          ),
        ),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: <Widget>[
              _chip(s.all, _category == null && !_favoritesOnly, () {
                setState(() {
                  _category = null;
                  _favoritesOnly = false;
                });
              }),
              _chip('★ ${s.favorites}', _favoritesOnly, () {
                setState(() {
                  _favoritesOnly = true;
                  _category = null;
                });
              }),
              for (final String cat in catalog.categories)
                _chip(cat, _category == cat, () {
                  setState(() {
                    _category = cat;
                    _favoritesOnly = false;
                  });
                }),
            ],
          ),
        ),
        if (catalog.recent.isNotEmpty && _query.isEmpty)
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text('${s.recent}: ${catalog.recent.take(5).join('، ')}',
                  style: Theme.of(context).textTheme.bodySmall),
            ),
          ),
        Expanded(
          child: ListView.builder(
            itemCount: results.length,
            itemBuilder: (BuildContext context, int i) {
              final FontEntry f = results[i];
              final bool fav = catalog.isFavorite(f.family);
              return ListTile(
                selected: f.family == widget.current,
                title: Text(f.family, style: const TextStyle(fontSize: 13)),
                subtitle: Text(
                  _sample,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(fontFamily: f.family, fontSize: 22),
                ),
                trailing: IconButton(
                  icon: Icon(fav ? Icons.star : Icons.star_border,
                      color: fav ? Colors.amber : null),
                  onPressed: () => catalog.toggleFavorite(f.family),
                ),
                onTap: () => Navigator.pop(context, f.family),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _chip(String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }
}
