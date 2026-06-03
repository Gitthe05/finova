import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';
import 'core/icons/app_symbols_manifest.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_controller.dart';

void _ensureWebViewPlatform() {
  if (WebViewPlatform.instance != null || kIsWeb) return;
  if (Platform.isAndroid) {
    AndroidWebViewPlatform.registerWith();
  } else if (Platform.isIOS || Platform.isMacOS) {
    WebKitWebViewPlatform.registerWith();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppSymbolsManifest.pinGlyphsForRelease();
  _ensureWebViewPlatform();
  await initializeDateFormatting('pt_BR');
  Intl.defaultLocale = 'pt_BR';

  final container = ProviderContainer();
  await container.read(themeModeProvider.notifier).ensureInitialized();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const FinovaApp(),
    ),
  );
}

class FinovaApp extends ConsumerWidget {
  const FinovaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'FINOVA',
      debugShowCheckedModeBanner: false,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
