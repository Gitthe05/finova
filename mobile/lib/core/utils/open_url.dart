import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../shared/widgets/app_toast.dart';

Future<void> openExternalUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url.trim());
  if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
    if (context.mounted) {
      showAppToast(
        context,
        message: 'Link da notícia inválido.',
        variant: AppToastVariant.error,
      );
    }
    return;
  }

  try {
    final launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && context.mounted) {
      showAppToast(
        context,
        message: 'Não foi possível abrir o link.',
        variant: AppToastVariant.error,
      );
    }
  } catch (_) {
    if (context.mounted) {
      showAppToast(
        context,
        message: 'Não foi possível abrir o link.',
        variant: AppToastVariant.error,
      );
    }
  }
}
