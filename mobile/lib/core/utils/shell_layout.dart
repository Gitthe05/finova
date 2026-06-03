import 'package:flutter/material.dart';
import '../theme/app_tokens.dart';

EdgeInsets shellListPadding(BuildContext context) {
  return EdgeInsets.fromLTRB(
    AppTokens.spaceMd,
    AppTokens.spaceMd,
    AppTokens.spaceMd,
    AppTokens.spaceLg,
  );
}

double shellBottomInset(BuildContext context) {
  return AppTokens.spaceSm;
}
