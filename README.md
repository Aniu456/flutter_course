<p align="center">
  <img src="assets/icon/app_icon.png" width="120" alt="Flutter Course" />
</p>

<h1 align="center">Flutter Course · Flutter 中文组件与实战课程</h1>

<p align="center">
  <a href="LICENSE"><img alt="License: MIT" src="https://img.shields.io/badge/license-MIT-blue.svg"></a>
  <img alt="Flutter 3.47" src="https://img.shields.io/badge/Flutter-3.47-02569B?logo=flutter">
  <img alt="Dart 3.13" src="https://img.shields.io/badge/Dart-3.13-0175C2?logo=dart">
</p>

> **English:** A comprehensive, hands-on Flutter course written in Simplified Chinese.
> It covers **25 chapters and 138 runnable demos** — from layout basics and Material 3 / Cupertino
> widgets to animations, state & lifecycle, routing, networking, local storage, i18n, dark mode and
> platform channels. Every demo is a self-contained page with a detailed Chinese doc comment
> (what it is / properties / pitfalls / use cases). Run the app, browse the catalog, read the source.

面向初学者到进阶开发者的 Flutter 学习项目：**25 个章节、138 个可运行示例**。
每个知识点都是一个可运行的 `XxxDemo` 页面，类上方的中文文档注释依次说明：

- **【是什么】** 组件 / 知识点的作用
- **【属性】** 常用属性、API 及含义
- **【注意】** 常见坑、尺寸规则、替代方案
- **【常见使用场景】** 什么时候用

运行 App → 在首页目录里点开示例看效果 → 打开对应源码读注释，边看边改。

## 截图

> 📷 截图待补充：可以把截图放到 `docs/screenshots/` 目录，然后替换下面的占位。

| 首页目录 | 示例页面 | 深色模式 |
|---|---|---|
| _待补充_ | _待补充_ | _待补充_ |

## 快速开始

```bash
git clone <你的仓库地址>
cd Flutter_course
flutter pub get        # 安装依赖，并根据 lib/l10n/*.arb 生成国际化代码
flutter run            # 运行到模拟器 / 真机
```

