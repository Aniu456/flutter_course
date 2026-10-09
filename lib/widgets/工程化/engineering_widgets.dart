import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../app/app_settings.dart';
import '../../l10n/app_localizations.dart';

// 工程化：国际化（gen-l10n）、深色模式、MethodChannel 原生通信、工程化清单。

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

Widget _code(BuildContext context, String text) {
  return Container(
    width: double.infinity,
    margin: const EdgeInsets.symmetric(horizontal: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
    ),
    child: SelectableText(text, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
  );
}

/// ===================== 国际化（flutter_localizations + gen-l10n） =====================
///
/// 【是什么】
/// 官方国际化方案：把文案写在 ARB（JSON）文件里，`flutter pub get` / `flutter run`
/// 时自动生成类型安全的 AppLocalizations 类，在代码里用 AppLocalizations.of(context).xxx 取文案。
///
/// 【配置步骤（本项目已配置好）】
/// 1. pubspec.yaml：
///      dependencies: flutter_localizations(sdk: flutter)、intl
///      flutter: generate: true
/// 2. 根目录 l10n.yaml：arb-dir、template-arb-file、output-localization-file
/// 3. lib/l10n/app_zh.arb（模板）、app_en.arb：写文案
/// 4. MaterialApp：
///      localizationsDelegates: AppLocalizations.localizationsDelegates,
///      supportedLocales: AppLocalizations.supportedLocales,
///      locale: 当前语言（null = 跟随系统）
/// 5. iOS 需在 Info.plist 的 CFBundleLocalizations 中声明支持的语言
///
/// 【ARB 进阶写法】
/// - 占位符："hello": "你好，{name}！"
/// - 复数："{count, plural, =0{空} other{{count} 件}}"
/// - 日期 / 货币格式：placeholders 里指定 type 与 format（yMMMMEEEEd、simpleCurrency）
///
/// 【注意】
/// - 修改 ARB 后重新运行 flutter pub get（或 flutter gen-l10n）生成代码
/// - 只在 Widget 内部（有 context）取文案；没有 context 的地方把文案作为参数传入
/// - Localizations.override 可以让局部子树使用另一种语言（本例的预览区就是这么做的）
class I18nDemo extends StatefulWidget {
  const I18nDemo({super.key});

  @override
  State<I18nDemo> createState() => _I18nDemoState();
}

class _I18nDemoState extends State<I18nDemo> {
  String _preview = 'zh';
  int _cart = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. 局部预览（Localizations.override）'),
        Center(
          child: SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'zh', label: Text('简体中文')),
              ButtonSegment(value: 'en', label: Text('English')),
            ],
            selected: {_preview},
            onSelectionChanged: (s) => setState(() => _preview = s.first),
          ),
        ),
        const SizedBox(height: 8),
        Localizations.override(
          context: context,
          locale: Locale(_preview),
          delegates: AppLocalizations.localizationsDelegates,
          // 用 Builder 拿到"被覆盖语言"之后的 context
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.appTitle, style: Theme.of(context).textTheme.titleLarge),
                      const Divider(),
                      Text('占位符：${l10n.hello('Flutter')}'),
                      Text('复数：${l10n.cartItems(_cart)}'),
                      Text('日期：${l10n.today(DateTime.now())}'),
                      Text('货币：${l10n.price(1234.5)}'),
                      Text(
                        'Material 自带文案：${MaterialLocalizations.of(context).okButtonLabel} / '
                        '${MaterialLocalizations.of(context).cancelButtonLabel}',
                      ),
                      Row(
                        children: [
                          const Text('购物车数量：'),
                          IconButton(
                            onPressed: _cart > 0 ? () => setState(() => _cart--) : null,
                            icon: const Icon(Icons.remove),
                          ),
                          Text('$_cart'),
                          IconButton(onPressed: () => setState(() => _cart++), icon: const Icon(Icons.add)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        _title('2. 切换整个 App 的语言（首页标题、日期选择器等都会变化）'),
        ListenableBuilder(
          listenable: appSettings,
          builder: (context, _) => Center(
            child: SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'system', label: Text('跟随系统')),
                ButtonSegment(value: 'zh', label: Text('中文')),
                ButtonSegment(value: 'en', label: Text('English')),
              ],
              selected: {appSettings.locale?.languageCode ?? 'system'},
              onSelectionChanged: (s) => appSettings.locale = s.first == 'system' ? null : Locale(s.first),
            ),
          ),
        ),
        _title('3. ARB 文件示例（lib/l10n/app_zh.arb）'),
        _code(
          context,
          '{\n'
          '  "@@locale": "zh",\n'
          '  "hello": "你好，{name}！",\n'
          '  "@hello": {\n'
          '    "placeholders": { "name": { "type": "String" } }\n'
          '  },\n'
          '  "cartItems": "{count, plural, =0{购物车是空的} other{购物车里有 {count} 件商品}}"\n'
          '}\n\n'
          '// 使用\n'
          'Text(AppLocalizations.of(context).hello(\'Flutter\'))',
        ),
      ],
    );
  }
}

