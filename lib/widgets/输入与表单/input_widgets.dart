import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 输入与表单：文本输入、表单校验、选择类组件。

Widget _label(String text) => Padding(
  padding: const EdgeInsets.fromLTRB(0, 16, 0, 6),
  child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
);

/// ===================== TextField =====================
///
/// 【是什么】
/// Material 风格的单行/多行文本输入框，是最常用的输入组件。
///
/// 【属性】
/// - controller:       TextEditingController，读取/设置/监听文本，需 dispose
/// - focusNode:        控制焦点（请求焦点、监听焦点变化），需 dispose
/// - decoration:       InputDecoration：labelText 标签、hintText 提示、
///                     helperText 辅助说明、errorText 错误文字、
///                     prefixIcon/suffixIcon 前后图标、border 边框
///                     （OutlineInputBorder / UnderlineInputBorder）、
///                     filled + fillColor 填充、counterText 计数器
/// - keyboardType:     键盘类型：text、number、emailAddress、phone、multiline
/// - textInputAction:  键盘右下角按钮：next、done、search、send
/// - obscureText:      是否隐藏文字（密码）
/// - maxLines:         最大行数，默认 1；设为 null 则自动增高
/// - minLines:         最小行数
/// - maxLength:        最大字符数（会显示计数器）
/// - inputFormatters:  输入格式限制，如 FilteringTextInputFormatter.digitsOnly
/// - onChanged:        文本每次变化回调
/// - onSubmitted:      点击键盘提交按钮回调
/// - enabled / readOnly: 禁用 / 只读
/// - autofocus:        自动获取焦点
/// - style / textAlign: 文字样式 / 对齐
///
/// 【注意】
/// - TextField 在 Row 中必须用 Expanded/SizedBox 约束宽度，否则报无限宽度错误
/// - controller 要在 State 里创建，并在 dispose 中释放
/// - 键盘弹出可能遮挡内容：外层用 SingleChildScrollView
/// - 需要校验时使用 TextFormField + Form
///
/// 【常见使用场景】
/// 1. 登录/注册的账号、密码输入
/// 2. 搜索框
/// 3. 评论、备注等多行输入
/// 4. 验证码、金额等限定格式输入
class TextFieldDemo extends StatefulWidget {
  const TextFieldDemo({super.key});

  @override
  State<TextFieldDemo> createState() => _TextFieldDemoState();
}

class _TextFieldDemoState extends State<TextFieldDemo> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _obscure = true;
  String _changed = '';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('1. 基础：label + hint + 边框'),
          const TextField(
            decoration: InputDecoration(labelText: '用户名', hintText: '请输入用户名', border: OutlineInputBorder()),
          ),
          _label('2. 密码：obscureText + 可切换的后缀图标'),
          TextField(
            obscureText: _obscure,
            decoration: InputDecoration(
              labelText: '密码',
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
              border: const OutlineInputBorder(),
            ),
          ),
          _label('3. controller + onChanged：内容是「$_changed」'),
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: (v) => setState(() => _changed = v),
            decoration: const InputDecoration(
              labelText: '输入后观察上方文字',
              helperText: '辅助说明文字',
              border: OutlineInputBorder(),
            ),
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  _controller.clear();
                  setState(() => _changed = '');
                },
                child: const Text('清空'),
              ),
              TextButton(onPressed: _focusNode.requestFocus, child: const Text('获取焦点')),
            ],
          ),
          _label('4. 键盘类型 + 只能输入数字 + 最大长度'),
          TextField(
            keyboardType: TextInputType.number,
            maxLength: 11,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: '手机号',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          _label('5. 多行输入 minLines / maxLines'),
          const TextField(
            minLines: 3,
            maxLines: 5,
            decoration: InputDecoration(hintText: '请输入备注（3~5 行）', border: OutlineInputBorder()),
          ),
          _label('6. 填充风格 + 圆角 + 错误提示'),
          const TextField(
            decoration: InputDecoration(
              filled: true,
              fillColor: Color(0xFFEFEFEF),
              hintText: '搜索',
              prefixIcon: Icon(Icons.search),
              errorText: '这是 errorText 的样子',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(24)),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          _label('7. 禁用 / 只读'),
          const TextField(
            enabled: false,
            decoration: InputDecoration(labelText: '禁用', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 8),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: '只读内容'),
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
        ],
      ),
    );
  }
}

