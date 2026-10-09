import 'package:flutter/material.dart';

// 基础容器：每个 Demo 类对应一个组件，类上方的文档注释说明用法，类内是可运行示例。

/// ===================== Container =====================
///
/// 【是什么】
/// Container 是一个"组合型"组件，本身不负责绘制，而是把常用的
/// 尺寸(ConstrainedBox)、内边距(Padding)、外边距(Padding)、
/// 对齐(Align)、背景/边框/圆角/阴影(DecoratedBox)、变换(Transform)、
/// 裁剪(ClipPath) 等组件按固定顺序包在 child 外面，省得手动嵌套。
///
/// 【属性】
/// - child:               子组件，只能有一个
/// - width / height:      固定宽高（内部会转成 tight 的 constraints）
/// - constraints:         BoxConstraints，设置最小/最大宽高；
///                        与 width/height 同时设置时，宽高会合并进 constraints
/// - color:               背景色（内部是 ColoredBox）
/// - decoration:          装饰，通常是 BoxDecoration：
///                        color 背景色、border 边框、borderRadius 圆角、
///                        boxShadow 阴影、gradient 渐变、image 背景图、
///                        shape（rectangle / circle）
/// - foregroundDecoration: 画在 child 上面的装饰（如遮罩、角标）
/// - padding:             内边距：边框与 child 之间的空白，背景色会覆盖这块区域
/// - margin:              外边距：Container 与外部之间的空白，背景色不会覆盖
/// - alignment:           child 在 Container 内的对齐位置，如 Alignment.center
/// - transform:           Matrix4 变换（旋转、缩放、平移），不影响布局占位
/// - transformAlignment:  变换的原点
/// - clipBehavior:        裁剪方式，默认 Clip.none；有 decoration 且想让
///                        child 被圆角裁掉时要设 Clip.antiAlias
///
/// 【尺寸规则】（最容易踩坑）
/// 1. 没有 child、没有 width/height/constraints：撑满父组件给的空间
/// 2. 有 child、没有设置尺寸：和 child 一样大（包裹内容）
/// 3. 设置了 alignment：会尽量撑满父组件（因为内部加了 Align）
/// 4. 父组件给的是"紧约束"（如放在 Scaffold.body 直接子级）时，
///    自己设置的 width/height 会被忽略；用 Center / Align 包一层即可放松约束
///
/// 【注意】
/// - color 和 decoration 不能同时设置，否则运行时断言报错；
///   需要颜色又要圆角/边框时，把颜色写进 BoxDecoration(color: ...)
/// - 只需要一种效果时，用更轻量的专用组件更好：
///   只要留白用 Padding，只要固定尺寸用 SizedBox，
///   只要背景色用 ColoredBox，只要对齐用 Align / Center
///
/// 【常见使用场景】
/// 1. 给内容加背景色 / 边框 / 圆角 / 阴影（卡片、标签、按钮背景）
/// 2. 设置固定大小的色块、占位图
/// 3. 给内容加内外边距
/// 4. 渐变背景、背景图
/// 5. 圆形头像背景（shape: BoxShape.circle）
/// 6. 配合 alignment 在固定区域里居中 / 靠边放置内容
class ContainerDemo extends StatelessWidget {
  const ContainerDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // 示例 1：最基础——固定宽高 + 背景色 + 居中子组件
          Container(
            width: 200,
            height: 80,
            color: Colors.amber,
            alignment: Alignment.center,
            child: const Text('1. color + alignment'),
          ),

