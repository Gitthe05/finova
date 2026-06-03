import 'package:flutter/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';

abstract final class AppSymbolsManifest {
  static const List<IconData> glyphs = [
    Symbols.home,
    Symbols.payments,
    Symbols.grid_view,
    Symbols.article,
    Symbols.person,
    Symbols.mail,
    Symbols.lock,
    Symbols.search,
    Symbols.filter_list,
    Symbols.delete_outline,
    Symbols.chevron_right,
    Symbols.refresh_rounded,
    Symbols.arrow_downward_alt,
    Symbols.arrow_upward_alt,
    Symbols.arrow_downward,
    Symbols.arrow_upward,
    Symbols.lightbulb,
    Symbols.add,
    Symbols.face,
    Symbols.check_circle,
    Symbols.error,
    Symbols.warning,
    Symbols.info,
    Symbols.check,
    Symbols.keyboard_arrow_down,
    Symbols.account_balance_wallet,
    Symbols.phone_android,
    Symbols.school,
    Symbols.open_in_new,
    Symbols.close,
    Symbols.verified_user,
    Symbols.palette,
    Symbols.calendar_month,
    Symbols.logout,
    Symbols.encrypted,
    Symbols.storage,
    Symbols.light_mode,
    Symbols.dark_mode,
    Symbols.work,
    Symbols.trending_up,
    Symbols.restaurant,
    Symbols.directions_car,
    Symbols.celebration,
    Symbols.subscriptions,
    Symbols.category,
    Symbols.delete,
    Symbols.inbox,
  ];

  @pragma('vm:entry-point')
  static void pinGlyphsForRelease() {
    Symbols.forceCompileTimeTreeShaking();
    if (glyphs.isEmpty) return;
  }
}
