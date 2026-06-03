import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:material_symbols_icons/symbols.dart';

IconData categoryIconForKey(String iconKey) {
  switch (iconKey) {
    case 'payments':
      return Symbols.payments;
    case 'work':
      return Symbols.work;
    case 'trending_up':
      return Symbols.trending_up;
    case 'restaurant':
      return Symbols.restaurant;
    case 'directions_car':
      return Symbols.directions_car;
    case 'home':
      return Symbols.home;
    case 'health':
      return FontAwesomeIcons.heartPulse;
    case 'celebration':
      return Symbols.celebration;
    case 'school':
      return Symbols.school;
    case 'subscriptions':
      return Symbols.subscriptions;
    default:
      return Symbols.category;
  }
}