          // 示例 2：padding 与 margin 的区别（蓝色区域包含 padding，不含 margin）
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            color: Colors.lightBlue,
            child: const Text('2. margin 在外，padding 在内'),
          ),

          // 示例 3：decoration——圆角 + 边框 + 阴影
          // 注意：此处不能再写 color:，颜色要放在 BoxDecoration 里
          Container(
            width: 220,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.deepPurple, width: 2),
              boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(2, 4))],
            ),
            child: const Text('3. BoxDecoration'),
          ),

          const SizedBox(height: 16),

          // 示例 4：渐变背景
          Container(
            width: 220,
            height: 80,
            alignment: Alignment.center,
            decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.orange, Colors.pink])),
            child: const Text('4. gradient', style: TextStyle(color: Colors.white)),
          ),

          const SizedBox(height: 16),

          // 示例 5：圆形（shape: circle 时不能再设置 borderRadius）
          Container(
            width: 80,
            height: 80,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
            child: const Text('5. 圆', style: TextStyle(color: Colors.white)),
          ),

          const SizedBox(height: 16),

          // 示例 6：constraints——限制最小/最大尺寸，内容多时在范围内自适应
          Container(
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 220),
            color: Colors.greenAccent,
            child: const Text('6. constraints 限制宽度范围，文字过长会换行'),
          ),

          // 示例 7：transform——旋转（只改变绘制，不改变占位）
          Container(
            margin: const EdgeInsets.symmetric(vertical: 24),
            width: 120,
            height: 50,
            color: Colors.redAccent,
            alignment: Alignment.center,
            transform: Matrix4.rotationZ(0.1),
            child: const Text('7. transform'),
          ),

          // 示例 8：clipBehavior——让 child 被圆角裁剪
          Container(
            width: 120,
            height: 60,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
            clipBehavior: Clip.antiAlias,
            child: Container(color: Colors.indigo),
          ),
        ],
      ),
    );
  }
}

/// 示例标题小组件（本文件内共用）
class _Label extends StatelessWidget {
  const _Label(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }
}

/// ===================== Padding =====================
///
/// 【是什么】
/// 给 child 四周增加内边距（留白）的最轻量组件。
///
/// 【属性】
/// - padding: EdgeInsets，必填。常用构造：
///     EdgeInsets.all(8)                 四边相同
///     EdgeInsets.symmetric(horizontal:, vertical:)  水平/垂直对称
///     EdgeInsets.only(left:, top:, right:, bottom:) 指定某几边
///     EdgeInsets.fromLTRB(l, t, r, b)   四边分别指定
///     EdgeInsetsDirectional              随文字方向（RTL）自动翻转
/// - child:   子组件，可为空
///
/// 【注意】
/// - Padding 自己没有背景色；想要带颜色的留白，用 Container(padding: ...)
///   或把 Padding 放进有颜色的组件里
/// - 外边距的效果就是在目标组件外面再包一层 Padding
/// - 想在多个子组件之间留间距，Column/Row 可用 SizedBox 或 spacing 属性
///
/// 【常见使用场景】
/// 1. 页面内容与屏幕边缘保持距离
/// 2. 列表项、卡片内部留白
/// 3. 给图标、文字增加点击/视觉空间
class PaddingDemo extends StatelessWidget {
  const PaddingDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. EdgeInsets.all(24)'),
          Container(
            color: Colors.amber.shade100,
            child: const Padding(padding: EdgeInsets.all(24), child: Text('四周都是 24 的留白')),
          ),
          const _Label('2. EdgeInsets.symmetric'),
          Container(
            color: Colors.lightBlue.shade100,
            child: const Padding(padding: EdgeInsets.symmetric(horizontal: 48, vertical: 8), child: Text('水平 48，垂直 8')),
          ),
          const _Label('3. EdgeInsets.only'),
          Container(
            color: Colors.green.shade100,
            child: const Padding(padding: EdgeInsets.only(left: 80, top: 20), child: Text('只有左 80、上 20')),
          ),
          const _Label('4. EdgeInsets.fromLTRB'),
          Container(
            color: Colors.pink.shade100,
            child: const Padding(padding: EdgeInsets.fromLTRB(10, 20, 60, 5), child: Text('左10 上20 右60 下5')),
          ),
          const _Label('5. 嵌套 Padding：叠加留白'),
          Container(
            color: Colors.grey.shade300,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Padding(padding: EdgeInsets.all(16), child: Text('8 + 16 = 24')),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== Center =====================
///
/// 【是什么】
/// 把 child 放在自己的正中央。本质是 Align(alignment: Alignment.center)。
///
/// 【属性】
/// - child:        子组件
/// - widthFactor:  不为空时，Center 宽度 = child 宽度 × 该倍数
/// - heightFactor: 不为空时，Center 高度 = child 高度 × 该倍数
///
/// 【注意】
/// - 父级约束有界时，Center 会尽量撑满父组件；无界（如在 Column、
///   ListView 里）时则包裹 child
/// - 设置了 widthFactor / heightFactor 后，该方向不再撑满，而是按倍数计算
/// - 放在 Scaffold.body 里可以"放松"紧约束，让子组件的 width/height 生效
/// - 只想居中单个组件：Center；想靠左/右/任意位置：Align
///
/// 【常见使用场景】
/// 1. 页面中央放加载圈、空状态提示
/// 2. 放松紧约束，让固定尺寸的子组件生效
/// 3. 在 Container 内居中文字（也可直接用 Container.alignment）
class CenterDemo extends StatelessWidget {
  const CenterDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 在有界区域内居中'),
          Container(
            height: 120,
            color: Colors.amber.shade100,
            child: const Center(child: Icon(Icons.star, size: 48)),
          ),
          const _Label('2. Center 放松约束，让 100x50 生效'),
          Container(
            height: 120,
            color: Colors.lightBlue.shade100,
            child: Center(child: Container(width: 100, height: 50, color: Colors.blue)),
          ),
          const _Label('3. widthFactor / heightFactor = 2（尺寸为 child 的 2 倍）'),
          Container(
            color: Colors.green.shade100,
            child: const Center(widthFactor: 2, heightFactor: 2, child: Text('我被放大两倍的空间包住')),
          ),
          const _Label('4. 不设 factor：宽度撑满、高度有界时也撑满'),
          Container(
            height: 60,
            color: Colors.pink.shade100,
            child: const Center(child: Text('Hello Center')),
          ),
        ],
      ),
    );
  }
}

