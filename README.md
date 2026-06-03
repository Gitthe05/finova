# Finova

**Aplicativo de controle financeiro pessoal** desenvolvido para apresentação acadêmica e uso real.

| Item | Detalhe |
|------|---------|
| **Frontend** | Flutter (Dart) — MVVM + Clean Architecture + Riverpod |
| **Backend** | NestJS (TypeScript) — API REST + JWT |
| **Banco** | PostgreSQL (Docker) + SQLite no app (modo offline) |
| **Produto** | Finova — controle financeiro pessoal |
| **Disciplina / Instituição** | *(preencher)* |

### Por onde começar?

| Situação | Vá para |
|----------|---------|
| **Nunca instalei nada** (sem Git, Node, Flutter, Docker) | **Seção 4** — instalação completa Mac / Linux / Windows |
| **Já tenho tudo instalado** | **Seção 5** (conferir) → **Seção 7** (rodar o projeto) |
| **Só quero subir o banco** | **Seção 6** + [docs/DOCKER.md](docs/DOCKER.md) |

---

## 1. O que o sistema faz

- Cadastro e login com validação e sessão segura
- Dashboard com saldo, receitas, despesas e resumo mensal
- CRUD de transações (receita/despesa) com categorias e filtros
- Persistência local (SQLite) e sincronização com API quando disponível
- Feed de notícias: API Finova → fallback NewsAPI/RSS direto no app → dicas curadas
- Interface Material Design 3, inspirada em apps fintech modernos

---

## 2. Arquitetura (visão para o professor)

```txt
finova/
├── mobile/                 # App Flutter (MVVM)
│   └── lib/
│       ├── presentation/   # Telas + ViewModels
│       ├── domain/         # Entidades + Use Cases
│       └── data/           # SQLite + API + Repositories
├── backend/                # API NestJS
│   ├── src/auth|transactions|news/
│   └── prisma/             # Schema PostgreSQL
├── docker-compose.yml      # Banco PostgreSQL
├── docs/DOCKER.md          # Detalhes do Docker
└── README.md               # Este arquivo
```

### Padrão MVVM no Flutter

| Camada | Função |
|--------|--------|
| **View** | Telas e widgets — apenas exibe estado |
| **ViewModel** | Estados (`loading`, `success`, `error`, etc.) e validações |
| **UseCase** | Regras de negócio |
| **Repository** | Abstração de dados (local + remoto) |

### Backend

Módulos: `auth`, `transactions`, `news` — com Prisma, Swagger, Helmet, rate limit, Bcrypt e JWT.

---

## 3. Tecnologias utilizadas

| Área | Stack |
|------|--------|
| Mobile | Flutter, Riverpod, sqflite, go_router, flutter_secure_storage |
| API | Node.js 20+, NestJS, TypeScript, Prisma 5 |
| Banco servidor | PostgreSQL 16 (Docker) |
| Banco local | SQLite (sqflite) |
| Segurança | JWT, Bcrypt, hash local de senha, Secure Storage |
| Docs API | Swagger em `/api/docs` |

---

## 4. Instalação do zero (Mac, Linux e Windows)

> **Leia esta seção primeiro** se o computador ainda **não tem** Git, Node, Flutter nem Docker.  
> Tempo estimado na primeira vez: **1h30 a 3h** (download + instalação + `flutter doctor`).

### O que você vai instalar (e para quê)

| Ferramenta | Versão mínima | Usada para |
|------------|---------------|------------|
| **Git** | recente | Baixar/atualizar o projeto |
| **Node.js** | 20 LTS | API NestJS (`backend/`) |
| **Flutter** | 3.11+ | App mobile (`mobile/`) — já inclui o Dart |
| **Docker** | recente | PostgreSQL em container |
| **Android Studio** | recente | Emulador Android (recomendado em qualquer SO) |
| **Xcode** | recente | Simulador iOS (**somente Mac**) |

Ordem sugerida: **Git → Node.js → Docker → Flutter → Android Studio** (Xcode no Mac se for testar no iPhone/simulador).

### Abrir o terminal

| Sistema | Como abrir |
|---------|------------|
| **macOS** | `Cmd + Espaço` → digite **Terminal** → Enter |
| **Linux** | `Ctrl + Alt + T` ou menu **Terminal** |
| **Windows** | `Win` → digite **PowerShell** ou **Terminal** → Enter |

Nos comandos abaixo, cole linha a linha e pressione **Enter**. Se pedir senha, é a do seu usuário no computador.

---

