import 'package:flutter/material.dart';

import '基础容器/container_widgets.dart';
import '线性布局/linear_widgets.dart';
import '弹性布局/flex_widgets.dart';
import '流式布局/flow_widgets.dart';
import '层叠布局/stack_widgets.dart';
import '滚动布局/scroll_widgets.dart';
import '基础展示/display_widgets.dart';
import '按钮/button_widgets.dart';
import '输入与表单/input_widgets.dart';
import '导航/navigation_widgets.dart';
import '对话框与反馈/feedback_widgets.dart';
import '手势与交互/gesture_widgets.dart';
import '动画/animation_widgets.dart';
import '状态与数据/state_widgets.dart';
import '适配与主题/adaptive_widgets.dart';
import '绘制/paint_widgets.dart';
import '组件传值/value_passing_widgets.dart';
import '路由/route_widgets.dart';
import '基础容器/sizing_widgets.dart';
import '线性布局/table_widgets.dart';
import '层叠布局/visibility_widgets.dart';
import '滚动布局/sliver_widgets.dart';
import '输入与表单/picker_widgets.dart';
import 'Material3组件/material3_widgets.dart';
import 'Cupertino风格/cupertino_widgets.dart';
import '动画进阶/advanced_animation_widgets.dart';
import '生命周期与Key/lifecycle_widgets.dart';
import '网络与异步/network_widgets.dart';
import '本地存储/storage_widgets.dart';
import '工程化/engineering_widgets.dart';

/// 目录中的一个条目：标题 + 一句话说明 + 对应的示例页面。
class CatalogEntry {
  const CatalogEntry(this.title, this.summary, this.builder);

  final String title;
  final String summary;
  final WidgetBuilder builder;
}

class CatalogCategory {
  const CatalogCategory(this.name, this.icon, this.entries);

  final String name;
  final IconData icon;
  final List<CatalogEntry> entries;
}