/// ===================== Form + TextFormField =====================
///
/// 【是什么】
/// Form 把多个表单字段（FormField）组合在一起，统一做校验、保存、重置；
/// TextFormField 是带校验能力的 TextField。
///
/// 【属性】
/// Form:
/// - key:               `GlobalKey<FormState>`，通过它调用
///                      validate() 校验、save() 保存、reset() 重置
/// - autovalidateMode:  何时自动校验：disabled / always / onUserInteraction
/// - onChanged:         任意字段变化的回调
/// - child:             内容，通常是 Column
/// TextFormField（拥有 TextField 的大部分属性，另外还有）:
/// - validator:         校验函数，返回 null 表示通过，返回字符串表示错误信息
/// - onSaved:           调用 save() 时触发，用于取值
/// - initialValue:      初始值（与 controller 不能同时使用）
/// - autovalidateMode:  单个字段自己的校验时机
///
/// 【注意】
/// - GlobalKey 要保存在 State 中，不要在 build 里每次新建
/// - validator 只在 validate() 被调用或开启自动校验时执行
/// - 有 controller 时不能再设置 initialValue
/// - 校验错误以 errorText 方式显示在输入框下方
///
/// 【常见使用场景】
/// 1. 登录、注册、修改资料
/// 2. 地址、订单填写等多字段提交
/// 3. 需要"必填/格式正确"校验的任何输入
class FormDemo extends StatefulWidget {
  const FormDemo({super.key});

  @override
  State<FormDemo> createState() => _FormDemoState();
}

class _FormDemoState extends State<FormDemo> {
  final _formKey = GlobalKey<FormState>();
  final _pwdController = TextEditingController();
  String _name = '';
  String _result = '';

  @override
  void dispose() {
    _pwdController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() => _result = '提交成功：$_name');
    } else {
      setState(() => _result = '校验未通过，请检查红色提示');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        // 用户输入过后才开始自动校验，避免一进页面就满屏报错
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('注册表单：昵称必填、邮箱格式、密码至少 6 位、两次密码一致'),
            const SizedBox(height: 16),
            TextFormField(
              decoration: const InputDecoration(labelText: '昵称', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? '昵称不能为空' : null,
              onSaved: (v) => _name = v ?? '',
            ),
            const SizedBox(height: 16),
            TextFormField(
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: '邮箱', border: OutlineInputBorder()),
              validator: (v) {
                if (v == null || v.isEmpty) return '邮箱不能为空';
                if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v)) {
                  return '邮箱格式不正确';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _pwdController,
              obscureText: true,
              decoration: const InputDecoration(labelText: '密码', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.length < 6) ? '密码至少 6 位' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              obscureText: true,
              decoration: const InputDecoration(labelText: '确认密码', border: OutlineInputBorder()),
              validator: (v) => v != _pwdController.text ? '两次密码不一致' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(onPressed: _submit, child: const Text('提交')),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: () {
                    _formKey.currentState!.reset();
                    setState(() => _result = '');
                  },
                  child: const Text('重置'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(_result, style: const TextStyle(color: Colors.indigo)),
          ],
        ),
      ),
    );
  }
}

/// ===================== Checkbox =====================
///
/// 【是什么】
/// 复选框，表示"选中 / 未选中"（可选三态）。多个 Checkbox 可同时选中。
///
/// 【属性】
/// - value:         当前是否选中（bool?；tristate 为 true 时 null 表示半选）
/// - onChanged:     状态变化回调，参数是新值；为 null 则禁用
/// - tristate:      是否三态（true / false / null）
/// - activeColor:   选中时的填充色
/// - checkColor:    对勾颜色
/// - side:          未选中时的边框
/// - shape:         形状（如圆形 CircleBorder）
/// - materialTapTargetSize: 点击区域大小
/// - CheckboxListTile: 带标题/副标题的整行复选框，整行可点击，更常用
///
/// 【注意】
/// - Checkbox 本身无状态，value 要由外部 State 保存并在 onChanged 里 setState
/// - onChanged 回调参数是 bool?，赋值给 bool 变量时需处理 null
/// - 列表中的选项优先用 CheckboxListTile，点击范围大
///
/// 【常见使用场景】
/// 1. 同意用户协议
/// 2. 多选筛选条件、兴趣爱好
/// 3. 待办事项勾选、全选/反选
class CheckboxDemo extends StatefulWidget {
  const CheckboxDemo({super.key});

  @override
  State<CheckboxDemo> createState() => _CheckboxDemoState();
}

class _CheckboxDemoState extends State<CheckboxDemo> {
  bool _agree = false;
  bool? _tri = false;
  final Map<String, bool> _hobbies = {'读书': true, '音乐': false, '运动': false};