/// ===================== Align =====================
///
/// 【是什么】
/// 按指定对齐方式把 child 放在自己范围内的某个位置（Center 是它的特例）。
///
/// 【属性】
/// - alignment:    对齐位置，默认 Alignment.center。
///                 Alignment(x, y)，x/y 取值 -1~1：(-1,-1) 左上，(0,0) 中心，
///                 (1,1) 右下。常量如 topLeft、topCenter、centerRight、bottomRight
///                 FractionalOffset 以左上为原点、取值 0~1
/// - widthFactor / heightFactor: 同 Center，按 child 尺寸的倍数决定自身尺寸
/// - child:        子组件
///
/// 【注意】
/// - 父约束有界时 Align 会撑满，所以需要时可给 Align 外面包 SizedBox
///   或 Container 限定区域
/// - 要配合文字方向，使用 AlignmentDirectional
/// - 在 Stack 里定位子元素优先用 Positioned，简单对齐用 Align
///
/// 【常见使用场景】
/// 1. 把角标、按钮放在容器的角落
/// 2. 文字靠左 / 靠右
/// 3. 用 Alignment(x, y) 做精确的相对位置摆放
class AlignDemo extends StatelessWidget {
  const AlignDemo({super.key});

  Widget _box(String label, Alignment a) {
    return Container(
      width: 140,
      height: 90,
      color: Colors.grey.shade200,
      child: Align(
        alignment: a,
        child: Container(
          padding: const EdgeInsets.all(4),
          color: Colors.deepPurple,
          child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 11)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 常量对齐'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _box('topLeft', Alignment.topLeft),
                _box('topRight', Alignment.topRight),
                _box('center', Alignment.center),
                _box('bottomLeft', Alignment.bottomLeft),
                _box('bottomRight', Alignment.bottomRight),
                _box('centerRight', Alignment.centerRight),
              ],
            ),
          ),
          const _Label('2. 自定义 Alignment(0.5, -0.5)：横向偏右四分之一、纵向偏上'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _box('(0.5, -0.5)', const Alignment(0.5, -0.5)),
          ),
          const _Label('3. FractionalOffset(0.2, 0.8)：以左上为原点'),
          Container(
            height: 90,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.amber.shade100,
            child: const Align(
              alignment: FractionalOffset(0.2, 0.8),
              child: Icon(Icons.location_on, color: Colors.red),
            ),
          ),
          const _Label('4. widthFactor：Align 宽度 = child 宽度 × 3'),
          Container(
            color: Colors.green.shade100,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: const Align(
              alignment: Alignment.centerLeft,
              widthFactor: 3,
              heightFactor: 1.5,
              child: Text('Factor'),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ===================== SizedBox =====================
///
/// 【是什么】
/// 给 child 指定固定宽高的盒子；没有 child 时就是一块空白间距。
///
/// 【属性】
/// - width / height: 固定宽高，可只设一个
/// - child:          子组件，可为空
/// - 构造函数：
///     SizedBox.expand()          尽可能撑满父组件
///     SizedBox.shrink()          尺寸为 0
///     SizedBox.square(dimension) 正方形
///     SizedBox.fromSize(size:)   用 Size 指定
///
/// 【注意】
/// - 父组件给的是紧约束时，SizedBox 的尺寸会被父约束覆盖
///   （用 Center / Align 包一层放松约束）
/// - width: double.infinity 表示尽量占满父级宽度（常用于撑满的按钮）
/// - 只是留间距时用 SizedBox 比空 Container 更轻量
///
/// 【常见使用场景】
/// 1. Column / Row 中子组件之间的间距
/// 2. 限制按钮、图片、加载圈的尺寸
/// 3. 让按钮宽度撑满
class SizedBoxDemo extends StatelessWidget {
  const SizedBoxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. 固定宽高限制子组件', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            width: 160,
            height: 60,
            child: ElevatedButton(onPressed: () {}, child: const Text('160 x 60')),
          ),
          const SizedBox(height: 16),
          const Text('2. 当作间距（下面两个色块相隔 40）', style: TextStyle(fontWeight: FontWeight.bold)),
          Container(width: 80, height: 30, color: Colors.amber),
          const SizedBox(height: 40),
          Container(width: 80, height: 30, color: Colors.lightBlue),
          const SizedBox(height: 16),
          const Text('3. width: double.infinity 撑满宽度', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(onPressed: () {}, child: const Text('撑满的按钮')),
          ),
          const SizedBox(height: 16),
          const Text('4. SizedBox.square：正方形加载圈', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const SizedBox.square(dimension: 48, child: CircularProgressIndicator()),
          const SizedBox(height: 16),
          const Text('5. SizedBox.expand：撑满父级（外层限定 100 高）', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SizedBox(
            height: 100,
            child: SizedBox.expand(child: Container(color: Colors.green.shade200)),
          ),
          const SizedBox(height: 16),
          const Text('6. SizedBox.shrink：不占空间（左右之间无间隔）', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 40, height: 30, color: Colors.red),
              const SizedBox.shrink(),
              Container(width: 40, height: 30, color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}

/// ===================== ConstrainedBox =====================
///
/// 【是什么】
/// 在父级约束之上，再给 child 追加一组 BoxConstraints（最小/最大宽高）。
///
/// 【属性】
/// - constraints: BoxConstraints，必填：
///     minWidth / maxWidth / minHeight / maxHeight
///     BoxConstraints.tight(Size)  固定尺寸
///     BoxConstraints.expand()     尽量撑满
///     BoxConstraints.loose(Size)  最小为 0，最大为指定值
/// - child:       子组件
///
/// 【注意】
/// - 多层 ConstrainedBox 嵌套时，会取"交集"：最小值取较大者，最大值取较小者
/// - 不能突破父级约束：父级最大 200，你写 minWidth 300 也只有 200
/// - 想强制固定尺寸用 SizedBox；想要"至少 xx、至多 yy"才用 ConstrainedBox
/// - 想完全无视父约束，可用 UnconstrainedBox / OverflowBox
///
/// 【常见使用场景】
/// 1. 设置按钮 / 输入框的最小宽高
/// 2. 限制文本卡片最大宽度（大屏适配）
/// 3. 与 Center 配合，让内容自适应但不超出范围
class ConstrainedBoxDemo extends StatelessWidget {
  const ConstrainedBoxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. minWidth / minHeight：内容很小也不低于 150x60'),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 150, minHeight: 60),
            child: Container(color: Colors.amber, child: const Text('小内容')),
          ),
          const _Label('2. maxWidth：文字太长时限制宽度并换行'),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 200),
            child: Container(color: Colors.lightBlue.shade100, child: const Text('这是一段很长的文字，会在最大宽度 200 处自动换行显示。')),
          ),
          const _Label('3. 嵌套取交集：min 取大、max 取小 -> 最终 120 宽'),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 100, maxWidth: 200),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 50, maxWidth: 120),
              child: Container(
                height: 40,
                color: Colors.green.shade200,
                child: const SizedBox(width: double.infinity),
              ),
            ),
          ),
          const _Label('4. BoxConstraints.tight：等同固定尺寸 100x40'),
          ConstrainedBox(
            constraints: BoxConstraints.tight(const Size(100, 40)),
            child: Container(color: Colors.pink.shade200),
          ),
          const _Label('5. 给按钮设最小尺寸'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 200, minHeight: 56),
              child: ElevatedButton(onPressed: () {}, child: const Text('OK')),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ===================== DecoratedBox =====================