/// ===================== 深色模式 / 主题切换 =====================
///
/// 【是什么】
/// MaterialApp 同时提供 theme（浅色）与 darkTheme（深色），
/// 再用 themeMode 决定使用哪一个：
/// - ThemeMode.system：跟随系统设置（默认）
/// - ThemeMode.light / ThemeMode.dark：强制浅色 / 深色
///
/// 【本项目的做法】
/// lib/app/app_settings.dart 中的 AppSettings（ChangeNotifier）保存 themeMode，
/// MyApp 用 ListenableBuilder 监听它；修改 appSettings.themeMode 即可全局切换。
/// 首页右上角的按钮也能切换。
///
/// 【注意】
/// - 颜色不要写死 Colors.white / Colors.black，用 Theme.of(context).colorScheme.xxx，
///   深浅模式会自动适配
/// - ColorScheme.fromSeed / colorSchemeSeed 会根据种子色生成完整的 M3 配色
/// - 想记住用户的选择，可用 shared_preferences 持久化 themeMode（见「本地存储」）
/// - 判断当前是否深色：Theme.of(context).brightness == Brightness.dark
class ThemeModeDemo extends StatelessWidget {
  const ThemeModeDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final colors = <(String, Color, Color)>[
      ('primary', scheme.primary, scheme.onPrimary),
      ('primaryContainer', scheme.primaryContainer, scheme.onPrimaryContainer),
      ('secondary', scheme.secondary, scheme.onSecondary),
      ('tertiary', scheme.tertiary, scheme.onTertiary),
      ('surface', scheme.surface, scheme.onSurface),
      ('surfaceContainerHighest', scheme.surfaceContainerHighest, scheme.onSurface),
      ('error', scheme.error, scheme.onError),
    ];
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        _title('1. 切换 ThemeMode（全局生效）'),
        ListenableBuilder(
          listenable: appSettings,
          builder: (context, _) => Center(
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('跟随系统'), icon: Icon(Icons.brightness_auto)),
                ButtonSegment(value: ThemeMode.light, label: Text('浅色'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('深色'), icon: Icon(Icons.dark_mode)),
              ],
              selected: {appSettings.themeMode},
              onSelectionChanged: (s) => appSettings.themeMode = s.first,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            '当前亮度：${Theme.of(context).brightness == Brightness.dark ? '深色 🌙' : '浅色 ☀️'}',
            textAlign: TextAlign.center,
          ),
        ),
        _title('2. 当前 ColorScheme（颜色会随模式自动变化）'),
        for (final (name, bg, fg) in colors)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
            child: Text(name, style: TextStyle(color: fg)),
          ),
        _title('3. MaterialApp 配置'),
        _code(
          context,
          'MaterialApp(\n'
          '  theme: ThemeData(colorSchemeSeed: Colors.blue),\n'
          '  darkTheme: ThemeData(\n'
          '    colorSchemeSeed: Colors.blue,\n'
          '    brightness: Brightness.dark,\n'
          '  ),\n'
          '  themeMode: appSettings.themeMode,\n'
          ')',
        ),
      ],
    );
  }
}

/// 与原生通信的通道封装。
///
/// 通道名在 Dart 与原生两端必须完全一致；
/// 原生实现见 android/.../MainActivity.kt 与 ios/Runner/AppDelegate.swift。
class DeviceChannel {
  static const MethodChannel _channel = MethodChannel('flutter_course/device');

  /// 获取电量百分比（0~100）。
  static Future<int> getBatteryLevel() async {
    final level = await _channel.invokeMethod<int>('getBatteryLevel');
    return level ?? -1;
  }

  /// 获取系统信息：{'os': ..., 'version': ..., 'model': ...}
  static Future<Map<String, String>> getDeviceInfo() async {
    final info = await _channel.invokeMapMethod<String, String>('getDeviceInfo');
    return info ?? const {};
  }
}

/// ===================== MethodChannel 平台通道 =====================
///
/// 【是什么】
/// Flutter 与原生（Android Kotlin / iOS Swift）之间"方法调用"式的通信：
/// Dart 端 invokeMethod('方法名', 参数) → 原生端处理 → 返回结果（或错误）。
///
/// 【三种通道】
/// - MethodChannel：一次调用一次返回（最常用）
/// - EventChannel：原生持续向 Dart 推送事件流（传感器、定位、电量变化）
/// - BasicMessageChannel：双向收发任意消息
///
/// 【错误处理】
/// - MissingPluginException：当前平台没有实现这个通道（Web、桌面、单元测试中）
/// - PlatformException：原生端返回了错误（result.error / FlutterError），如模拟器无电池
///
/// 【注意】
/// - 通道名、方法名两端必须一致，建议加上包名前缀避免冲突
/// - 参数和返回值只能是标准类型：null、bool、num、String、List、Map、Uint8List
/// - 原生代码修改后需要重新编译运行，热重载不生效
/// - 可复用的原生能力建议做成插件（flutter create --template=plugin），或使用 pigeon 生成类型安全代码
class MethodChannelDemo extends StatefulWidget {
  const MethodChannelDemo({super.key});

