import '../../domain/entities/news_item.dart';
import '../../domain/repositories/news_repository.dart';
import '../datasources/remote/direct_news_datasource.dart';
import '../datasources/remote/remote_news_datasource.dart';
import '../datasources/remote/rss_news_datasource.dart';

class NewsRepositoryImpl implements NewsRepository {
  NewsRepositoryImpl(
    this._finovaApi,
    this._directNewsApi,
    this._rssNews,
  );

  final RemoteNewsDataSource _finovaApi;
  final DirectNewsDataSource _directNewsApi;
  final RssNewsDataSource _rssNews;

  static List<NewsItem> get _curatedFallback {
    final now = DateTime.now().toIso8601String();
    return [
      NewsItem(
        id: '1',
        title: 'Dicas para organizar suas finanças pessoais',
        description:
            'Separe gastos fixos e variáveis, defina metas mensais e revise seu orçamento toda semana.',
        source: 'FINOVA',
        url: 'https://www.bcb.gov.br/',
        publishedAt: now,
      ),
      NewsItem(
        id: '2',
        title: 'Reserva de emergência: por onde começar',
        description:
            'Especialistas recomendam guardar de 3 a 6 meses de despesas essenciais antes de investir.',
        source: 'FINOVA',
        url: 'https://www.gov.br/economia',
        publishedAt: now,
      ),
      NewsItem(
        id: '3',
        title: 'Inflação e planejamento de longo prazo',
        description:
            'Acompanhe indicadores econômicos e ajuste suas metas de poupança periodicamente.',
        source: 'FINOVA',
        url: 'https://www.ibge.gov.br/',
        publishedAt: now,
      ),
    ];
  }

  @override
  Future<List<NewsItem>> getFinancialNews() async {
    try {
      final items = await _finovaApi.fetch();
      if (items.isNotEmpty) return items.map((e) => e.toEntity()).toList();
    } catch (_) {}

    final deviceNews = await _fetchFromDevice();
    if (deviceNews != null) return deviceNews;

    return _curatedFallback;
  }

  Future<List<NewsItem>?> _fetchFromDevice() async {
    if (_directNewsApi.isConfigured) {
      try {
        final items = await _directNewsApi.fetch();
        if (items.isNotEmpty) {
          return items.map((e) => e.toEntity()).toList();
        }
      } catch (_) {}
    }

    try {
      final items = await _rssNews.fetch();
      if (items.isNotEmpty) {
        return items.map((e) => e.toEntity()).toList();
      }
    } catch (_) {}

    return null;
  }
}