///
/// 【是什么】
/// 在 child 的背后（或前面）绘制装饰：背景色、边框、圆角、阴影、渐变等。
/// Container 的 decoration 内部就是用它实现的。
///
/// 【属性】
/// - decoration: Decoration，通常用 BoxDecoration：
///     color / gradient / image    背景
///     border                      边框
///     borderRadius                圆角（shape 为 circle 时不能用）
///     boxShadow                   阴影
///     shape                       rectangle / circle
/// - position:   DecorationPosition.background（默认，画在 child 后面）
///               或 foreground（画在 child 前面）
/// - child:      子组件
///
/// 【注意】
/// - DecoratedBox 没有尺寸、内边距属性，大小由 child 决定（无 child 时撑满）
///   需要时配合 SizedBox / Padding 使用
/// - 只需要装饰又要尺寸、留白时，直接用 Container 更方便
/// - 圆角不会裁剪 child，要裁剪请用 ClipRRect
///
/// 【常见使用场景】
/// 1. 渐变背景、圆角卡片背景
/// 2. 带边框的标签 / 徽章
/// 3. 在图片上叠一层渐变遮罩（position: foreground）
class DecoratedBoxDemo extends StatelessWidget {
  const DecoratedBoxDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('1. 背景色 + 圆角 + 边框'),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange, width: 2),
            ),
            child: const Padding(padding: EdgeInsets.all(16), child: Text('圆角边框盒子')),
          ),
          const SizedBox(height: 20),
          const Text('2. 渐变背景'),
          const SizedBox(height: 8),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.purple, Colors.blue],
              ),
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            child: SizedBox(
              height: 70,
              width: double.infinity,
              child: Center(
                child: Text('LinearGradient', style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text('3. 阴影'),
          const SizedBox(height: 8),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 1, offset: Offset(0, 4)),
              ],
            ),
            child: const Padding(padding: EdgeInsets.all(20), child: Text('带阴影的卡片')),
          ),
          const SizedBox(height: 20),
          const Text('4. 圆形 shape: BoxShape.circle'),
          const SizedBox(height: 8),
          const DecoratedBox(
            decoration: BoxDecoration(color: Colors.teal, shape: BoxShape.circle),
            child: SizedBox(width: 70, height: 70, child: Icon(Icons.person, color: Colors.white, size: 36)),
          ),
          const SizedBox(height: 20),
          const Text('5. position: foreground 装饰盖在 child 上面'),
          const SizedBox(height: 8),
          DecoratedBox(
            position: DecorationPosition.foreground,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
              ),
            ),
            child: Container(
              height: 100,
              color: Colors.orange,
              alignment: Alignment.center,
              child: const Icon(Icons.landscape, size: 60, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

/// ===================== Card =====================
///
/// 【是什么】
/// Material 风格卡片：带圆角和阴影的面板，用来承载一组相关内容。
///
/// 【属性】
/// - child:        子组件
/// - color:        背景色（默认取主题 cardColor / surface）
/// - elevation:    阴影高度，越大越明显
/// - shadowColor:  阴影颜色
/// - surfaceTintColor: 表面着色（Material 3）
/// - shape:        形状，如 RoundedRectangleBorder(borderRadius:, side:)
/// - margin:       外边距（默认四周 4）
/// - borderOnForeground: 边框画在 child 上面还是下面
/// - clipBehavior: 裁剪方式，默认 Clip.none；child 有图片/色块要被圆角裁掉时
///                 设 Clip.antiAlias
/// - Card.filled / Card.outlined: Material 3 的填充 / 描边样式
///
/// 【注意】
/// - Card 没有 padding 属性，内部留白需自己加 Padding
/// - Card 默认有 margin，宽度在有界区域内会撑满
/// - 想自定义更多装饰（渐变等）用 Container + BoxDecoration
///
/// 【常见使用场景】
/// 1. 信息列表项（新闻、商品、订单）
/// 2. 设置面板分组
/// 3. 仪表盘数据块
class CardDemo extends StatelessWidget {
  const CardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 默认 Card'),
          const Card(
            child: Padding(padding: EdgeInsets.all(16), child: Text('最简单的 Card')),
          ),
          const _Label('2. elevation 阴影高度 12 + 自定义 shadowColor'),
          const Card(
            elevation: 12,
            shadowColor: Colors.deepPurple,
            child: Padding(padding: EdgeInsets.all(16), child: Text('阴影更明显')),
          ),
          const _Label('3. color + shape（大圆角和边框）'),
          Card(
            color: Colors.amber.shade100,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: const BorderSide(color: Colors.orange, width: 2),
            ),
            child: const Padding(padding: EdgeInsets.all(16), child: Text('自定义形状')),
          ),
          const _Label('4. clipBehavior: 子组件被圆角裁剪'),
          Card(
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Column(
              children: [
                Container(height: 80, color: Colors.indigo),
                const ListTile(leading: Icon(Icons.album), title: Text('歌曲名称'), subtitle: Text('歌手')),
              ],
            ),
          ),
          const _Label('5. Card.outlined / Card.filled（Material 3）'),
          const Card.outlined(
            child: Padding(padding: EdgeInsets.all(16), child: Text('outlined 描边卡片')),
          ),
          const Card.filled(
            child: Padding(padding: EdgeInsets.all(16), child: Text('filled 填充卡片')),
          ),
          const _Label('6. margin 外边距'),
          const Card(
            margin: EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            child: Padding(padding: EdgeInsets.all(16), child: Text('左右 margin 40')),
          ),
        ],
      ),
    );
  }
}

