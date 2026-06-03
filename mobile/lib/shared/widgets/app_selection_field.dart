import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../core/theme/app_surface_colors.dart';
import '../../core/theme/app_tokens.dart';

class AppSelectionField<T> extends StatelessWidget {
  const AppSelectionField({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.itemLabel,
    this.sheetTitle,
  });

  final String label;
  final T value;
  final List<T> items;
  final ValueChanged<T> onChanged;
  final String Function(T item)? itemLabel;
  final String? sheetTitle;

  String _labelFor(T item) => itemLabel?.call(item) ?? item.toString();

  Future<void> _openSheet(BuildContext context) async {
    final surfaces = context.surfaces;
    final accent = context.accentHighlight;

    final selected = await showModalBottomSheet<T>(
      context: context,
      backgroundColor: surfaces.card,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTokens.radius2xl)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTokens.spaceLg,
            AppTokens.spaceSm,
            AppTokens.spaceLg,
            AppTokens.spaceLg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: surfaces.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppTokens.spaceMd),
              Text(
                sheetTitle ?? label,
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppTokens.spaceSm),
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: items.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: surfaces.border,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    final isSelected = item == value;
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                      title: Text(
                        _labelFor(item),
                        style: Theme.of(ctx).textTheme.bodyLarge?.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected ? accent : surfaces.textPrimary,
                            ),
                      ),
                      trailing: isSelected
                          ? Icon(Symbols.check, color: accent, size: 22)
                          : null,
                      onTap: () => Navigator.pop(ctx, item),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );

    if (selected != null) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: surfaces.textPrimary,
              ),
        ),
        const SizedBox(height: 6),
        Material(
          color: surfaces.inputFill,
          borderRadius: BorderRadius.circular(AppTokens.radiusMd),
          child: InkWell(
            onTap: () => _openSheet(context),
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppTokens.radiusMd),
                border: Border.all(color: surfaces.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _labelFor(value),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: surfaces.textPrimary,
                          ),
                    ),
                  ),
                  Icon(
                    Symbols.keyboard_arrow_down,
                    color: surfaces.textMuted,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
