// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Flutter 课程';

  @override
  String get catalogTitle => 'Flutter Course 组件目录';

  @override
  String demoCount(int count) {
    return '$count 个示例';
  }

  @override
  String hello(String name) {
    return '你好，$name！';
  }

  @override
  String cartItems(int count) {
    String _temp0 = intl.Intl.pluralLogic(count, locale: localeName, other: '购物车里有 $count 件商品', zero: '购物车是空的');
    return '$_temp0';
  }

  @override
  String today(DateTime date) {
    final intl.DateFormat dateDateFormat = intl.DateFormat.yMMMMEEEEd(localeName);
    final String dateString = dateDateFormat.format(date);

    return '今天是 $dateString';
  }

  @override
  String price(double value) {
    final intl.NumberFormat valueNumberFormat = intl.NumberFormat.simpleCurrency(locale: localeName, decimalDigits: 2);
    final String valueString = valueNumberFormat.format(value);

    return '价格：$valueString';
  }

  @override
  String get themeMode => '主题模式';

  @override
  String get themeSystem => '跟随系统';

  @override
  String get themeLight => '浅色';

  @override
  String get themeDark => '深色';

  @override
  String get language => '语言';

  @override
  String get languageSystem => '跟随系统';
}
