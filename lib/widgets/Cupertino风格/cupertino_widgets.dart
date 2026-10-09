import 'package:flutter/cupertino.dart';

// Cupertino（iOS 风格）组件：按钮、对话框、操作表、开关 / 滑块、滚轮选择器、导航栏。
//
// 【说明】
// - import 'package:flutter/cupertino.dart' 即可使用，任何平台都能渲染
// - Material 与 Cupertino 组件可以混用；完全 iOS 风格的 App 可以用 CupertinoApp
// - 很多 Material 组件有 .adaptive 构造（Switch.adaptive、Slider.adaptive、
//   AlertDialog.adaptive、CircularProgressIndicator.adaptive），会在 iOS 上自动使用 Cupertino 外观

Widget _title(String text) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
  );
}

/// ===================== CupertinoButton =====================
///
/// 【是什么】
/// iOS 风格按钮：没有水波纹，按下时变淡。
///
/// 【构造】
/// - CupertinoButton(child, onPressed)：纯文字按钮
/// - CupertinoButton.filled：主题色填充按钮
/// - CupertinoButton.tinted：浅色背景按钮
///
/// 【属性】
/// - onPressed: 为 null 时禁用
/// - color / disabledColor: 背景色
/// - padding / minimumSize / borderRadius: 尺寸与圆角
/// - pressedOpacity: 按下时的透明度，默认 0.4
/// - sizeStyle: small / medium / large 预设尺寸
///
/// 【常见使用场景】
/// iOS 风格页面的主操作、导航栏按钮、表单提交
class CupertinoButtonDemo extends StatefulWidget {
  const CupertinoButtonDemo({super.key});

  @override
  State<CupertinoButtonDemo> createState() => _CupertinoButtonDemoState();
}

class _CupertinoButtonDemoState extends State<CupertinoButtonDemo> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('点击次数：$_count', textAlign: TextAlign.center, style: const TextStyle(fontSize: 18)),
        _title('CupertinoButton（纯文字）'),
        CupertinoButton(onPressed: () => setState(() => _count++), child: const Text('文字按钮')),
        _title('CupertinoButton.filled'),
        CupertinoButton.filled(onPressed: () => setState(() => _count++), child: const Text('填充按钮')),
        _title('CupertinoButton.tinted'),
        CupertinoButton.tinted(onPressed: () => setState(() => _count++), child: const Text('浅色按钮')),
        _title('自定义颜色 + 图标'),
        CupertinoButton(
          color: CupertinoColors.systemGreen,
          borderRadius: BorderRadius.circular(24),
          onPressed: () => setState(() => _count++),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.heart_fill, color: CupertinoColors.white),
              SizedBox(width: 8),
              Text('喜欢'),
            ],
          ),
        ),
        _title('禁用（onPressed: null）'),
        const CupertinoButton.filled(onPressed: null, child: Text('禁用')),
      ],
    );
  }
}

/// ===================== CupertinoAlertDialog =====================
///
/// 【是什么】
/// iOS 风格的提示对话框，配合 showCupertinoDialog 弹出。
///
/// 【属性】
/// - title / content: 标题、内容
/// - actions: `List<CupertinoDialogAction>`
///   - isDefaultAction: 加粗，表示推荐操作
///   - isDestructiveAction: 红色，表示危险操作（删除等）
///
/// 【注意】
/// - showCupertinoDialog 默认点击遮罩不关闭，需要 barrierDismissible: true
/// - 按钮里用 Navigator.pop(context, 结果) 关闭并返回值
/// - 想按平台自动选择风格可用 AlertDialog.adaptive + showAdaptiveDialog
///
/// 【常见使用场景】
/// 删除确认、权限说明、重要提示
class CupertinoAlertDialogDemo extends StatefulWidget {
  const CupertinoAlertDialogDemo({super.key});

  @override
  State<CupertinoAlertDialogDemo> createState() => _CupertinoAlertDialogDemoState();
}

class _CupertinoAlertDialogDemoState extends State<CupertinoAlertDialogDemo> {
  String _result = '（尚未操作）';

  Future<void> _show() async {
    final result = await showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('删除照片？'),
        content: const Text('删除后将无法恢复。'),
        actions: [
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, '取消'),
            child: const Text('取消'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, '删除'),
            child: const Text('删除'),
          ),
        ],
      ),
    );
    if (mounted) setState(() => _result = result ?? '（未选择）');
  }

  Future<void> _showInput() async {
    final controller = TextEditingController();
    final result = await showCupertinoDialog<String>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('重命名'),
        content: Padding(
          padding: const EdgeInsets.only(top: 12),
          child: CupertinoTextField(controller: controller, placeholder: '输入新名称', autofocus: true),
        ),
        actions: [
          CupertinoDialogAction(onPressed: () => Navigator.pop(context), child: const Text('取消')),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('确定'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (mounted) setState(() => _result = result == null ? '（已取消）' : '新名称：$result');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton.filled(onPressed: _show, child: const Text('删除确认对话框')),
          const SizedBox(height: 12),
          CupertinoButton.tinted(onPressed: _showInput, child: const Text('带输入框的对话框')),
          const SizedBox(height: 24),
          Text('结果：$_result'),
        ],
      ),
    );
  }
}