### 4.1 macOS (Intel ou Apple Silicon M1/M2/M3)

#### Passo A — Homebrew (gerenciador de pacotes)

O Homebrew facilita instalar quase tudo no Mac.

1. Abra o **Terminal**
2. Cole o comando da página oficial: [brew.sh](https://brew.sh/) (começa com `/bin/bash -c "$(curl ...)"`)
3. Siga as instruções na tela até terminar
4. Teste:

```bash
brew --version
```

#### Passo B — Git

```bash
brew install git
git --version
```

*(Alternativa: instalar **Xcode Command Line Tools** com `xcode-select --install` — também traz o Git.)*

#### Passo C — Node.js 20 LTS

**Opção 1 — Homebrew (recomendado):**

```bash
brew install node@20
brew link node@20 --force --overwrite
node -v    # deve mostrar v20.x
npm -v
```

**Opção 2 — Instalador gráfico:** baixe em [nodejs.org](https://nodejs.org/) (versão **LTS**), abra o `.pkg` e conclua o assistente.

#### Passo D — Docker (banco PostgreSQL)

Escolha **uma** opção:

**Opção D1 — Colima (leve, recomendado no Mac):**

```bash
brew install colima docker docker-compose
colima start
docker --version
docker compose version
```

**Opção D2 — Docker Desktop:**

1. Baixe: [Docker Desktop para Mac](https://docs.docker.com/desktop/setup/install/mac-install/) (escolha **Apple Chip** ou **Intel** conforme seu Mac)
2. Instale, abra o app e aguarde **“Docker is running”**
3. No Terminal: `docker --version`

Detalhes e erros comuns: **[docs/DOCKER.md](docs/DOCKER.md)**

#### Passo E — Flutter

**Opção 1 — Homebrew:**

```bash
brew install --cask flutter
flutter --version
```

**Opção 2 — Site oficial:**

1. [docs.flutter.dev/get-started/install/macos](https://docs.flutter.dev/get-started/install/macos)
2. Baixe o SDK, extraia (ex.: `~/development/flutter`)
3. Adicione ao PATH no `~/.zshrc`:

```bash
export PATH="$PATH:$HOME/development/flutter/bin"
```

4. Feche e abra o Terminal, depois: `flutter --version`

#### Passo F — Android Studio (emulador Android)

1. [developer.android.com/studio](https://developer.android.com/studio) → baixe para Mac
2. Instale com as opções padrão (**Android SDK**, **Android Virtual Device**)
3. Abra o Android Studio → **More Actions** → **SDK Manager** → instale **Android SDK Platform** recente
4. **Device Manager** → **Create device** → escolha um telefone (ex. Pixel 7) → baixe uma imagem do sistema → **Finish**
5. No Terminal:

```bash
flutter doctor
flutter doctor --android-licenses   # digite y para aceitar
```

#### Passo G — Xcode (somente se for rodar no simulador iOS)

1. App Store → instale **Xcode** (é grande, pode demorar)
2. Abra o Xcode uma vez e aceite a licença
3. No Terminal:

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
flutter doctor
```

---

### 4.2 Linux (Ubuntu / Debian e similares)

> Em **Fedora**, troque `apt` por `dnf`. Em **Arch**, use `pacman`. Os nomes dos pacotes podem variar levemente.

#### Passo A — Atualizar o sistema e instalar base

```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y curl git unzip xz-utils zip libglu1-mesa clang cmake ninja-build pkg-config libgtk-3-dev
```

#### Passo B — Git

```bash
git --version
```

*(Se não existir: `sudo apt install -y git`)*

#### Passo C — Node.js 20 LTS

**Opção 1 — NodeSource (recomendado):**

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
node -v
npm -v
```

**Opção 2 — NVM** (útil se você mantém vários projetos): [github.com/nvm-sh/nvm](https://github.com/nvm-sh/nvm)

#### Passo D — Docker

```bash
sudo apt install -y docker.io docker-compose-v2
sudo systemctl enable --now docker
sudo usermod -aG docker $USER
```

**Importante:** feche o Terminal, abra de novo (ou faça logout/login) para o grupo `docker` valer.

```bash
docker --version
docker compose version
```

*(Em distribuições recentes o comando é `docker compose`, não `docker-compose`.)*

#### Passo E — Flutter

```bash
cd ~
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$PATH:$HOME/flutter/bin"' >> ~/.bashrc
source ~/.bashrc
flutter --version
```

Guia oficial: [docs.flutter.dev/get-started/install/linux](https://docs.flutter.dev/get-started/install/linux)

#### Passo F — Android Studio

1. Baixe o `.tar.gz` em [developer.android.com/studio](https://developer.android.com/studio)
2. Extraia e execute `bin/studio.sh`
3. Instale SDK + crie um emulador (igual ao macOS, passo F acima)
4. `flutter doctor` e `flutter doctor --android-licenses`

**Emulador no Linux:** ative virtualização (VT-x/AMD-V) na BIOS; em algumas máquinas é preciso `sudo apt install qemu-kvm`.

---

### 4.3 Windows 10 / 11

#### Passo A — Git

1. [git-scm.com/download/win](https://git-scm.com/download/win)
2. Execute o instalador — pode deixar as opções **padrão**
3. Abra **PowerShell** ou **Terminal**:

```powershell
git --version
```

#### Passo B — Node.js 20 LTS

1. [nodejs.org](https://nodejs.org/) → baixe **LTS**
2. Instale marcando **“Add to PATH”**
3. Feche e abra o PowerShell:

```powershell
node -v
npm -v
```

#### Passo C — WSL2 + Docker Desktop (recomendado no Windows)

O Docker no Windows funciona melhor com **WSL2**.

1. PowerShell **como Administrador**:

```powershell
wsl --install
```

2. Reinicie o PC se pedido; na primeira inicialização do Ubuntu/WSL, crie usuário e senha
3. Instale [Docker Desktop para Windows](https://docs.docker.com/desktop/setup/install/windows-install/)
4. Nas configurações do Docker Desktop: ative **Use the WSL 2 based engine**
5. Teste no PowerShell:

```powershell
docker --version
docker compose version
```

> Se `docker` não for reconhecido, reinicie o PC e abra o Docker Desktop até ficar **Running**.

#### Passo D — Flutter

1. [docs.flutter.dev/get-started/install/windows](https://docs.flutter.dev/get-started/install/windows)
2. Baixe o ZIP do SDK, extraia em `C:\src\flutter` (evite pastas com espaço ou acentos)
3. Adicione ao PATH:
   - **Configurações** → **Sistema** → **Sobre** → **Configurações avançadas do sistema**
   - **Variáveis de ambiente** → em **Path** do usuário → **Novo** → `C:\src\flutter\bin`
4. Novo PowerShell:

```powershell
flutter --version
```

#### Passo E — Android Studio

1. [developer.android.com/studio](https://developer.android.com/studio) → instalador `.exe`
2. Instale SDK + **Android Virtual Device**
3. Crie um emulador no **Device Manager**
4. No PowerShell (na pasta do projeto, depois de clonar):

```powershell
flutter doctor
flutter doctor --android-licenses
```

**iOS no Windows:** não é possível compilar para iPhone no Windows; use **emulador Android** ou um **celular Android** via USB.

---

## 5. Conferir se tudo está instalado

Depois da seção 4, rode no Terminal (Mac/Linux) ou PowerShell (Windows):

```bash
git --version
node -v          # v20.x ou superior
npm -v
flutter --version
docker --version
docker compose version
flutter doctor
```

| Resultado | O que fazer |
|-----------|-------------|
| `command not found` / não reconhecido | Volte à seção 4 do seu sistema; reinstale a ferramenta e **reabra** o Terminal |
| `flutter doctor` com ✗ vermelho | Siga a mensagem (licenças Android, Android Studio, Xcode no Mac) |
| Docker não conecta | Mac: `colima start` ou abra Docker Desktop; Windows: abra Docker Desktop |
| Node mostra v18 ou menor | Instale Node **20 LTS** (seção 4) |

Quando `flutter doctor` mostrar pelo menos o **Flutter** e **Android toolchain** OK (ou Xcode no Mac para iOS), siga para a seção 6.

---

## 6. Docker — subir só o banco

O projeto precisa do **PostgreSQL em Docker**. Com Docker já instalado (seção 4):

```bash
cd /caminho/para/finova

# Mac com Colima (se usar):
colima start

docker compose up -d
docker compose ps
```

**Resultado esperado:** serviço `postgres` com status `running`, porta **5433**.

Mais detalhes: **[docs/DOCKER.md](docs/DOCKER.md)**

---

## 7. Passo a passo — rodar localmente

Siga **na ordem**. Você vai usar **até 3 janelas do Terminal** (Mac/Linux) ou **PowerShell/Terminal** (Windows).

> **Windows:** troque `/caminho/para/` por algo como `C:\Users\SeuNome\Desktop\finova`. No PowerShell use `cd C:\Users\SeuNome\Desktop\finova`.

### Passo 0 — Obter o projeto

```bash
# Exemplo: clonar ou descompactar na pasta desejada
cd ~/Desktop/finova
```

*(Ajuste o caminho se a pasta estiver em outro lugar.)*

---

### Passo 1 — Subir o banco (Terminal 1)

```bash
cd /caminho/para/finova

# Se usar Colima e acabou de ligar o Mac:
colima start

docker compose up -d
docker compose ps
```

**Resultado esperado:** serviço `postgres` com status `running`.

O banco fica na porta **5433** (para não conflitar com outro Postgres na 5432).

---

### Passo 2 — Subir a API (Terminal 2)

```bash
cd /caminho/para/finova/backend

# Primeira vez apenas:
cp .env.example .env
npm install
npx prisma migrate dev

# Sempre que for desenvolver:
npm run start:dev
```

**Resultado esperado:** mensagem `API running on http://localhost:3000`.

#### Testar no navegador (professor ou aluna)

> **Atenção:** use a porta **3000**. `http://localhost` sozinho **não** abre a API — a barra deve mostrar `localhost:3000`.

| URL | O que é |
|-----|---------|
| http://localhost:3000/api/docs | **Swagger** — documentação interativa da API |
| http://localhost:3000 | Redireciona para o Swagger |
| http://localhost:3000/financial-news | Exemplo de rota pública (notícias) |

No Swagger é possível testar cadastro (`POST /auth/register`) e login (`POST /auth/login`) sem o app.

**Deixe este Terminal aberto** enquanto usar o aplicativo.

---

### Passo 3 — Rodar o app Flutter (Terminal 3)

```bash
cd /caminho/para/finova/mobile
flutter pub get
```

Conecte um **emulador Android**, **simulador iOS** ou celular via USB, depois:

#### Android (emulador)

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000
```

> No emulador Android, `10.0.2.2` é o “localhost” do seu computador.

#### iOS (simulador Mac)

```bash
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000
```

#### Celular físico (mesma rede Wi‑Fi)

1. Descubra o IP do computador:
   - **Mac:** `ipconfig getifaddr en0` ou **Ajustes → Rede**
   - **Linux:** `hostname -I | awk '{print $1}'`
   - **Windows (PowerShell):** `ipconfig` → procure **Endereço IPv4** da Wi‑Fi
2. Exemplo com IP `192.168.1.50`:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.50:3000
```

---

## 8. Checklist rápido (colar na apresentação)

Use esta ordem na demonstração para o professor:

- [ ] `docker compose ps` → Postgres **running**
- [ ] `npm run start:dev` no `backend/` → API na porta **3000**
- [ ] Abrir **http://localhost:3000/api/docs** → Swagger carrega
- [ ] `flutter run` no `mobile/` → app abre
- [ ] **Cadastrar** um usuário no app
- [ ] **Criar** uma transação (receita ou despesa)
- [ ] Ver **Dashboard** com saldo atualizado
- [ ] Abrir aba **Notícias** (funciona mesmo sem chave de API externa)

---

## 9. Fluxo de uso no aplicativo

1. **Login** ou **Criar conta** (nome, e-mail, senha)
2. **Dashboard** — saldo, receitas, despesas, últimas movimentações
3. **Transações** — botão flutuante **+** → preencher e salvar
4. **Categorias** — lista de categorias de receita e despesa
5. **Notícias** — feed financeiro
6. **Perfil** — dados do usuário e **Sair**

O app funciona **offline** (SQLite) se a API estiver desligada; com a API ligada, os dados sincronizam.

---

## 10. Gerar APK (Android)

Com a API em produção ou para demo só no celular:

```bash
cd mobile
flutter build apk --release --dart-define=API_BASE_URL=http://SEU_IP:3000
```

Arquivo gerado:

```txt
mobile/build/app/outputs/flutter-apk/app-release.apk
```

Instale o APK no Android e use o mesmo IP da máquina onde a API está rodando (mesma rede Wi‑Fi).

---

## 11. Parar tudo ao terminar

```bash
# Terminal do backend: Ctrl + C

# Banco Docker (na pasta do projeto):
docker compose down

# Colima (opcional):
colima stop
```

---

## 12. Problemas comuns

| Problema | Solução |
|----------|---------|
| `docker: command not found` | Instale Docker (seção 4) e reabra o Terminal |
| `User postgres was denied` na migração | Confirme `DATABASE_URL` com porta **5433** em `backend/.env` |
| App não conecta na API | Verifique URL do `--dart-define` (10.0.2.2 Android / 127.0.0.1 iOS) |
| API não sobe | Postgres rodando? `docker compose ps` |
| `flutter doctor` com erros | Instale Android Studio ou Xcode (seção 4) conforme a plataforma |
| Porta 3000 em uso | Feche outro processo ou altere `PORT` no `backend/.env` |
| Prisma pede versão 7 | Use `npx prisma migrate dev` **dentro de `backend/`** (Prisma 5 do projeto) |
| Windows: `cp` não funciona | Use `copy .env.example .env` no PowerShell, dentro de `backend\` |
| Linux: permissão negada no Docker | Rode `sudo usermod -aG docker $USER` e faça login de novo (seção 4.2) |

---

## 13. Endpoints principais da API

| Método | Rota | Descrição |
|--------|------|-----------|
| POST | `/auth/register` | Cadastro |
| POST | `/auth/login` | Login |
| GET | `/auth/me` | Usuário logado (JWT) |
| GET | `/transactions` | Listar transações |
| POST | `/transactions` | Criar |
| PUT | `/transactions/:id` | Atualizar |
| DELETE | `/transactions/:id` | Excluir |
| GET | `/transactions/summary` | Resumo financeiro |
| GET | `/financial-news` | Notícias |

---

## 14. Variáveis de ambiente (`backend/.env`)

Copie de `.env.example` na primeira execução:

```env
DATABASE_URL="postgresql://postgres:postgres@localhost:5433/finova?schema=public"
JWT_SECRET="altere-em-producao-minimo-32-caracteres"
JWT_EXPIRES_IN="7d"
PORT=3000
NEWS_API_KEY=""   # opcional — NewsAPI; vazio usa notícias de fallback no backend
```

**Notícias no mobile (ordem):**

1. `GET {API_BASE_URL}/financial-news` — API Finova (preferencial)
2. Se o backend estiver fora — **NewsAPI** direto no app (`NEWS_API_KEY` no build)
3. Se NewsAPI bloquear o celular — **RSS** financeiro (G1 Economia, InfoMoney)
4. Se tudo falhar — dicas curadas FINOVA

O build do APK lê `NEWS_API_KEY` de `backend/.env` automaticamente.

**Celular fora da sua rede:** publique a API Finova (HTTPS) + mantenha a chave NewsAPI no build. Guia: [docs/API_PRODUCAO.md](docs/API_PRODUCAO.md).

```bash
cd mobile
cp .env.build.example .env.build
# API_BASE_URL=https://sua-api-publica.com
bash scripts/build-android-apk.sh
```

Desenvolvimento na mesma Wi‑Fi: o script detecta o IP do Mac automaticamente.

**Não compartilhe** o `.env` com senhas reais em repositórios públicos.

---

## 15. Estrutura de pastas (referência)

```txt
finova/
├── mobile/lib/
│   ├── core/              # Tema, rotas, rede, injeção de dependência
│   ├── domain/            # Entidades, contratos, use cases
│   ├── data/              # SQLite, API, implementação dos repositórios
│   ├── presentation/      # auth, dashboard, transactions, categories, news, profile
│   └── shared/widgets/    # Botões, cards, estados vazios/erro
├── backend/src/
│   ├── auth/
│   ├── transactions/
│   └── news/
├── backend/prisma/
├── docker-compose.yml
└── docs/DOCKER.md
```

---

## 16. Para o professor — roteiro de avaliação (≈ 5 min)

1. **Arquitetura:** MVVM no mobile + camadas `domain` / `data` / `presentation`; API modular NestJS.
2. **Banco:** PostgreSQL via Docker (`docker compose ps`); migrations Prisma em `backend/prisma/migrations`.
3. **Segurança:** senha com Bcrypt na API; JWT; `passwordHash` nunca retornado; token em armazenamento seguro no app.
4. **Demonstração ao vivo:** Swagger → cadastro → app → transação → dashboard atualizado.
5. **Resiliência:** desligar a API e mostrar que o app ainda abre (SQLite); aba Notícias com fallback.

Documentação interativa da API: **http://localhost:3000/api/docs**

---

## 17. Contato e entrega

| | |
|---|---|
| Repositório | *(link do GitHub ou ZIP entregue)* |
| Documentação Docker | [docs/DOCKER.md](docs/DOCKER.md) |
| Dúvidas técnicas | *(e-mail / WhatsApp da autora)* |

---

**Finova — controle financeiro pessoal**

*Última atualização: junho/2026*