  // 全选状态：全选 true、全不选 false、其余 null（半选）
  bool? get _allState {
    final n = _hobbies.values.where((v) => v).length;
    if (n == _hobbies.length) return true;
    if (n == 0) return false;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('1. 基础 Checkbox + 文字'),
          Row(
            children: [
              Checkbox(value: _agree, onChanged: (v) => setState(() => _agree = v ?? false)),
              const Text('我同意用户协议'),
            ],
          ),
          _label('2. 自定义颜色'),
          Checkbox(value: true, activeColor: Colors.orange, checkColor: Colors.black, onChanged: (_) {}),
          _label('3. 禁用（onChanged: null）'),
          const Row(children: [Checkbox(value: true, onChanged: null), Checkbox(value: false, onChanged: null)]),
          _label('4. 三态 tristate（当前：$_tri）'),
          Checkbox(tristate: true, value: _tri, onChanged: (v) => setState(() => _tri = v)),
          _label('5. CheckboxListTile + 全选联动'),
          CheckboxListTile(
            title: const Text('全选'),
            tristate: true,
            value: _allState,
            controlAffinity: ListTileControlAffinity.leading,
            onChanged: (v) => setState(() {
              for (final k in _hobbies.keys) {
                _hobbies[k] = v ?? false;
              }
            }),
          ),
          for (final e in _hobbies.entries)
            CheckboxListTile(
              title: Text(e.key),
              subtitle: Text('选择${e.key}'),
              value: e.value,
              onChanged: (v) => setState(() => _hobbies[e.key] = v ?? false),
            ),
        ],
      ),
    );
  }
}

/// ===================== Radio =====================
///
/// 【是什么】
/// 单选按钮，同一组中只能选中一个。新版 Flutter 用 RadioGroup 管理
/// 一组 Radio 的当前值与变化回调。
///
/// 【属性】
/// `RadioGroup<T>`:
/// - groupValue:   当前选中的值
/// - onChanged:    选中变化回调（参数 T?）
/// - child:        包含若干 Radio 的子树
/// `Radio<T>`:
/// - value:        该按钮代表的值（必填）
/// - activeColor:  选中颜色
/// - enabled:      是否可用
/// RadioListTile: 带标题的整行单选（value/title/subtitle/secondary）
///
/// 【注意】
/// - 旧写法 Radio(groupValue:, onChanged:) 已弃用，应放到外层 RadioGroup 上
/// - 同一组的 Radio 要在同一个 RadioGroup 下，泛型类型要一致
/// - 单选一旦选中无法通过再次点击取消
/// - 选项很多时考虑 DropdownButton；只有两种状态用 Switch
///
/// 【常见使用场景】
/// 1. 性别、支付方式选择
/// 2. 设置里的互斥选项（主题、语言）
/// 3. 问卷单选题
class RadioDemo extends StatefulWidget {
  const RadioDemo({super.key});

  @override
  State<RadioDemo> createState() => _RadioDemoState();
}

enum _Pay { wechat, alipay, card }

