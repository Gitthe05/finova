import 'package:flutter/material.dart';
import 'premium_card.dart';

class AppCard extends StatelessWidget {
  const AppCard({super.key, required this.child, this.padding, this.onTap});

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(padding: padding, onTap: onTap, child: child);
  }
}
