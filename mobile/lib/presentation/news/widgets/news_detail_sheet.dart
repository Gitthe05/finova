import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_surface_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/open_url.dart';
import '../../../domain/entities/news_item.dart';

final Set<Factory<OneSequenceGestureRecognizer>> _webViewGestureRecognizers = {
  Factory<VerticalDragGestureRecognizer>(VerticalDragGestureRecognizer.new),
  Factory<HorizontalDragGestureRecognizer>(HorizontalDragGestureRecognizer.new),
  Factory<ScaleGestureRecognizer>(ScaleGestureRecognizer.new),
  Factory<TapGestureRecognizer>(TapGestureRecognizer.new),
};

Future<void> showNewsDetailSheet(BuildContext context, NewsItem item) {
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (ctx) => _NewsArticlePage(item: item),
    ),
  );
}

class _NewsArticlePage extends StatefulWidget {
  const _NewsArticlePage({required this.item});

  final NewsItem item;

  @override
  State<_NewsArticlePage> createState() => _NewsArticlePageState();
}

class _NewsArticlePageState extends State<_NewsArticlePage> {
  late final WebViewController _webController;
  var _loading = true;
  var _webFailed = false;
  var _pageLoaded = false;

  @override
  void initState() {
    super.initState();
    final uri = Uri.tryParse(widget.item.url.trim());

    if (kIsWeb || WebViewPlatform.instance == null) {
      _loading = false;
      _webFailed = true;
      _webController = WebViewController();
      return;
    }

    late final PlatformWebViewControllerCreationParams params;
    if (WebViewPlatform.instance is WebKitWebViewPlatform) {
      params = WebKitWebViewControllerCreationParams(
        allowsInlineMediaPlayback: true,
      );
    } else {
      params = const PlatformWebViewControllerCreationParams();
    }

    _webController = WebViewController.fromPlatformCreationParams(params)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _loading = true;
                _webFailed = false;
              });
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() {
                _loading = false;
                _pageLoaded = true;
              });
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == false) return;
            if (_pageLoaded || !mounted) return;
            setState(() {
              _loading = false;
              _webFailed = true;
            });
          },
          onNavigationRequest: (request) {
            final target = Uri.tryParse(request.url);
            if (target == null) return NavigationDecision.prevent;
            if (target.scheme == 'http' || target.scheme == 'https') {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
        ),
      );

    if (!kIsWeb &&
        Platform.isAndroid &&
        _webController.platform is AndroidWebViewController) {
      final android = _webController.platform as AndroidWebViewController;
      AndroidWebViewController.enableDebugging(false);
      android.setMediaPlaybackRequiresUserGesture(true);
    }

    if (uri != null && (uri.scheme == 'http' || uri.scheme == 'https')) {
      _webController.loadRequest(uri);
    } else {
      _loading = false;
      _webFailed = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    final item = widget.item;
    final published = DateTime.tryParse(item.publishedAt);
    final dateLabel = published != null
        ? AppFormatters.dateTime.format(published.toLocal())
        : null;
    final summary = _plainText(item.description);

    return Scaffold(
      backgroundColor: surfaces.card,
      appBar: AppBar(
        backgroundColor: surfaces.card,
        foregroundColor: surfaces.textPrimary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.source,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.teal,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            if (dateLabel != null)
              Text(
                dateLabel,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: surfaces.textMuted,
                    ),
              ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () => openExternalUrl(context, item.url),
            icon: const Icon(Symbols.open_in_new, size: 22),
            tooltip: 'Abrir no navegador',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTokens.spaceLg,
              0,
              AppTokens.spaceLg,
              AppTokens.spaceSm,
            ),
            child: Text(
              item.title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
            ),
          ),
          Expanded(
            child: _webFailed
                ? _FallbackReader(summary: summary, item: item)
                : Stack(
                    children: [
                      WebViewWidget(
                        controller: _webController,
                        gestureRecognizers: _webViewGestureRecognizers,
                      ),
                      if (_loading)
                        ColoredBox(
                          color: surfaces.card,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(strokeWidth: 2),
                                const SizedBox(height: AppTokens.spaceMd),
                                Text(
                                  'Carregando matéria…',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: surfaces.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _FallbackReader extends StatelessWidget {
  const _FallbackReader({required this.summary, required this.item});

  final String summary;
  final NewsItem item;

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaces;
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTokens.spaceLg,
        0,
        AppTokens.spaceLg,
        AppTokens.spaceMd,
      ),
      children: [
        if (item.imageUrl != null && item.imageUrl!.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTokens.radiusMd),
            child: Image.network(
              item.imageUrl!,
              fit: BoxFit.cover,
              width: double.infinity,
              height: 160,
              errorBuilder: (context, error, stackTrace) =>
                  const SizedBox.shrink(),
            ),
          ),
          const SizedBox(height: AppTokens.spaceMd),
        ],
        Text(
          summary.isNotEmpty
              ? summary
              : 'Não foi possível carregar a página completa neste aparelho.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: surfaces.textSecondary,
                height: 1.55,
              ),
        ),
        const SizedBox(height: AppTokens.spaceMd),
        Text(
          'Use o ícone no topo para abrir a matéria no site original.',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: surfaces.textMuted,
              ),
        ),
      ],
    );
  }
}

String _plainText(String raw) {
  return raw
      .replaceAll(RegExp(r'<[^>]*>'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}
