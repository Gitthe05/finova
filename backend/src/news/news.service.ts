import { Injectable, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

export type FinancialNewsItem = {
  id: string;
  title: string;
  description: string;
  source: string;
  url: string;
  publishedAt: string;
  imageUrl?: string;
};

export type NewsFallbackReason =
  | 'not_configured'
  | 'invalid_key'
  | 'api_error'
  | 'empty';

const FALLBACK_NEWS: FinancialNewsItem[] = [
  {
    id: '1',
    title: 'Dicas para organizar suas finanças pessoais',
    description:
      'Separe gastos fixos e variáveis, defina metas mensais e revise seu orçamento toda semana.',
    source: 'FINOVA',
    url: 'https://www.bcb.gov.br/',
    publishedAt: new Date().toISOString(),
  },
  {
    id: '2',
    title: 'Reserva de emergência: por onde começar',
    description:
      'Especialistas recomendam guardar de 3 a 6 meses de despesas essenciais antes de investir.',
    source: 'FINOVA',
    url: 'https://www.gov.br/economia',
    publishedAt: new Date().toISOString(),
  },
  {
    id: '3',
    title: 'Inflação e planejamento de longo prazo',
    description:
      'Acompanhe indicadores econômicos e ajuste suas metas de poupança periodicamente.',
    source: 'FINOVA',
    url: 'https://www.ibge.gov.br/',
    publishedAt: new Date().toISOString(),
  },
];

function pickArticleBody(description?: string, content?: string): string {
  const clean = (value?: string) => {
    if (!value) return '';
    return value
      .replace(/\[\+\d+\s*chars\]$/i, '')
      .replace(/\s+/g, ' ')
      .trim();
  };
  const candidates = [clean(content), clean(description)].filter(Boolean);
  if (candidates.length === 0) return '';
  return candidates.reduce((a, b) => (b.length > a.length ? b : a));
}

@Injectable()
export class NewsService {
  private readonly logger = new Logger(NewsService.name);

  constructor(private readonly config: ConfigService) {}

  private env(key: string): string | undefined {
    const raw = this.config.get<string>(key);
    if (!raw) return undefined;
    const trimmed = raw.trim();
    if (!trimmed) return undefined;
    return trimmed.replace(/^["']|["']$/g, '');
  }

  async getFinancialNews(): Promise<{
    items: FinancialNewsItem[];
    fromCache: boolean;
    fallback: boolean;
    fallbackReason?: NewsFallbackReason;
  }> {
    const apiKey = this.env('NEWS_API_KEY');
    const apiUrl = this.env('NEWS_API_URL');

    if (!apiKey || !apiUrl) {
      return {
        items: FALLBACK_NEWS,
        fromCache: false,
        fallback: true,
        fallbackReason: 'not_configured',
      };
    }

    try {
      const separator = apiUrl.includes('?') ? '&' : '?';
      const url = `${apiUrl}${separator}apiKey=${apiKey}`;
      const res = await fetch(url, { signal: AbortSignal.timeout(8000) });
      const data = (await res.json()) as {
        status?: string;
        code?: string;
        message?: string;
        articles?: Array<{
          title?: string;
          description?: string;
          content?: string;
          source?: { name?: string };
          url?: string;
          publishedAt?: string;
          urlToImage?: string;
        }>;
      };

      if (!res.ok || data.status === 'error') {
        const reason: NewsFallbackReason =
          data.code === 'apiKeyInvalid' ? 'invalid_key' : 'api_error';
        this.logger.warn(
          `News API error: ${data.message ?? res.status} (${data.code ?? 'unknown'})`,
        );
        return {
          items: FALLBACK_NEWS,
          fromCache: false,
          fallback: true,
          fallbackReason: reason,
        };
      }

      const items: FinancialNewsItem[] = (data.articles ?? [])
        .filter((a) => a.title && a.url)
        .slice(0, 15)
        .map((a, i) => ({
          id: String(i),
          title: a.title!,
          description: pickArticleBody(a.description, a.content),
          source: a.source?.name ?? 'Notícias',
          url: a.url!,
          publishedAt: a.publishedAt ?? new Date().toISOString(),
          imageUrl: a.urlToImage,
        }));

      if (items.length === 0) {
        return {
          items: FALLBACK_NEWS,
          fromCache: false,
          fallback: true,
          fallbackReason: 'empty',
        };
      }

      return { items, fromCache: false, fallback: false };
    } catch (err) {
      this.logger.warn(`News API failed: ${err}`);
      return {
        items: FALLBACK_NEWS,
        fromCache: false,
        fallback: true,
        fallbackReason: 'api_error',
      };
    }
  }
}