class _RadioDemoState extends State<RadioDemo> {
  String _gender = '男';
  _Pay _pay = _Pay.wechat;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('1. 基础 Radio（RadioGroup）：当前 $_gender'),
          RadioGroup<String>(
            groupValue: _gender,
            onChanged: (v) => setState(() => _gender = v ?? _gender),
            child: const Row(
              children: [
                Radio<String>(value: '男'),
                Text('男'),
                SizedBox(width: 16),
                Radio<String>(value: '女'),
                Text('女'),
                SizedBox(width: 16),
                Radio<String>(value: '保密', activeColor: Colors.green),
                Text('保密（绿色）'),
              ],
            ),
          ),
          _label('2. RadioListTile：当前 ${_pay.name}'),
          RadioGroup<_Pay>(
            groupValue: _pay,
            onChanged: (v) => setState(() => _pay = v ?? _pay),
            child: const Column(
              children: [
                RadioListTile<_Pay>(value: _Pay.wechat, title: Text('微信支付'), secondary: Icon(Icons.chat)),
                RadioListTile<_Pay>(
                  value: _Pay.alipay,
                  title: Text('支付宝'),
                  subtitle: Text('推荐使用'),
                  secondary: Icon(Icons.account_balance_wallet),
                ),
                RadioListTile<_Pay>(
                  value: _Pay.card,
                  title: Text('银行卡（暂不可用）'),
                  enabled: false,
                  secondary: Icon(Icons.credit_card),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== Switch =====================
///
/// 【是什么】
/// 开关，表示"开 / 关"两种状态，修改后一般立即生效。
///
/// 【属性】
/// - value:               当前开关状态
/// - onChanged:           状态变化回调，null 则禁用
/// - activeThumbColor:    打开时滑块颜色
/// - activeTrackColor:    打开时轨道颜色
/// - inactiveThumbColor / inactiveTrackColor: 关闭时的滑块/轨道颜色
/// - thumbIcon:           滑块上的图标（`WidgetStateProperty<Icon?>`）
/// - Switch.adaptive:     根据平台自动使用 iOS 或 Material 风格
/// - SwitchListTile:      带标题的整行开关
///
/// 【注意】
/// - 同 Checkbox，value 由外部 State 管理
/// - 旧的 activeColor 控制的是滑块色，新版推荐 activeThumbColor / activeTrackColor
/// - 需要用户确认再提交的选择用 Checkbox，即时生效的设置用 Switch
///
/// 【常见使用场景】
/// 1. 设置页：通知开关、深色模式
/// 2. 功能启用 / 禁用
/// 3. 隐私选项
class SwitchDemo extends StatefulWidget {
  const SwitchDemo({super.key});

  @override
  State<SwitchDemo> createState() => _SwitchDemoState();
}

class _SwitchDemoState extends State<SwitchDemo> {
  bool _a = true;
  bool _b = false;
  bool _c = true;
  bool _d = false;
  bool _e = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('1. 基础'),
          Switch(value: _a, onChanged: (v) => setState(() => _a = v)),
          _label('2. 自定义颜色'),
          Switch(
            value: _b,
            activeThumbColor: Colors.white,
            activeTrackColor: Colors.green,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.shade300,
            onChanged: (v) => setState(() => _b = v),
          ),
          _label('3. 滑块带图标 thumbIcon'),
          Switch(
            value: _c,
            thumbIcon: WidgetStateProperty.resolveWith(
              (states) => Icon(states.contains(WidgetState.selected) ? Icons.check : Icons.close),
            ),
            onChanged: (v) => setState(() => _c = v),
          ),
          _label('4. 禁用'),
          const Row(children: [Switch(value: true, onChanged: null), Switch(value: false, onChanged: null)]),
          _label('5. 平台自适应 Switch.adaptive'),
          Switch.adaptive(value: _d, onChanged: (v) => setState(() => _d = v)),
          _label('6. SwitchListTile'),
          SwitchListTile(
            title: const Text('消息通知'),
            subtitle: Text(_e ? '已开启' : '已关闭'),
            secondary: const Icon(Icons.notifications),
            value: _e,
            onChanged: (v) => setState(() => _e = v),
          ),
        ],
      ),
    );
  }
}

/// ===================== Slider =====================
///
/// 【是什么】
/// 滑动条，在一个连续或离散的数值范围内选择值。
///
/// 【属性】
/// - value:        当前值（必须在 min~max 之间）
/// - onChanged:    拖动时回调，null 则禁用
/// - onChangeStart / onChangeEnd: 开始 / 结束拖动回调（结束时常用于提交）
/// - min / max:    范围，默认 0.0~1.0
/// - divisions:    把范围分成几段；设置后变成离散值并可显示 label
/// - label:        拖动时显示在气泡里的文字（需配合 divisions）
/// - activeColor / inactiveColor: 已滑过 / 未滑过部分的颜色
/// - thumbColor:   滑块颜色
/// - RangeSlider:  双滑块，选区间（RangeValues）
/// - SliderTheme:  更细致的样式（轨道高度、滑块大小等）
///
/// 【注意】
/// - value 超出 min~max 会断言报错
/// - 默认范围 0~1，要用 0~100 记得设置 max
/// - Slider 需要有限的宽度；放在 Row 里请用 Expanded
/// - 频繁回调时在 onChangeEnd 再做耗时操作
///
/// 【常见使用场景】
/// 1. 音量、亮度调节
/// 2. 价格区间筛选
/// 3. 评分、字号大小调整
class SliderDemo extends StatefulWidget {
  const SliderDemo({super.key});

