class NewsApiConfig {
  NewsApiConfig._();

  static const defaultUrl =
      'https://newsapi.org/v2/everything?q=financas+OR+economia&language=pt&sortBy=publishedAt&pageSize=15';

  static String get url {
    const fromEnv = String.fromEnvironment('NEWS_API_URL', defaultValue: '');
    return fromEnv.isNotEmpty ? fromEnv : defaultUrl;
  }

  static String get apiKey =>
      const String.fromEnvironment('NEWS_API_KEY', defaultValue: '');

  static bool get isConfigured => apiKey.isNotEmpty;
}
