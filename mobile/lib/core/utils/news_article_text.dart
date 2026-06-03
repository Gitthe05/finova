String pickNewsArticleBody(String? description, String? content) {
  String clean(String? value) {
    if (value == null || value.isEmpty) return '';
    return value
        .replaceAll(RegExp(r'\[\+\d+\s*chars\]$', caseSensitive: false), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  final candidates = [clean(content), clean(description)].where((s) => s.isNotEmpty).toList();
  if (candidates.isEmpty) return '';
  return candidates.reduce((a, b) => b.length > a.length ? b : a);
}
