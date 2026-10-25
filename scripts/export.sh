#!/bin/bash

set -euo pipefail

if (( $# > 1 )); then
    printf 'Usage: %s [export-directory]\n' "$0" >&2
    exit 2
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd -P)"
EXPORT_DIR="${1:-"$ROOT_DIR/build/exports"}"

for tool in tuist xcodebuild codesign diskutil hdiutil ditto; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        printf 'Required tool not found: %s\n' "$tool" >&2
        exit 1
    fi
done

mkdir -p "$EXPORT_DIR"
EXPORT_DIR="$(cd "$EXPORT_DIR" && pwd -P)"

if [[ "$EXPORT_DIR" == "$ROOT_DIR" ]]; then
    printf 'Export directory must not be the project root.\n' >&2
    exit 1
fi

BUILD_DIR="$ROOT_DIR/build/DerivedData"
APP_NAME="Macopardy"
BUILT_APP="$BUILD_DIR/Build/Products/Release/$APP_NAME.app"
EXPORTED_APP="$EXPORT_DIR/$APP_NAME.app"
EXPORTED_DMG="$EXPORT_DIR/$APP_NAME.dmg"
STAGING_DIR="$(mktemp -d "${TMPDIR:-/tmp}/macopardy-export.XXXXXX")"
STAGED_APP="$STAGING_DIR/$APP_NAME.app"
STAGED_DMG="$STAGING_DIR/$APP_NAME.dmg"

cleanup() {
    rm -rf "$STAGING_DIR"
}
trap cleanup EXIT

tuist generate --no-open

xcodebuild -quiet \
    -project "$ROOT_DIR/$APP_NAME.xcodeproj" \
    -scheme "$APP_NAME" \
    -configuration Release \
    -destination 'generic/platform=macOS' \
    -derivedDataPath "$BUILD_DIR" \
    CODE_SIGN_STYLE=Manual \
    CODE_SIGN_IDENTITY=- \
    CODE_SIGNING_ALLOWED=YES \
    CODE_SIGNING_REQUIRED=YES \
    ENABLE_HARDENED_RUNTIME=YES \
    clean build

if [[ ! -d "$BUILT_APP" ]]; then
    printf 'Release app was not produced at %s\n' "$BUILT_APP" >&2
    exit 1
fi

ditto "$BUILT_APP" "$STAGED_APP"
codesign --verify --deep --strict --verbose=2 "$STAGED_APP"

SIGNATURE_INFO="$(codesign --display --verbose=4 "$STAGED_APP" 2>&1)"
if [[ "$SIGNATURE_INFO" != *"Signature=adhoc"* || "$SIGNATURE_INFO" != *"adhoc,runtime"* ]]; then
    printf 'Expected an ad-hoc signature with Hardened Runtime on %s\n' "$STAGED_APP" >&2
    exit 1
fi

SIGNED_ENTITLEMENTS="$(codesign -d --entitlements :- "$STAGED_APP" 2>/dev/null)"
for entitlement in \
    com.apple.security.app-sandbox \
    com.apple.security.files.user-selected.read-write \
    com.apple.security.network.client \
    com.apple.security.network.server; do
    if ! grep -Fq "<key>$entitlement</key><true/>" <<< "$SIGNED_ENTITLEMENTS"; then
        printf 'Expected entitlement missing from %s: %s\n' "$STAGED_APP" "$entitlement" >&2
        exit 1
    fi
done

if grep -Fq '<key>com.apple.security.get-task-allow</key><true/>' <<< "$SIGNED_ENTITLEMENTS"; then
    printf 'Development debugging entitlement must not be enabled in the export.\n' >&2
    exit 1
fi

mkdir "$STAGING_DIR/dmg"
ditto "$STAGED_APP" "$STAGING_DIR/dmg/$APP_NAME.app"
ln -s /Applications "$STAGING_DIR/dmg/Applications"
diskutil image create from \
    --format UDZO \
    --volumeName "$APP_NAME" \
    "$STAGING_DIR/dmg" \
    "$STAGED_DMG"
hdiutil verify "$STAGED_DMG"

rm -rf "$EXPORTED_APP"
mv "$STAGED_APP" "$EXPORTED_APP"
mv -f "$STAGED_DMG" "$EXPORTED_DMG"

printf 'Exported app: %s\n' "$EXPORTED_APP"
printf 'Exported DMG: %s\n' "$EXPORTED_DMG"