- 首页是按分类折叠的目录，点击条目即可打开对应示例
- 首页右上角可以切换 **语言（中文 / English）** 和 **主题（浅色 / 深色 / 跟随系统）**
- 「网络与异步」分类会访问 [jsonplaceholder.typicode.com](https://jsonplaceholder.typicode.com)，需要联网
- 「MethodChannel」示例需要在 Android / iOS 上运行（Web、桌面会显示友好的提示）

环境：Flutter 3.47（stable）/ Dart 3.13。

## 课程大纲

| # | 章节 | 源码 | 示例 |
|---|---|---|---|
| 1 | 基础容器 | `基础容器/container_widgets.dart`、`sizing_widgets.dart` | Container、Padding、Center、Align、SizedBox、ConstrainedBox、DecoratedBox、Card、ClipRRect、Opacity、Transform、AspectRatio、FittedBox、FractionallySizedBox |
| 2 | 线性布局 | `线性布局/linear_widgets.dart`、`table_widgets.dart` | Row、Column、Table |
| 3 | 弹性布局 | `弹性布局/flex_widgets.dart` | Flex、Expanded、Flexible、Spacer |
| 4 | 流式布局 | `流式布局/flow_widgets.dart` | Wrap、Flow |
| 5 | 层叠布局 | `层叠布局/stack_widgets.dart`、`visibility_widgets.dart` | Stack、Positioned、IndexedStack、Visibility / Offstage |
| 6 | 滚动布局 | `滚动布局/scroll_widgets.dart`、`sliver_widgets.dart` | ListView、GridView、SingleChildScrollView、CustomScrollView、PageView、SliverAppBar、ReorderableListView |
| 7 | 基础展示 | `基础展示/display_widgets.dart` | Text、Icon、Image、RichText、Divider、CircleAvatar、Chip |
| 8 | 按钮 | `按钮/button_widgets.dart` | ElevatedButton、TextButton、OutlinedButton、IconButton、FloatingActionButton |
| 9 | 输入与表单 | `输入与表单/input_widgets.dart`、`picker_widgets.dart` | TextField、Form、Checkbox、Radio、Switch、Slider、DropdownButton、日期 / 时间选择器 |
| 10 | 导航 | `导航/navigation_widgets.dart` | Scaffold、AppBar、BottomNavigationBar、TabBar、Drawer、Navigator |
| 11 | Material 3 组件 | `Material3组件/material3_widgets.dart` | NavigationBar、NavigationRail、SegmentedButton、SearchBar、Badge |
| 12 | Cupertino（iOS 风格） | `Cupertino风格/cupertino_widgets.dart` | CupertinoButton、CupertinoAlertDialog、CupertinoActionSheet、CupertinoSwitch / Slider、CupertinoPicker、CupertinoNavigationBar |
| 13 | 对话框与反馈 | `对话框与反馈/feedback_widgets.dart` | AlertDialog、SnackBar、BottomSheet、Tooltip、ProgressIndicator |
| 14 | 手势与交互 | `手势与交互/gesture_widgets.dart` | GestureDetector、Dismissible、Draggable、InkWell |
| 15 | 动画 | `动画/animation_widgets.dart` | AnimatedContainer、AnimatedOpacity、Hero、AnimatedBuilder |
| 16 | 动画进阶 | `动画进阶/advanced_animation_widgets.dart` | AnimationController + Tween、TweenAnimationBuilder、AnimatedSwitcher、AnimatedList、交错动画 |
| 17 | 状态与数据 | `状态与数据/state_widgets.dart` | StatefulWidget、InheritedWidget、FutureBuilder、StreamBuilder、ValueListenableBuilder |
| 18 | 生命周期与 Key | `生命周期与Key/lifecycle_widgets.dart` | State 生命周期、AppLifecycleListener、Key 与列表重排、GlobalKey |
| 19 | 适配与主题 | `适配与主题/adaptive_widgets.dart` | Theme、MediaQuery、LayoutBuilder、SafeArea |
| 20 | 绘制 | `绘制/paint_widgets.dart` | CustomPaint、CustomClipper |
| 21 | 组件传值 | `组件传值/value_passing_widgets.dart` | 构造函数、回调、状态提升、InheritedWidget、ValueNotifier、Notification、GlobalKey、页面间传值、状态管理方案概览 |
| 22 | 路由 | `路由/route_widgets.dart` | push/pop、返回值、传参、命名路由、栈操作、自定义转场、PopScope、嵌套路由、路由监听、方案概览 |
| 23 | 网络与异步 | `网络与异步/network_widgets.dart`、`post_api.dart` | Future 与 async/await、JSON 序列化、HTTP GET、HTTP POST、加载 / 错误 / 空状态、下拉刷新、上拉加载更多 |
| 24 | 本地存储 | `本地存储/storage_widgets.dart` | SharedPreferences、JSON 对象持久化、文件读写、存储方案对比 |
| 25 | 工程化 | `工程化/engineering_widgets.dart` | 国际化 i18n、深色模式、MethodChannel、工程化清单 |

> 源码路径均相对于 `lib/widgets/`。「组件传值」「路由」「网络与异步」「动画进阶」「生命周期与 Key」等文件顶部都有一张"场景 → 推荐方式"速查表。

### 推荐学习路线

1. **布局入门**（1–6）：先理解约束与尺寸，再学滚动
2. **常用组件**（7–14）：Material、Material 3、Cupertino 三套组件
3. **动画**（15–16）：隐式动画 → 显式动画 → 编排
4. **状态与架构**（17–22）：生命周期、Key、组件传值、路由
5. **实战能力**（23–25）：网络、存储、国际化、主题、原生通信、工程化

## 项目结构

```
Flutter_course/
├── lib/
│   ├── main.dart                  # 入口：MaterialApp（主题 / 国际化）+ 首页目录 + Demo 页面外壳
│   ├── app/
│   │   └── app_settings.dart      # 全局设置：ThemeMode、Locale（ChangeNotifier）
│   ├── l10n/                      # 国际化：app_zh.arb（模板）、app_en.arb + 自动生成的代码
│   └── widgets/
│       ├── catalog.dart           # 目录注册表：新增示例在这里加一行
│       ├── 基础容器/ … 工程化/      # 25 个分类，每个分类一个或多个 *_widgets.dart
├── test/widget_test.dart          # 逐个构建全部示例；网络与插件均已 Mock
├── assets/icon/                   # App 图标、自适应图标前景、启动页 Logo
├── android/ ios/                  # 平台工程（含 MethodChannel 原生实现）
├── l10n.yaml                      # gen-l10n 配置
├── .github/workflows/flutter.yml  # CI：format + analyze + test
└── pubspec.yaml
```

## 如何新增一个示例

1. 在对应分类目录下的 `*_widgets.dart` 中新增 `XxxDemo`（`StatelessWidget` / `StatefulWidget` 均可），
   并在类上方按 **【是什么】【属性】【注意】【常见使用场景】** 写好中文文档注释。
2. 在 `lib/widgets/catalog.dart` 对应分类下加一行：
   ```dart
   CatalogEntry('Xxx', '一句话说明', (_) => const XxxDemo()),
   ```
   新分类则新增一个 `CatalogCategory('分类名', Icons.xxx, [...])`。
3. 运行检查：
   ```bash
   dart format lib test
   flutter analyze
   flutter test
   ```
   测试会自动构建新示例。如果示例会访问网络或调用插件，请参考 `test/widget_test.dart`
   中的 `PostApi.clientFactory`（注入假的 http Client）和 `SharedPreferences.setMockInitialValues`。

## 常用命令

| 命令 | 作用 |
|---|---|
| `flutter pub get` | 安装依赖并生成国际化代码 |
| `flutter test` | 运行测试（会构建全部 138 个示例） |
| `flutter analyze` | 静态检查 |
| `dart format lib test` | 格式化代码（页宽 120，见 `analysis_options.yaml`） |
| `dart run flutter_launcher_icons` | 根据 `assets/icon/app_icon.png` 重新生成各平台图标 |
| `dart run flutter_native_splash:create` | 重新生成原生启动页 |

## 第三方依赖

| 包 | 用途 |
|---|---|
| [http](https://pub.dev/packages/http) | 网络请求 |
| [shared_preferences](https://pub.dev/packages/shared_preferences) | 键值对存储 |
| [path_provider](https://pub.dev/packages/path_provider) | 获取文件目录 |
| [intl](https://pub.dev/packages/intl) / flutter_localizations | 国际化 |
| [flutter_launcher_icons](https://pub.dev/packages/flutter_launcher_icons)（dev） | 生成 App 图标 |
| [flutter_native_splash](https://pub.dev/packages/flutter_native_splash)（dev） | 生成启动页 |

## 贡献

欢迎提交 Issue 和 PR：补充新的示例、修正注释、完善截图都非常欢迎。
提交前请确保 `dart format`、`flutter analyze`、`flutter test` 全部通过（CI 会自动检查）。

## License

[MIT](LICENSE) © 2026 Aniu456
