import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/fonts/font_catalog.dart';
import '../../core/settings_controller.dart';
import '../../core/strings.dart';
import '../../shared/controls.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController settings = context.watch<SettingsController>();
    final FontCatalog catalog = context.watch<FontCatalog>();
    final S s = S.of(context);

    return ListView(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(s.language),
          trailing: SegmentedButton<String>(
            segments: const <ButtonSegment<String>>[
              ButtonSegment<String>(value: 'fa', label: Text('فارسی')),
              ButtonSegment<String>(value: 'en', label: Text('English')),
            ],
            selected: <String>{settings.locale.languageCode},
            onSelectionChanged: (Set<String> v) => settings.setLocale(Locale(v.first)),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.brightness_6),
          title: Text(s.theme),
          trailing: SegmentedButton<ThemeMode>(
            segments: <ButtonSegment<ThemeMode>>[
              ButtonSegment<ThemeMode>(value: ThemeMode.light, label: Text(s.light)),
              ButtonSegment<ThemeMode>(value: ThemeMode.dark, label: Text(s.dark)),
              ButtonSegment<ThemeMode>(value: ThemeMode.system, label: Text(s.system)),
            ],
            selected: <ThemeMode>{settings.themeMode},
            onSelectionChanged: (Set<ThemeMode> v) => settings.setThemeMode(v.first),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: ColorRow(
            label: s.workspaceColor,
            value: settings.workspaceColorValue,
            onChanged: settings.setWorkspaceColor,
          ),
        ),
        const Divider(),
        ListTile(
          leading: const Icon(Icons.font_download),
          title: Text(s.manageFonts),
          subtitle: Text('${catalog.all.length} ${s.font}'),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: FilledButton.icon(
            icon: const Icon(Icons.upload_file),
            label: Text(s.importFont),
            onPressed: () => _importFont(context, catalog, s),
          ),
        ),
        for (final FontEntry f in catalog.imported)
          ListTile(
            title: Text(f.family, style: TextStyle(fontFamily: f.family)),
            subtitle: const Text('Imported'),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => catalog.removeImported(f.family),
            ),
          ),
        const Divider(),
        AboutListTile(
          icon: const Icon(Icons.info_outline),
          applicationName: s.appTitle,
          applicationVersion: '0.1.0',
          aboutBoxChildren: <Widget>[
            Text(s.get(
              'ساخته‌شده با Flutter. فونت‌های همراه با مجوز OFL هستند؛ فونت‌های تجاری را خودتان وارد کنید.',
              'Built with Flutter. Bundled fonts are OFL-licensed; import commercial fonts yourself.',
            )),
          ],
        ),
      ],
    );
  }

  Future<void> _importFont(BuildContext context, FontCatalog catalog, S s) async {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: <String>['ttf', 'otf'],
    );
    if (result == null || result.files.single.path == null) return;
    final PlatformFile file = result.files.single;
    try {
      final FontEntry entry = await catalog.importFont(file.path!, file.name);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${s.importFont}: ${entry.family}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    }
  }
}