/// ===================== CupertinoActionSheet =====================
///
/// 【是什么】
/// iOS 风格的底部操作表，配合 showCupertinoModalPopup 从底部弹出。
///
/// 【属性】
/// - title / message: 标题、说明
/// - actions: `List<CupertinoActionSheetAction>`（可设 isDestructiveAction / isDefaultAction）
/// - cancelButton: 单独显示在最下方的取消按钮
///
/// 【注意】
/// - 点击遮罩默认会关闭，返回 null
/// - Material 风格的对应组件是 showModalBottomSheet
///
/// 【常见使用场景】
/// 选择照片来源（拍照 / 相册）、分享、更多操作菜单
class CupertinoActionSheetDemo extends StatefulWidget {
  const CupertinoActionSheetDemo({super.key});

  @override
  State<CupertinoActionSheetDemo> createState() => _CupertinoActionSheetDemoState();
}

class _CupertinoActionSheetDemoState extends State<CupertinoActionSheetDemo> {
  String _result = '（尚未选择）';

  Future<void> _show() async {
    final result = await showCupertinoModalPopup<String>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('更换头像'),
        message: const Text('请选择图片来源'),
        actions: [
          CupertinoActionSheetAction(onPressed: () => Navigator.pop(context, '拍照'), child: const Text('拍照')),
          CupertinoActionSheetAction(onPressed: () => Navigator.pop(context, '从相册选择'), child: const Text('从相册选择')),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(context, '移除头像'),
            child: const Text('移除头像'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(context),
          child: const Text('取消'),
        ),
      ),
    );
    if (mounted) setState(() => _result = result ?? '（已取消）');
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton.filled(onPressed: _show, child: const Text('弹出操作表')),
          const SizedBox(height: 24),
          Text('选择：$_result'),
        ],
      ),
    );
  }
}

/// ===================== CupertinoSwitch / CupertinoSlider / 分段控件 =====================
///
/// 【是什么】
/// - CupertinoSwitch：iOS 开关，属性 value / onChanged / activeTrackColor
/// - CupertinoSlider：iOS 滑块，属性 value / min / max / divisions / onChanged
/// - CupertinoSlidingSegmentedControl：iOS 分段控件（带滑动指示器）
///
/// 【注意】
/// - 都是受控组件：必须在 onChanged 里 setState 更新 value
/// - 想按平台自动切换：Switch.adaptive / Slider.adaptive
///
/// 【常见使用场景】
/// iOS 风格的设置页
class CupertinoSwitchSliderDemo extends StatefulWidget {
  const CupertinoSwitchSliderDemo({super.key});

  @override
  State<CupertinoSwitchSliderDemo> createState() => _CupertinoSwitchSliderDemoState();
}

class _CupertinoSwitchSliderDemoState extends State<CupertinoSwitchSliderDemo> {
  bool _wifi = true;
  bool _bluetooth = false;
  double _volume = 40;
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        CupertinoListSection.insetGrouped(
          header: const Text('CupertinoSwitch'),
          children: [
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.wifi),
              title: const Text('无线局域网'),
              trailing: CupertinoSwitch(value: _wifi, onChanged: (v) => setState(() => _wifi = v)),
            ),
            CupertinoListTile(
              leading: const Icon(CupertinoIcons.bluetooth),
              title: const Text('蓝牙'),
              trailing: CupertinoSwitch(
                value: _bluetooth,
                activeTrackColor: CupertinoColors.systemGreen,
                onChanged: (v) => setState(() => _bluetooth = v),
              ),
            ),
          ],
        ),
        CupertinoListSection.insetGrouped(
          header: Text('CupertinoSlider：音量 ${_volume.round()}'),
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  const Icon(CupertinoIcons.volume_down),
                  Expanded(
                    child: CupertinoSlider(value: _volume, max: 100, onChanged: (v) => setState(() => _volume = v)),
                  ),
                  const Icon(CupertinoIcons.volume_up),
                ],
              ),
            ),
          ],
        ),
        _title('CupertinoSlidingSegmentedControl'),
        Center(
          child: CupertinoSlidingSegmentedControl<int>(
            groupValue: _segment,
            onValueChanged: (v) => setState(() => _segment = v ?? 0),
            children: const {
              0: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('日')),
              1: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('周')),
              2: Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('月')),
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text('当前选择：${['日', '周', '月'][_segment]}视图', textAlign: TextAlign.center),
        ),
      ],
    );
  }
}