  @override
  State<SliderDemo> createState() => _SliderDemoState();
}

class _SliderDemoState extends State<SliderDemo> {
  double _v1 = 0.3;
  double _v2 = 50;
  double _v3 = 3;
  RangeValues _range = const RangeValues(20, 80);
  double _fontSize = 16;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('1. 基础（默认 0~1）：${_v1.toStringAsFixed(2)}'),
          Slider(value: _v1, onChanged: (v) => setState(() => _v1 = v)),
          _label('2. 自定义范围 + 颜色：${_v2.round()}'),
          Slider(
            value: _v2,
            min: 0,
            max: 100,
            activeColor: Colors.red,
            inactiveColor: Colors.red.shade100,
            onChanged: (v) => setState(() => _v2 = v),
          ),
          _label('3. 离散 divisions + label：${_v3.round()} 星'),
          Slider(
            value: _v3,
            min: 1,
            max: 5,
            divisions: 4,
            label: '${_v3.round()} 星',
            onChanged: (v) => setState(() => _v3 = v),
          ),
          _label('4. RangeSlider：${_range.start.round()} ~ ${_range.end.round()}'),
          RangeSlider(
            values: _range,
            min: 0,
            max: 100,
            divisions: 20,
            labels: RangeLabels(_range.start.round().toString(), _range.end.round().toString()),
            onChanged: (v) => setState(() => _range = v),
          ),
          _label('5. 禁用'),
          const Slider(value: 0.5, onChanged: null),
          _label('6. 实际应用：调整字号'),
          Row(
            children: [
              const Icon(Icons.text_fields, size: 16),
              Expanded(
                child: Slider(value: _fontSize, min: 12, max: 40, onChanged: (v) => setState(() => _fontSize = v)),
              ),
              const Icon(Icons.text_fields, size: 32),
            ],
          ),
          Text('Flutter 你好', style: TextStyle(fontSize: _fontSize)),
        ],
      ),
    );
  }
}

/// ===================== DropdownButton =====================
///
/// 【是什么】
/// 下拉选择按钮：点击后弹出菜单列表，选中一项。
/// 配合 Form 时使用 DropdownButtonFormField；Material 3 还有 DropdownMenu。
///
/// 【属性】
/// - items:          `List<DropdownMenuItem<T>>`，每项含 value 和 child
/// - value:          当前选中项的值（必须匹配 items 中某项，或为 null）
/// - onChanged:      选中变化回调，null 则禁用
/// - hint:           未选择时的提示
/// - disabledHint:   禁用时的提示
/// - isExpanded:     是否撑满父级宽度（默认只包裹内容）
/// - icon / iconSize: 右侧箭头图标
/// - underline:      下划线，设为 const SizedBox() 可去掉
/// - style:          选中项文字样式
/// - dropdownColor:  弹出菜单的背景色
/// - borderRadius:   弹出菜单圆角
/// - selectedItemBuilder: 自定义选中后在按钮上显示的内容
/// - DropdownButtonFormField: 带 InputDecoration 与校验的版本
///
/// 【注意】
/// - value 必须出现在 items 里且唯一，否则会报断言错误
/// - 在 Row 中使用且 isExpanded: true 时，要有有限宽度（外层 Expanded）
/// - 需要输入过滤/搜索，使用 DropdownMenu（Material 3）
///
/// 【常见使用场景】
/// 1. 选择城市、国家、分类
/// 2. 排序方式、筛选条件
/// 3. 表单中的选项字段
class DropdownButtonDemo extends StatefulWidget {
  const DropdownButtonDemo({super.key});

  @override
  State<DropdownButtonDemo> createState() => _DropdownButtonDemoState();
}

class _DropdownButtonDemoState extends State<DropdownButtonDemo> {
  static const _cities = ['北京', '上海', '广州', '深圳'];
  String _city = '北京';
  String? _hintValue;
  String? _formValue;

  @override
  Widget build(BuildContext context) {
    final items = _cities.map((c) => DropdownMenuItem<String>(value: c, child: Text(c))).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label('1. 基础：当前 $_city'),
          DropdownButton<String>(value: _city, items: items, onChanged: (v) => setState(() => _city = v ?? _city)),
          _label('2. 带 hint（未选择）+ 撑满宽度 isExpanded'),
          DropdownButton<String>(
            value: _hintValue,
            hint: const Text('请选择城市'),
            isExpanded: true,
            items: items,
            onChanged: (v) => setState(() => _hintValue = v),
          ),
          _label('3. 自定义图标 / 去掉下划线 / 菜单样式'),
          DropdownButton<String>(
            value: _city,
            items: items,
            icon: const Icon(Icons.arrow_drop_down_circle),
            underline: const SizedBox(),
            dropdownColor: Colors.amber.shade100,
            borderRadius: BorderRadius.circular(12),
            style: const TextStyle(color: Colors.deepPurple, fontSize: 18),
            onChanged: (v) => setState(() => _city = v ?? _city),
          ),
          _label('4. 禁用'),
          DropdownButton<String>(value: '北京', items: items, onChanged: null),
          _label('5. DropdownButtonFormField（带边框与校验）'),
          DropdownButtonFormField<String>(
            initialValue: _formValue,
            items: items,
            decoration: const InputDecoration(labelText: '所在城市', border: OutlineInputBorder()),
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: (v) => v == null ? '请选择城市' : null,
            onChanged: (v) => setState(() => _formValue = v),
          ),
        ],
      ),
    );
  }
}
