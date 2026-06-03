import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/shell_layout.dart';
import '../widgets/news_detail_sheet.dart';
import '../../../core/utils/view_status.dart';
import '../../../domain/entities/news_item.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/premium_card.dart';
import '../viewmodel/news_state.dart';
import '../viewmodel/news_view_model.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({super.key});

  @override
  ConsumerState<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends ConsumerState<NewsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(newsViewModelProvider.notifier).load());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(newsViewModelProvider);
    final vm = ref.read(newsViewModelProvider.notifier);
    final padding = shellListPadding(context);

    return ColoredBox(
      color: context.surfaces.screenTint,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                padding.left,
                AppTokens.spaceSm,
                padding.right,
                AppTokens.spaceSm,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Notícias',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: vm.load,
                    icon: const Icon(Symbols.refresh_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: context.surfaces.card,
                      side: BorderSide(color: context.surfaces.border),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: AppColors.accent,
                onRefresh: vm.load,
                child: _body(state, vm, padding),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _body(NewsState state, NewsViewModel vm, EdgeInsets padding) {
    if (state.status == ViewStatus.loading) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: const [
          SizedBox(height: 100, child: Card()),
          SizedBox(height: 12),
          SizedBox(height: 100, child: Card()),
        ],
      );
    }
    if (state.status == ViewStatus.error) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: [
          ErrorState(
            message: state.errorMessage ?? 'Não foi possível carregar as notícias',
            onRetry: vm.load,
          ),
        ],
      );
    }
    if (state.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: padding,
        children: const [
          EmptyState(
            title: 'Nenhuma notícia disponível',
            subtitle: 'Tente novamente em instantes',
          ),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: padding,
      itemCount: state.items.length,
      itemBuilder: (context, index) {
        final item = state.items[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTokens.spaceMd),
          child: _NewsCard(item: item),
        ).animate().fadeIn(delay: (40 * index).ms);
      },
    );
  }
}

class _NewsCard extends StatelessWidget {
  const _NewsCard({required this.item});

  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: const EdgeInsets.all(AppTokens.spaceMd),
      onTap: () => showNewsDetailSheet(context, item),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTokens.radiusSm),
            ),
            child: const Icon(Symbols.article, color: AppColors.teal, size: 22),
          ),
          const SizedBox(width: AppTokens.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.source,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.teal,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: context.surfaces.textSecondary,
                        height: 1.35,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTokens.spaceSm),
          Icon(
            Symbols.chevron_right,
            size: 22,
            color: context.surfaces.textMuted,
          ),
        ],
      ),
    );
  }
}
