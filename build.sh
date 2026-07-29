#!/usr/bin/env bash
# OneWhamScale - Build IPA (sans BlazeUniversal)
# Usage: ./build.sh --ipa Tinder.ipa [--sign CERT]

set -euo pipefail

CONFIG_DIR="$(cd "$(dirname "$0")" && pwd)"
WORK_DIR="$CONFIG_DIR/tmp"
OUTPUT_DIR="${CONFIG_DIR}/output"
SIGNING_CERT="${SIGNING_CERT:-}"

log() { echo -e "\033[32m[BUILD]\033[0m $1"; }
err() { echo -e "\033[31m[ERROR]\033[0m $1"; exit 1; }

cleanup() { rm -rf "$WORK_DIR"; }
trap cleanup EXIT

mkdir -p "$WORK_DIR" "$OUTPUT_DIR"

# Parse args
IPA_SOURCE=""
while [[ $# -gt 0 ]]; do
    case "$1" in
        --ipa) IPA_SOURCE="$2"; shift 2 ;;
        --sign) SIGNING_CERT="$2"; shift 2 ;;
        *) err "Argument inconnu: $1" ;;
    esac
done

[ -z "$IPA_SOURCE" ] && err "Usage: $0 --ipa Tinder.ipa"

# 1. Build OneWhamScale.dylib avec Theos
log "Compilation du tweak OneWhamScale..."
cd "$CONFIG_DIR"
export THEOS="${THEOS:-$HOME/theos}"
make clean 2>/dev/null || true
make package 2>/dev/null || {
    log "Theos pas trouvé, compilation manuelle..."
    "$(dirname "$0")/build_dylib.sh"
}

# 2. Extraire l'IPA Tinder
log "Extraction de l'IPA source..."
cd "$WORK_DIR"
unzip -q "$IPA_SOURCE" -d extracted/
APP_DIR=$(find extracted/Payload -name "*.app" -maxdepth 2 | head -1)
[ -z "$APP_DIR" ] && err "Aucun .app trouvé"
log "App: $APP_DIR"

# 3. Copier notre dylib
log "Injection OneWhamScale.dylib..."
mkdir -p "$APP_DIR/Frameworks"
cp "$CONFIG_DIR/OneWhamScale.dylib" "$APP_DIR/Frameworks/" 2>/dev/null || {
    cp "$CONFIG_DIR/.theos/obj/debug/OneWhamScale.dylib" "$APP_DIR/Frameworks/" 2>/dev/null || err "OneWhamScale.dylib pas trouvé"
}
cp "$CONFIG_DIR/OneWhamScaleConfig.plist" "$APP_DIR/"

# 4. Modifier Info.plist
log "Rebranding..."
plutil -replace CFBundleDisplayName -string "OneWhamScale" "$APP_DIR/Info.plist"
plutil -replace CFBundleName -string "OneWhamScale" "$APP_DIR/Info.plist"
plutil -replace CFBundleIdentifier -string "com.onewhamscale.tinderplus" "$APP_DIR/Info.plist"

# 5. Injecter le dylib dans le binaire
log "Patch du binaire..."
BINARY="$APP_DIR/$(plutil -extract CFBundleExecutable raw "$APP_DIR/Info.plist")"
if command -v insert_dylib &>/dev/null; then
    insert_dylib --strip-codesig --all-yes \
        "@executable_path/Frameworks/OneWhamScale.dylib" \
        "$BINARY" "$BINARY.patched"
    mv "$BINARY.patched" "$BINARY"
    log "Binaire patché"
fi

# 6. Nettoyer signature
find "$APP_DIR" -name "_CodeSignature" -exec rm -rf {} + 2>/dev/null || true
find "$APP_DIR" -name "SC_Info" -exec rm -rf {} + 2>/dev/null || true

# 7. Signer
if [ -n "$SIGNING_CERT" ]; then
    codesign -f -s "$SIGNING_CERT" --deep "$APP_DIR"
    log "Signé avec: $SIGNING_CERT"
elif command -v ldid &>/dev/null; then
    find "$APP_DIR" -name "*.dylib" -exec ldid -S {} \;
    ldid -S "$APP_DIR"
    log "Signé avec ldid"
else
    log "Warning: non signé"
fi

# 8. Repack IPA
log "Création de l'IPA..."
cd "$WORK_DIR/extracted"
IPA_OUT="$OUTPUT_DIR/OneWhamScale_TinderPlus_$(date +%Y%m%d).ipa"
zip -qry "$IPA_OUT" .
log "IPA: $IPA_OUT"
ls -lh "$IPA_OUT"