/// ===================== ClipRRect =====================
///
/// 【是什么】
/// 用圆角矩形裁剪 child，超出圆角的部分不再显示。
///
/// 【属性】
/// - borderRadius: BorderRadius，裁剪圆角；
///                 BorderRadius.circular(r) 四角相同，
///                 BorderRadius.only(topLeft: ...) 指定某角，
///                 BorderRadius.vertical / horizontal 上下 / 左右
/// - clipBehavior: 裁剪质量，默认 Clip.antiAlias（抗锯齿）；
///                 hardEdge 最快但边缘有锯齿，antiAliasWithSaveLayer 最慢最精细
/// - clipper:      自定义裁剪区域（CustomClipper 的 RRect 版本）
/// - child:        子组件
///
/// 【注意】
/// - 裁剪有性能开销，不要大面积、频繁使用；
///   只需要圆角背景用 DecoratedBox / Container 即可
/// - 想裁成圆形：用 ClipOval，或 ClipRRect 半径设为边长的一半
/// - 其它裁剪组件：ClipRect（矩形）、ClipOval（椭圆）、ClipPath（任意路径）
/// - borderRadius 并不会改变 child 的布局尺寸，只是画出来被裁掉
///
/// 【常见使用场景】
/// 1. 圆角图片、圆角视频
/// 2. 圆形头像
/// 3. 让内容被容器的圆角边裁掉
class ClipRRectDemo extends StatelessWidget {
  const ClipRRectDemo({super.key});

