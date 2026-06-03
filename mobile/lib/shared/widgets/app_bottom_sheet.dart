import 'package:flutter/material.dart';
import '../../core/theme/app_surface_colors.dart';
import '../../core/theme/app_tokens.dart';

Future<T?> showAppBottomSheet<T>(BuildContext context, {required Widget child}) {
  final surfaces = context.surfaces;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: surfaces.card,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radius2xl)),
    ),
    builder: (ctx) {
      final bottomInset = MediaQuery.viewInsetsOf(ctx).bottom;
      return Padding(
        padding: EdgeInsets.only(bottom: bottomInset),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: AppTokens.spaceSm),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: surfaces.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppTokens.spaceSm),
              child,
            ],
          ),
        ),
      );
    },
  );
}