/// 所有分类与示例的注册表。新增示例时，在这里加一行即可出现在首页目录。
final List<CatalogCategory> catalog = [
  CatalogCategory('基础容器', Icons.crop_square, [
    CatalogEntry('Container', '组合型容器：尺寸、边距、背景、边框、圆角、阴影', (_) => const ContainerDemo()),
    CatalogEntry('Padding', '给子组件加内边距', (_) => const PaddingDemo()),
    CatalogEntry('Center', '让子组件居中', (_) => const CenterDemo()),
    CatalogEntry('Align', '按比例对齐子组件', (_) => const AlignDemo()),
    CatalogEntry('SizedBox', '固定尺寸 / 占位间距', (_) => const SizedBoxDemo()),
    CatalogEntry('ConstrainedBox', '限制最小 / 最大尺寸', (_) => const ConstrainedBoxDemo()),
    CatalogEntry('DecoratedBox', '只负责装饰（背景、边框、阴影）', (_) => const DecoratedBoxDemo()),
    CatalogEntry('Card', 'Material 风格卡片', (_) => const CardDemo()),
    CatalogEntry('ClipRRect', '圆角裁剪', (_) => const ClipRRectDemo()),
    CatalogEntry('Opacity', '透明度', (_) => const OpacityDemo()),
    CatalogEntry('Transform', '旋转、缩放、平移', (_) => const TransformDemo()),
    CatalogEntry('AspectRatio', '固定宽高比', (_) => const AspectRatioDemo()),
    CatalogEntry('FittedBox', '按 BoxFit 缩放子组件', (_) => const FittedBoxDemo()),
    CatalogEntry('FractionallySizedBox', '按父组件比例确定尺寸', (_) => const FractionallySizedBoxDemo()),
  ]),
  CatalogCategory('线性布局', Icons.view_agenda_outlined, [
    CatalogEntry('Row', '水平排列', (_) => const RowDemo()),
    CatalogEntry('Column', '垂直排列', (_) => const ColumnDemo()),
    CatalogEntry('Table', '表格：行列对齐', (_) => const TableDemo()),
  ]),
  CatalogCategory('弹性布局', Icons.open_in_full, [
    CatalogEntry('Flex', 'Row / Column 的父类，可指定方向', (_) => const FlexDemo()),
    CatalogEntry('Expanded', '按比例占满剩余空间', (_) => const ExpandedDemo()),
    CatalogEntry('Flexible', '可松可紧的弹性空间', (_) => const FlexibleDemo()),
    CatalogEntry('Spacer', '弹性空白', (_) => const SpacerDemo()),
  ]),
  CatalogCategory('流式布局', Icons.wrap_text, [
    CatalogEntry('Wrap', '自动换行的流式布局', (_) => const WrapDemo()),
    CatalogEntry('Flow', '自定义定位的高性能流式布局', (_) => const FlowDemo()),
  ]),
  CatalogCategory('层叠布局', Icons.layers_outlined, [
    CatalogEntry('Stack', '层叠子组件', (_) => const StackDemo()),
    CatalogEntry('Positioned', '在 Stack 中绝对定位', (_) => const PositionedDemo()),
    CatalogEntry('IndexedStack', '只显示指定下标的子组件', (_) => const IndexedStackDemo()),
    CatalogEntry('Visibility / Offstage', '显示与隐藏的几种方式对比', (_) => const VisibilityDemo()),
  ]),
  CatalogCategory('滚动布局', Icons.swap_vert, [
    CatalogEntry('ListView', '列表', (_) => const ListViewDemo()),
    CatalogEntry('GridView', '网格', (_) => const GridViewDemo()),
    CatalogEntry('SingleChildScrollView', '让单个子组件可滚动', (_) => const SingleChildScrollViewDemo()),
    CatalogEntry('CustomScrollView', 'Sliver 组合滚动', (_) => const CustomScrollViewDemo()),
    CatalogEntry('PageView', '整页滑动', (_) => const PageViewDemo()),
    CatalogEntry('SliverAppBar', '可折叠的顶部栏', (_) => const SliverAppBarDemo()),
    CatalogEntry('ReorderableListView', '拖拽排序列表', (_) => const ReorderableListViewDemo()),
  ]),
  CatalogCategory('基础展示', Icons.text_fields, [
    CatalogEntry('Text', '文本', (_) => const TextDemo()),
    CatalogEntry('Icon', '图标', (_) => const IconDemo()),
    CatalogEntry('Image', '图片', (_) => const ImageDemo()),
    CatalogEntry('RichText', '富文本', (_) => const RichTextDemo()),
    CatalogEntry('Divider', '分割线', (_) => const DividerDemo()),
    CatalogEntry('CircleAvatar', '圆形头像', (_) => const CircleAvatarDemo()),
    CatalogEntry('Chip', '标签', (_) => const ChipDemo()),
  ]),
  CatalogCategory('按钮', Icons.smart_button, [
    CatalogEntry('ElevatedButton', '凸起按钮', (_) => const ElevatedButtonDemo()),
    CatalogEntry('TextButton', '文字按钮', (_) => const TextButtonDemo()),
    CatalogEntry('OutlinedButton', '描边按钮', (_) => const OutlinedButtonDemo()),
    CatalogEntry('IconButton', '图标按钮', (_) => const IconButtonDemo()),
    CatalogEntry('FloatingActionButton', '悬浮按钮', (_) => const FloatingActionButtonDemo()),
  ]),
  CatalogCategory('输入与表单', Icons.edit_note, [
    CatalogEntry('TextField', '文本输入框', (_) => const TextFieldDemo()),
    CatalogEntry('Form', '表单与校验', (_) => const FormDemo()),
    CatalogEntry('Checkbox', '复选框', (_) => const CheckboxDemo()),
    CatalogEntry('Radio', '单选框', (_) => const RadioDemo()),
    CatalogEntry('Switch', '开关', (_) => const SwitchDemo()),
    CatalogEntry('Slider', '滑块', (_) => const SliderDemo()),
    CatalogEntry('DropdownButton', '下拉选择', (_) => const DropdownButtonDemo()),
    CatalogEntry('日期 / 时间选择器', 'showDatePicker / showTimePicker', (_) => const DateTimePickerDemo()),
  ]),
  CatalogCategory('导航', Icons.explore_outlined, [
    CatalogEntry('Scaffold', '页面脚手架', (_) => const ScaffoldDemo()),
    CatalogEntry('AppBar', '顶部栏', (_) => const AppBarDemo()),
    CatalogEntry('BottomNavigationBar', '底部导航栏', (_) => const BottomNavigationBarDemo()),
    CatalogEntry('TabBar', '标签页', (_) => const TabBarDemo()),
    CatalogEntry('Drawer', '侧边抽屉', (_) => const DrawerDemo()),
    CatalogEntry('Navigator', '页面跳转', (_) => const NavigatorDemo()),
  ]),
  CatalogCategory('Material 3 组件', Icons.auto_awesome_outlined, [
    CatalogEntry('NavigationBar', 'M3 底部导航栏', (_) => const NavigationBarDemo()),
    CatalogEntry('NavigationRail', '宽屏侧边导航', (_) => const NavigationRailDemo()),
    CatalogEntry('SegmentedButton', '分段按钮：单选 / 多选', (_) => const SegmentedButtonDemo()),
    CatalogEntry('SearchBar', '搜索栏与搜索建议', (_) => const SearchBarDemo()),
    CatalogEntry('Badge', '角标 / 小红点', (_) => const BadgeDemo()),
  ]),
  CatalogCategory('Cupertino（iOS 风格）', Icons.phone_iphone, [
    CatalogEntry('CupertinoButton', 'iOS 风格按钮', (_) => const CupertinoButtonDemo()),
    CatalogEntry('CupertinoAlertDialog', 'iOS 风格对话框', (_) => const CupertinoAlertDialogDemo()),
    CatalogEntry('CupertinoActionSheet', 'iOS 底部操作表', (_) => const CupertinoActionSheetDemo()),
    CatalogEntry('CupertinoSwitch / Slider', '开关、滑块、分段控件', (_) => const CupertinoSwitchSliderDemo()),
    CatalogEntry('CupertinoPicker', '滚轮选择器 / 日期滚轮', (_) => const CupertinoPickerDemo()),
    CatalogEntry('CupertinoNavigationBar', 'iOS 导航栏与大标题', (_) => const CupertinoNavigationBarDemo()),
  ]),
  CatalogCategory('对话框与反馈', Icons.chat_bubble_outline, [
    CatalogEntry('AlertDialog', '对话框', (_) => const AlertDialogDemo()),
    CatalogEntry('SnackBar', '底部提示条', (_) => const SnackBarDemo()),
    CatalogEntry('BottomSheet', '底部弹出面板', (_) => const BottomSheetDemo()),
    CatalogEntry('Tooltip', '长按提示', (_) => const TooltipDemo()),
    CatalogEntry('ProgressIndicator', '进度指示器', (_) => const ProgressIndicatorDemo()),
  ]),
  CatalogCategory('手势与交互', Icons.touch_app_outlined, [
    CatalogEntry('GestureDetector', '手势识别', (_) => const GestureDetectorDemo()),
    CatalogEntry('Dismissible', '滑动删除', (_) => const DismissibleDemo()),
    CatalogEntry('Draggable', '拖拽与接收', (_) => const DraggableDemo()),
    CatalogEntry('InkWell', '带水波纹的点击', (_) => const InkWellDemo()),
  ]),
  CatalogCategory('动画', Icons.animation, [
    CatalogEntry('AnimatedContainer', '隐式动画容器', (_) => const AnimatedContainerDemo()),
    CatalogEntry('AnimatedOpacity', '渐变动画', (_) => const AnimatedOpacityDemo()),
    CatalogEntry('Hero', '共享元素转场', (_) => const HeroDemo()),
    CatalogEntry('AnimatedBuilder', '显式动画', (_) => const AnimatedBuilderDemo()),
  ]),
  CatalogCategory('动画进阶', Icons.motion_photos_on_outlined, [
    CatalogEntry('AnimationController + Tween', '显式动画：播放、反向、循环、曲线', (_) => const ExplicitAnimationDemo()),
    CatalogEntry('TweenAnimationBuilder', '无需 Controller 的自定义补间', (_) => const TweenAnimationBuilderDemo()),
    CatalogEntry('AnimatedSwitcher', '新旧组件切换动画', (_) => const AnimatedSwitcherDemo()),
    CatalogEntry('AnimatedList', '插入 / 删除带动画的列表', (_) => const AnimatedListDemo()),
    CatalogEntry('交错动画', 'Interval 编排多段动画', (_) => const StaggeredAnimationDemo()),
  ]),
  CatalogCategory('状态与数据', Icons.sync_alt, [
    CatalogEntry('StatefulWidget', '有状态组件与生命周期', (_) => const StatefulWidgetDemo()),
    CatalogEntry('InheritedWidget', '向下共享数据', (_) => const InheritedWidgetDemo()),
    CatalogEntry('FutureBuilder', '异步 Future 构建 UI', (_) => const FutureBuilderDemo()),
    CatalogEntry('StreamBuilder', '数据流构建 UI', (_) => const StreamBuilderDemo()),
    CatalogEntry('ValueListenableBuilder', '监听 ValueNotifier', (_) => const ValueListenableBuilderDemo()),
  ]),
  CatalogCategory('生命周期与 Key', Icons.autorenew, [
    CatalogEntry('State 生命周期', 'initState / didUpdateWidget / dispose 日志', (_) => const StateLifecycleDemo()),
    CatalogEntry('AppLifecycleListener', 'App 前后台切换监听', (_) => const AppLifecycleDemo()),
    CatalogEntry('Key 与列表重排', '不写 Key vs ValueKey', (_) => const KeyReorderDemo()),
    CatalogEntry('GlobalKey', '跨父组件保留状态', (_) => const GlobalKeyReparentDemo()),
  ]),
  CatalogCategory('适配与主题', Icons.devices, [
    CatalogEntry('Theme', '主题', (_) => const ThemeDemo()),
    CatalogEntry('MediaQuery', '屏幕信息', (_) => const MediaQueryDemo()),
    CatalogEntry('LayoutBuilder', '根据约束布局', (_) => const LayoutBuilderDemo()),
    CatalogEntry('SafeArea', '安全区域', (_) => const SafeAreaDemo()),
  ]),
  CatalogCategory('绘制', Icons.brush_outlined, [
    CatalogEntry('CustomPaint', '自定义绘制', (_) => const CustomPaintDemo()),
    CatalogEntry('CustomClipper', '自定义裁剪', (_) => const CustomClipperDemo()),
  ]),
  CatalogCategory('组件传值', Icons.share_outlined, [
    CatalogEntry('构造函数传值', '父传子', (_) => const ConstructorPassingDemo()),
    CatalogEntry('回调传值', '子传父', (_) => const CallbackPassingDemo()),
    CatalogEntry('状态提升', '兄弟组件通信', (_) => const LiftStateUpDemo()),
    CatalogEntry('InheritedWidget 传值', '跨层级传值', (_) => const InheritedWidgetPassingDemo()),
    CatalogEntry('ValueNotifier 传值', '共享可监听状态', (_) => const ValueNotifierPassingDemo()),
    CatalogEntry('Notification 传值', '子向祖先冒泡', (_) => const NotificationPassingDemo()),
    CatalogEntry('GlobalKey 传值', '直接调用子 State（不推荐）', (_) => const GlobalKeyPassingDemo()),
    CatalogEntry('页面间传值', 'push 传参与 pop 返回', (_) => const RoutePassingDemo()),
    CatalogEntry('状态管理方案概览', 'Provider / Riverpod / Bloc / GetX', (_) => const StateManagementOverviewDemo()),
  ]),
  CatalogCategory('路由', Icons.alt_route, [
    CatalogEntry('Navigator 基础', 'push / pop 与路由栈', (_) => const NavigatorBasicDemo()),
    CatalogEntry('路由返回值', 'pop(result) 回传数据', (_) => const RouteReturnValueDemo()),
    CatalogEntry('路由传参', '构造函数与 arguments', (_) => const RouteArgumentsDemo()),
    CatalogEntry('命名路由', 'routes / onGenerateRoute', (_) => const NamedRouteDemo()),
    CatalogEntry('路由栈操作', 'pushReplacement / popUntil 等', (_) => const RouteStackOpsDemo()),
    CatalogEntry('自定义转场', 'PageRouteBuilder', (_) => const RouteTransitionDemo()),
    CatalogEntry('拦截返回', 'PopScope', (_) => const PopScopeDemo()),
    CatalogEntry('嵌套路由', '每个 Tab 独立路由栈', (_) => const NestedNavigatorDemo()),
    CatalogEntry('路由监听', 'NavigatorObserver / RouteAware', (_) => const RouteObserverDemo()),
    CatalogEntry('路由方案概览', 'Navigator 2.0 / go_router', (_) => const RouterOverviewDemo()),
  ]),
  CatalogCategory('网络与异步', Icons.cloud_outlined, [
    CatalogEntry('Future 与 async/await', '顺序、并行、异常、超时', (_) => const FutureAsyncDemo()),
    CatalogEntry('JSON 序列化', 'jsonDecode / fromJson / toJson', (_) => const JsonModelDemo()),
    CatalogEntry('HTTP GET', 'http 包请求列表数据', (_) => const HttpGetDemo()),
    CatalogEntry('HTTP POST', '提交 JSON 表单', (_) => const HttpPostDemo()),
    CatalogEntry('加载 / 错误 / 空状态', '异步页面的状态处理', (_) => const LoadStateDemo()),
    CatalogEntry('下拉刷新', 'RefreshIndicator', (_) => const RefreshIndicatorDemo()),
    CatalogEntry('上拉加载更多', '分页 + 无限滚动', (_) => const LoadMoreDemo()),
  ]),
  CatalogCategory('本地存储', Icons.save_outlined, [
    CatalogEntry('SharedPreferences', '键值对存储', (_) => const SharedPreferencesDemo()),
    CatalogEntry('JSON 对象持久化', '对象列表存到本地', (_) => const JsonPersistenceDemo()),
    CatalogEntry('文件读写', 'path_provider + dart:io', (_) => const FileStorageDemo()),
    CatalogEntry('存储方案对比', 'prefs / 文件 / 数据库 / 安全存储', (_) => const StorageOverviewDemo()),
  ]),
  CatalogCategory('工程化', Icons.engineering_outlined, [
    CatalogEntry('国际化 i18n', 'flutter_localizations + gen-l10n', (_) => const I18nDemo()),
    CatalogEntry('深色模式', 'ThemeMode 浅色 / 深色 / 跟随系统', (_) => const ThemeModeDemo()),
    CatalogEntry('MethodChannel', '调用 Android / iOS 原生代码', (_) => const MethodChannelDemo()),
    CatalogEntry('工程化清单', 'Lint、CI、图标、启动页、版本号', (_) => const EngineeringChecklistDemo()),
  ]),
];
