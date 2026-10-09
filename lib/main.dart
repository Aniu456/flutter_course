import 'package:flutter/material.dart';
import 'package:flutter_course/app/app_settings.dart';
import 'package:flutter_course/l10n/app_localizations.dart';
import 'package:flutter_course/widgets/catalog.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 监听全局设置：主题模式或语言变化时重建 MaterialApp
    return ListenableBuilder(
      listenable: appSettings,
      builder: (context, _) {
        return MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
          theme: ThemeData(colorSchemeSeed: Colors.blue),
          darkTheme: ThemeData(colorSchemeSeed: Colors.blue, brightness: Brightness.dark),
          themeMode: appSettings.themeMode,
          // 国际化：locale 为 null 时跟随系统，系统语言不受支持时回退到第一个（中文）
          locale: appSettings.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const CatalogPage(),
        );
      },
    );
  }
}

/// 首页：按分类列出所有示例，点击进入对应的 Demo 页面。
class CatalogPage extends StatelessWidget {
  const CatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogTitle), actions: const [_LanguageMenu(), _ThemeMenu()]),
      body: ListView(
        children: [
          for (final category in catalog)
            ExpansionTile(
              leading: Icon(category.icon),
              title: Text(category.name),
              subtitle: Text(l10n.demoCount(category.entries.length)),
              children: [
                for (final entry in category.entries)
                  ListTile(
                    title: Text(entry.title),
                    subtitle: Text(entry.summary),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => DemoPage(entry: entry))),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}

/// 右上角：切换浅色 / 深色 / 跟随系统。
class _ThemeMenu extends StatelessWidget {
  const _ThemeMenu();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final icon = switch (appSettings.themeMode) {
      ThemeMode.light => Icons.light_mode,
      ThemeMode.dark => Icons.dark_mode,
      ThemeMode.system => Icons.brightness_auto,
    };
    return PopupMenuButton<ThemeMode>(
      icon: Icon(icon),
      tooltip: l10n.themeMode,
      initialValue: appSettings.themeMode,
      onSelected: (mode) => appSettings.themeMode = mode,
      itemBuilder: (_) => [
        PopupMenuItem(value: ThemeMode.system, child: Text(l10n.themeSystem)),
        PopupMenuItem(value: ThemeMode.light, child: Text(l10n.themeLight)),
        PopupMenuItem(value: ThemeMode.dark, child: Text(l10n.themeDark)),
      ],
    );
  }
}

/// 右上角：切换语言（跟随系统 / 中文 / English）。
class _LanguageMenu extends StatelessWidget {
  const _LanguageMenu();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<String>(
      icon: const Icon(Icons.translate),
      tooltip: l10n.language,
      initialValue: appSettings.locale?.languageCode ?? 'system',
      onSelected: (code) => appSettings.locale = code == 'system' ? null : Locale(code),
      itemBuilder: (_) => [
        PopupMenuItem(value: 'system', child: Text(l10n.languageSystem)),
        const PopupMenuItem(value: 'zh', child: Text('简体中文')),
        const PopupMenuItem(value: 'en', child: Text('English')),
      ],
    );
  }
}

class DemoPage extends StatelessWidget {
  const DemoPage({super.key, required this.entry});

  final CatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry.title)),
      body: SafeArea(child: entry.builder(context)),
    );
  }
}
