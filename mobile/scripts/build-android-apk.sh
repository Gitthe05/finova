#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

load_env_build() {
  local env_file="$ROOT/.env.build"
  if [[ ! -f "$env_file" ]]; then
    return 0
  fi
  set -a
  # shellcheck disable=SC1091
  source "$env_file"
  set +a
}

detect_lan_ip() {
  local ip=""
  if [[ "$(uname -s)" == "Darwin" ]]; then
    ip="$(ipconfig getifaddr en0 2>/dev/null || true)"
    if [[ -z "$ip" ]]; then
      ip="$(ipconfig getifaddr en1 2>/dev/null || true)"
    fi
  else
    ip="$(hostname -I 2>/dev/null | awk '{print $1}' || true)"
  fi
  if [[ -z "$ip" ]]; then
    echo "Não foi possível detectar o IP da rede. Defina manualmente:"
    echo "  API_BASE_URL=https://sua-api.com bash $0"
    echo "  ou crie mobile/.env.build (veja .env.build.example)"
    exit 1
  fi
  API_BASE_URL="http://${ip}:3000"
}

load_news_api_from_backend_env() {
  local env_file="$ROOT/../backend/.env"
  if [[ ! -f "$env_file" ]]; then
    return 0
  fi
  if [[ -z "${NEWS_API_KEY:-}" ]]; then
    NEWS_API_KEY="$(grep -E '^NEWS_API_KEY=' "$env_file" | head -1 | cut -d= -f2- | tr -d '"' | tr -d "'" | xargs || true)"
  fi
  if [[ -z "${NEWS_API_URL:-}" ]]; then
    NEWS_API_URL="$(grep -E '^NEWS_API_URL=' "$env_file" | head -1 | cut -d= -f2- | tr -d '"' | tr -d "'" | xargs || true)"
  fi
}

load_env_build
load_news_api_from_backend_env

if [[ -z "${API_BASE_URL:-}" ]]; then
  if [[ "${BUILD_ENV:-}" == "production" ]]; then
    echo "BUILD_ENV=production exige API_BASE_URL (URL pública HTTPS da API Finova)."
    echo "Ex.: API_BASE_URL=https://api.finova.com bash $0"
    exit 1
  fi
  detect_lan_ip
  echo "→ Modo local: API na mesma rede Wi‑Fi"
else
  echo "→ API_BASE_URL definida (app funciona fora da rede local)"
fi

echo "→ API_BASE_URL=$API_BASE_URL"
echo "→ flutter pub get"
flutter pub get

echo "→ ícone e splash (Android alinhado ao iOS)"
dart run flutter_launcher_icons
dart run flutter_native_splash:create

BUILD_ARGS=(
  --release
  --no-tree-shake-icons
  "--dart-define=API_BASE_URL=$API_BASE_URL"
)
if [[ -n "${NEWS_API_KEY:-}" ]]; then
  BUILD_ARGS+=("--dart-define=NEWS_API_KEY=$NEWS_API_KEY")
fi
if [[ -n "${NEWS_API_URL:-}" ]]; then
  BUILD_ARGS+=("--dart-define=NEWS_API_URL=$NEWS_API_URL")
fi
echo "→ flutter build apk --release"
flutter build apk "${BUILD_ARGS[@]}"

APK="$ROOT/build/app/outputs/flutter-apk/app-release.apk"
if [[ -f "$APK" ]]; then
  echo ""
  echo "✓ APK gerado:"
  echo "  $APK"
  ls -lh "$APK"
  echo ""
  echo "Instalar no celular (USB + depuração):"
  echo "  adb install -r \"$APK\""
  echo ""
  if [[ "$API_BASE_URL" == https://* ]]; then
    echo "Este APK usa API pública — celular pode estar em qualquer rede (4G/Wi‑Fi)."
  else
    echo "Este APK usa rede local — API Finova precisa estar acessível nesse endereço."
    echo "Para qualquer rede: deploy da API + API_BASE_URL=https://... (veja docs/API_PRODUCAO.md)"
  fi
else
  echo "APK não encontrado em $APK"
  exit 1
fi
