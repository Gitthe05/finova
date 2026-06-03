import 'package:flutter/material.dart';
import 'finova_logo.dart';

class BrandLogo extends StatelessWidget {
  const BrandLogo({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return FinovaLogo(
      size: compact ? 40 : 44,
      showName: true,
      showTagline: !compact,
    );
  }
}