  Widget _img(Color c) => Container(
    width: 120,
    height: 80,
    color: c,
    alignment: Alignment.center,
    child: const Icon(Icons.image, color: Colors.white, size: 40),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 不裁剪（对照）'),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _img(Colors.indigo)),
          const _Label('2. BorderRadius.circular(20)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(borderRadius: BorderRadius.circular(20), child: _img(Colors.indigo)),
          ),
          const _Label('3. 只裁左上和右下'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(topLeft: Radius.circular(40), bottomRight: Radius.circular(40)),
              child: _img(Colors.teal),
            ),
          ),
          const _Label('4. 圆形头像：半径 = 边长的一半'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(40),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.orange,
                child: const Icon(Icons.person, size: 48, color: Colors.white),
              ),
            ),
          ),
          const _Label('5. ClipOval 椭圆裁剪'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipOval(child: _img(Colors.pink)),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ===================== Opacity =====================
///
/// 【是什么】
/// 让 child 整体变得半透明（含它的所有子孙）。
///
/// 【属性】
/// - opacity:            透明度，0.0 完全透明 ~ 1.0 完全不透明，必填
/// - alwaysIncludeSemantics: 完全透明时是否仍保留语义（无障碍）信息，默认 false
/// - child:              子组件
///
/// 【注意】
/// - 完全透明（0.0）时 child 仍占据布局空间，且不绘制、也不响应点击；
///   需要隐藏并释放空间用 Visibility
/// - Opacity 会产生离屏缓冲，开销较大；动画请用 AnimatedOpacity 或 FadeTransition
/// - 只要颜色半透明，直接用 color.withValues(alpha: ...) 更高效
/// - Image 等单个组件可用自己的 opacity / color 参数
///
/// 【常见使用场景】
/// 1. 禁用状态的置灰效果
/// 2. 淡入淡出（配合 AnimatedOpacity）
/// 3. 遮罩、水印
class OpacityDemo extends StatefulWidget {
  const OpacityDemo({super.key});

  @override
  State<OpacityDemo> createState() => _OpacityDemoState();
}

class _OpacityDemoState extends State<OpacityDemo> {
  double _value = 0.5;
  bool _visible = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. 不同透明度：1.0 / 0.6 / 0.3 / 0.0（占位仍在）'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final o in [1.0, 0.6, 0.3, 0.0])
                  Opacity(
                    opacity: o,
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      color: Colors.blue,
                      alignment: Alignment.center,
                      child: Text('$o', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
          const _Label('2. 拖动滑块实时调整 opacity'),
          Opacity(
            opacity: _value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 70,
              color: Colors.deepOrange,
              alignment: Alignment.center,
              child: Text('opacity = ${_value.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white)),
            ),
          ),
          Slider(value: _value, onChanged: (v) => setState(() => _value = v)),
          const _Label('3. AnimatedOpacity：带动画的淡入淡出（推荐）'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 500),
                  child: const Icon(Icons.favorite, color: Colors.red, size: 48),
                ),
                const SizedBox(width: 16),
                ElevatedButton(onPressed: () => setState(() => _visible = !_visible), child: const Text('切换')),
              ],
            ),
          ),
          const _Label('4. 禁用效果：半透明按钮'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Opacity(
              opacity: 0.4,
              child: ElevatedButton(onPressed: () {}, child: const Text('看起来被禁用')),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

/// ===================== Transform =====================
///
/// 【是什么】
/// 在绘制阶段对 child 做矩阵变换：旋转、缩放、平移、倾斜。
///
/// 【属性】
/// - transform:       Matrix4 变换矩阵（默认构造函数使用）
/// - origin:          变换原点偏移（相对于 child 左上角基础上的 Offset）
/// - alignment:       变换原点的对齐方式，默认左上角（Transform.rotate 默认中心）
/// - transformHitTests: 点击测试是否跟随变换，默认 true
/// - filterQuality:   变换后的图像过滤质量
/// - 便捷构造函数：
///     Transform.rotate(angle:)        旋转，单位弧度（pi = 180°）
///     Transform.scale(scale:)         缩放（scaleX / scaleY 单独缩放）
///     Transform.translate(offset:)    平移
///     Transform.flip(flipX:, flipY:)  翻转
///
/// 【注意】
/// - Transform 只改变绘制，不改变布局：child 原本占的位置不变，
///   可能会与周围组件重叠
/// - 要让旋转影响布局（如 90° 后占位互换）用 RotatedBox
/// - 做动画时配合 AnimatedRotation / AnimatedScale / AnimatedSlide，
///   或 RotationTransition 等
/// - 旋转角度单位是弧度：角度 × pi / 180
///
/// 【常见使用场景】
/// 1. 旋转图标（如展开/收起箭头）
/// 2. 点击时的缩放反馈
/// 3. 轻微倾斜的贴纸、角标
/// 4. 3D 透视效果（Matrix4.identity()..setEntry(3, 2, 0.001)）
class TransformDemo extends StatelessWidget {
  const TransformDemo({super.key});

  Widget _box(String t, [Color c = Colors.blue]) => Container(
    width: 80,
    height: 50,
    color: c,
    alignment: Alignment.center,
    child: Text(t, style: const TextStyle(color: Colors.white)),
  );

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Label('1. Transform.rotate（弧度，π/6 = 30°）'),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Transform.rotate(angle: 0.5236, child: _box('rotate')),
          ),
          const _Label('2. Transform.scale（放大 1.5 倍，但占位不变）'),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Transform.scale(scale: 1.5, child: _box('scale', Colors.green)),
          ),
          const _Label('3. Transform.translate（平移 40, 10）'),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Transform.translate(offset: const Offset(40, 10), child: _box('translate', Colors.orange)),
          ),
          const _Label('4. Transform.flip（水平翻转）'),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Transform.flip(
              flipX: true,
              child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(Icons.arrow_forward), Text('flipX')]),
            ),
          ),
          const _Label('5. Matrix4：倾斜 + alignment 指定原点'),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.skewX(0.4),
              child: _box('skewX', Colors.purple),
            ),
          ),
          const _Label('6. 3D 透视旋转（绕 Y 轴）'),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.002)
                ..rotateY(0.6),
              child: _box('3D', Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
