# Docker — Finova

O projeto usa **PostgreSQL** via `docker-compose.yml` na raiz.

## Opção A: Colima (recomendado no Mac, já configurado)

Colima substitui o Docker Desktop e não exige senha de administração para atualizar.

```bash
# Iniciar o motor Docker (após reiniciar o Mac)
colima start

# Subir o banco
cd ~/Workspace/finova
docker compose up -d

# Verificar
docker compose ps
```

Parar o banco:

```bash
docker compose down
```

Parar o Colima:

```bash
colima stop
```

Iniciar Colima automaticamente no login (opcional):

```bash
brew services start colima
```

## Opção B: Docker Desktop

1. Instale: [Docker Desktop para Mac (Apple Silicon)](https://docs.docker.com/desktop/setup/install/mac-install/)
2. Abra o app **Docker** e aguarde ficar “Running”.
3. Na raiz do projeto:

```bash
cd ~/Workspace/finova
docker compose up -d
```

> Se o `brew install --cask docker` pedir senha de administrador, use o instalador do site ou conclua o upgrade no Terminal com sua senha.

## Credenciais do PostgreSQL

| Campo    | Valor            |
|----------|------------------|
| Host     | `localhost`      |
| Porta    | `5433` (host) → `5432` (container) |
| Usuário  | `postgres`       |
| Senha    | `postgres`       |
| Banco    | `finova`|

Deve bater com `backend/.env`:

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5433/finova?schema=public"
```

## Backend após o Docker

```bash
cd backend
npm install
npx prisma migrate dev
npm run start:dev
```

API: http://localhost:3000  
Swagger: http://localhost:3000/api/docs

## Problemas comuns

### `docker: command not found`

Reabra o terminal ou rode:

```bash
export PATH="/opt/homebrew/bin:$PATH"
```

### `docker-credential-desktop: executable file not found`

Remova `"credsStore": "desktop"` de `~/.docker/config.json` (já corrigido se usou Colima).

### Porta em uso

O compose usa **5433** no Mac para não conflitar com Postgres instalado via Homebrew (5432).

```bash
docker compose down
docker compose up -d
```
