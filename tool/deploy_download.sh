#!/usr/bin/env bash
# Builds the signed release APK and deploys the download page (Worker tchip-cash).
# First time only: `npx wrangler login`.
# Usage: tool/deploy_download.sh            (build + deploy)
#        SKIP_BUILD=1 tool/deploy_download.sh  (deploy the last build)
set -euo pipefail
cd "$(dirname "$0")/.."

APK=build/app/outputs/flutter-apk/app-arm64-v8a-release.apk
OUT=build/download

if [[ ! -f android/key.properties ]]; then
  echo "android/key.properties missing: the APK would be signed with the debug key." >&2
  echo "Friends could not update it later with the release key. Aborting." >&2
  exit 1
fi

if [[ -z "${SKIP_BUILD:-}" ]]; then
  flutter build apk --release --split-per-abi
fi
[[ -f "$APK" ]] || { echo "$APK not found" >&2; exit 1; }

size=$(stat -c %s "$APK")
# Cloudflare static assets refuse files over 25 MiB.
(( size < 25 * 1024 * 1024 )) || { echo "APK is over 25 MiB, Cloudflare will refuse it" >&2; exit 1; }

version=$(grep -E '^version:' pubspec.yaml | awk '{print $2}')
rm -rf "$OUT" && mkdir -p "$OUT"
cp -r download/site/. "$OUT/"
cp "$APK" "$OUT/tchip.apk"
printf '{"version":"%s","sizeMb":%s}\n' "${version%%+*}" \
  "$(awk -v s="$size" 'BEGIN{printf "%.1f", s/1048576}')" > "$OUT/version.json"

npx --yes wrangler@latest deploy --assets "$OUT"