/// ===================== CupertinoPicker / CupertinoDatePicker =====================
///
/// 【是什么】
/// iOS 风格的滚轮选择器。
/// - CupertinoPicker：通用滚轮，自定义选项
/// - CupertinoDatePicker：日期 / 时间 / 日期+时间滚轮
///
/// 【CupertinoPicker 属性】
/// - itemExtent: 必填，每一项的高度
/// - onSelectedItemChanged: 选中项变化回调（滚动停止前也会触发）
/// - scrollController: FixedExtentScrollController(initialItem: n) 设置初始项
/// - selectionOverlay / magnification / useMagnifier: 外观
/// - looping: 是否循环滚动
///
/// 【CupertinoDatePicker 属性】
/// - mode: date / time / dateAndTime / monthYear
/// - initialDateTime / minimumDate / maximumDate
/// - use24hFormat / minuteInterval
/// - onDateTimeChanged: 必填
///
/// 【注意】
/// - 滚轮需要有限的高度，常放在固定高度的 SizedBox 或底部弹窗中
/// - 底部弹出：showCupertinoModalPopup + Container(height: 260, child: picker)
///
/// 【常见使用场景】
/// 地区 / 性别 / 数量选择、生日、提醒时间
class CupertinoPickerDemo extends StatefulWidget {
  const CupertinoPickerDemo({super.key});

  @override
  State<CupertinoPickerDemo> createState() => _CupertinoPickerDemoState();
}

class _CupertinoPickerDemoState extends State<CupertinoPickerDemo> {
  static const _cities = ['北京', '上海', '广州', '深圳', '杭州', '成都', '台北', '香港'];
  int _city = 1;
  DateTime _date = DateTime(2000, 1, 1);

  Future<void> _showPopupPicker() async {
    await showCupertinoModalPopup<void>(
      context: context,
      builder: (context) => Container(
        height: 260,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: CupertinoPicker(
            itemExtent: 36,
            scrollController: FixedExtentScrollController(initialItem: _city),
            onSelectedItemChanged: (i) => setState(() => _city = i),
            children: [for (final c in _cities) Center(child: Text(c))],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        _title('1. 内嵌 CupertinoPicker（固定高度）：${_cities[_city]}'),
        SizedBox(
          height: 150,
          child: CupertinoPicker(
            itemExtent: 32,
            looping: true,
            scrollController: FixedExtentScrollController(initialItem: _city),
            onSelectedItemChanged: (i) => setState(() => _city = i),
            children: [for (final c in _cities) Center(child: Text(c))],
          ),
        ),
        _title('2. 底部弹出滚轮'),
        Center(
          child: CupertinoButton.tinted(onPressed: _showPopupPicker, child: Text('选择城市：${_cities[_city]}')),
        ),
        _title('3. CupertinoDatePicker（mode: date）：${_date.year}-${_date.month}-${_date.day}'),
        SizedBox(
          height: 180,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.date,
            initialDateTime: _date,
            minimumDate: DateTime(1900),
            maximumDate: DateTime(2100),
            onDateTimeChanged: (d) => setState(() => _date = d),
          ),
        ),
      ],
    );
  }
}

/// ===================== CupertinoNavigationBar =====================
///
/// 【是什么】
/// iOS 风格的顶部导航栏，通常与 CupertinoPageScaffold 搭配。
/// 大标题效果用 CustomScrollView + CupertinoSliverNavigationBar。
///
/// 【属性】
/// - middle: 中间标题
/// - leading / trailing: 左右两侧组件（返回按钮会自动生成）
/// - backgroundColor / border: 背景（默认半透明毛玻璃）
/// - previousPageTitle: 返回按钮旁显示的上一页标题
/// - CupertinoSliverNavigationBar(largeTitle: ...)：滚动时大标题缩小到中间
///
/// 【注意】
/// - 跳转用 CupertinoPageRoute，获得 iOS 的右滑进入 / 侧滑返回效果
/// - 导航栏默认半透明，内容会延伸到导航栏下方，SafeArea 可避免遮挡
///
/// 【常见使用场景】
/// iOS 风格页面、设置页、列表 → 详情
class CupertinoNavigationBarDemo extends StatelessWidget {
  const CupertinoNavigationBarDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        leading: CupertinoButton(padding: EdgeInsets.zero, onPressed: () {}, child: const Text('编辑')),
        middle: const Text('设置'),
        trailing: CupertinoButton(padding: EdgeInsets.zero, onPressed: () {}, child: const Icon(CupertinoIcons.add)),
      ),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('点击进入：大标题导航栏页面（CupertinoPageRoute）'),
              children: [
                for (final (icon, name) in [
                  (CupertinoIcons.person_crop_circle, '个人信息'),
                  (CupertinoIcons.bell, '通知'),
                  (CupertinoIcons.lock, '隐私与安全'),
                ])
                  CupertinoListTile(
                    leading: Icon(icon),
                    title: Text(name),
                    trailing: const CupertinoListTileChevron(),
                    onTap: () =>
                        Navigator.of(context)
                            .push(CupertinoPageRoute<void>(builder: (_) => _LargeTitlePage(title: name))),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LargeTitlePage extends StatelessWidget {
  const _LargeTitlePage({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(largeTitle: Text(title), previousPageTitle: '设置'),
          SliverList.builder(
            itemCount: 30,
            itemBuilder: (_, i) => CupertinoListTile(title: Text('$title 选项 ${i + 1}')),
          ),
        ],
      ),
    );
  }
}
