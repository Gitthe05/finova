# API Finova acessível de qualquer rede

O app **só** fala com a API Finova (`API_BASE_URL`). Notícias, login e sync passam por ela.

O IP `192.168.x.x:3000` do Mac **só funciona na mesma Wi‑Fi**. Para celular em 4G, outra casa ou sem o PC ligado, a API precisa estar **na internet**.

## Arquitetura

```
Celular (qualquer rede)
    → https://api.seudominio.com/financial-news
    → API Finova (NestJS na nuvem)
    → NewsAPI (chave só no servidor)
```

## 1. Publicar o backend

Opções comuns (escolha uma):

| Serviço | Observação |
|---------|------------|
| [Railway](https://railway.app) | Postgres + Node, deploy rápido |
| [Render](https://render.com) | Web Service + Postgres free tier |
| [Fly.io](https://fly.io) | Docker, bom para NestJS |
| VPS (DigitalOcean, etc.) | `docker compose` + domínio |

### Variáveis obrigatórias no servidor

```env
DATABASE_URL=postgresql://...
JWT_SECRET=...
PORT=3000
NEWS_API_KEY=...
NEWS_API_URL=https://newsapi.org/v2/everything?q=financas+OR+economia&language=pt&sortBy=publishedAt&pageSize=10
```

Use **HTTPS** na URL pública (certificado do provedor ou Cloudflare).

### Teste após deploy

```bash
curl https://SUA-URL/financial-news
```

Deve retornar JSON com `items`.

## 2. Gerar APK apontando para a API pública

```bash
cd mobile
cp .env.build.example .env.build
# Edite .env.build: API_BASE_URL=https://sua-url-real.com
bash scripts/build-android-apk.sh
```

Ou em uma linha:

```bash
API_BASE_URL=https://sua-api.exemplo.com bash scripts/build-android-apk.sh
```

## 3. Notícias com backend fora

Mesmo sem a API Finova, o app tenta:

1. **NewsAPI** direto (chave em `NEWS_API_KEY` no build do APK)
2. **RSS** financeiro (G1 Economia, InfoMoney) — funciona no celular
3. Dicas curadas FINOVA

## 4. O que funciona sem a API Finova

| Recurso | Sem API Finova no ar |
|---------|----------------------|
| Transações locais (SQLite) | Sim |
| Login / cadastro | Não |
| Notícias reais | Sim (NewsAPI ou RSS no app) |
| Sync na nuvem | Não |

## Desenvolvimento local (mesma rede)

Sem `.env.build`, o script usa o IP do Mac na LAN:

```bash
bash scripts/build-android-apk.sh
# → API_BASE_URL=http://192.168.x.x:3000
```