  @override
  State<MethodChannelDemo> createState() => _MethodChannelDemoState();
}

class _MethodChannelDemoState extends State<MethodChannelDemo> {
  String _battery = '点击按钮获取';
  String _device = '点击按钮获取';

  Future<void> _call(Future<String> Function() task, void Function(String) assign) async {
    String text;
    try {
      text = await task();
    } on MissingPluginException {
      text = '当前平台没有实现该通道（MissingPluginException）。\n请在 Android / iOS 真机或模拟器上运行。';
    } on PlatformException catch (e) {
      text = '原生端返回错误：${e.code} ${e.message ?? ''}';
    }
    if (mounted) setState(() => assign(text));
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        ListTile(
          leading: const Icon(Icons.battery_std),
          title: const Text('getBatteryLevel'),
          subtitle: Text(_battery),
          trailing: FilledButton.tonal(
            onPressed: () => _call(() async => '电量：${await DeviceChannel.getBatteryLevel()}%', (t) => _battery = t),
            child: const Text('调用'),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.phone_iphone),
          title: const Text('getDeviceInfo'),
          subtitle: Text(_device),
          trailing: FilledButton.tonal(
            onPressed: () => _call(() async {
              final info = await DeviceChannel.getDeviceInfo();
              return info.entries.map((e) => '${e.key}: ${e.value}').join('\n');
            }, (t) => _device = t),
            child: const Text('调用'),
          ),
        ),
        _title('Dart 端'),
        _code(
          context,
          "const channel = MethodChannel('flutter_course/device');\n"
          "final level = await channel.invokeMethod<int>('getBatteryLevel');",
        ),
        _title('Android 端（MainActivity.kt）'),
        _code(
          context,
          'override fun configureFlutterEngine(engine: FlutterEngine) {\n'
          '  super.configureFlutterEngine(engine)\n'
          '  MethodChannel(engine.dartExecutor.binaryMessenger, "flutter_course/device")\n'
          '    .setMethodCallHandler { call, result ->\n'
          '      when (call.method) {\n'
          '        "getBatteryLevel" -> result.success(batteryLevel())\n'
          '        else -> result.notImplemented()\n'
          '      }\n'
          '    }\n'
          '}',
        ),
        _title('iOS 端（AppDelegate.swift）'),
        _code(
          context,
          'let channel = FlutterMethodChannel(\n'
          '  name: "flutter_course/device", binaryMessenger: messenger)\n'
          'channel.setMethodCallHandler { call, result in\n'
          '  switch call.method {\n'
          '  case "getBatteryLevel": result(Int(UIDevice.current.batteryLevel * 100))\n'
          '  default: result(FlutterMethodNotImplemented)\n'
          '  }\n'
          '}',
        ),
      ],
    );
  }
}

/// ===================== 工程化清单 =====================
///
/// 一个可以发布、可以多人协作的 Flutter 项目，除了业务代码还需要这些"基础设施"。
/// 本项目中每一项都已经配置好，可以直接对照源码学习。
class EngineeringChecklistDemo extends StatelessWidget {
  const EngineeringChecklistDemo({super.key});

  static const _items = [
    (Icons.rule, '静态检查', 'analysis_options.yaml 引入 flutter_lints；运行 flutter analyze'),
    (Icons.format_align_left, '代码格式化', 'dart format .；页宽在 analysis_options.yaml 的 formatter.page_width 中配置'),
    (Icons.science_outlined, '自动化测试', 'test/widget_test.dart 逐个构建所有示例；网络与插件在测试中被 Mock'),
    (Icons.cloud_sync_outlined, '持续集成 CI', '.github/workflows/flutter.yml：每次 push / PR 自动 analyze + test'),
    (Icons.apps, 'App 图标', 'flutter_launcher_icons：assets/icon/app_icon.png → dart run flutter_launcher_icons'),
    (Icons.flash_on_outlined, '启动页', 'flutter_native_splash：dart run flutter_native_splash:create'),
    (Icons.translate, '国际化', 'l10n.yaml + lib/l10n/*.arb，gen-l10n 自动生成 AppLocalizations'),
    (Icons.dark_mode_outlined, '深色模式', 'MaterialApp 的 theme / darkTheme / themeMode'),
    (Icons.settings_input_component, '原生通信', 'MethodChannel，Android 与 iOS 两端各实现一份'),
    (Icons.tag, '版本号', 'pubspec.yaml 的 version: 1.0.0+1（版本名+构建号），或 --build-name / --build-number'),
    (Icons.call_split, '多环境 Flavor', '--flavor + --dart-define 区分开发 / 测试 / 生产环境'),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final (icon, title, desc) in _items)
          Card(
            child: ListTile(leading: Icon(icon), title: Text(title), subtitle: Text(desc)),
          ),
      ],
    );
  }
}
