#!/bin/bash
set -euo pipefail

ARCHIVE="${1:-UTM.xcarchive}"
APP="$ARCHIVE/Products/Applications/UTM.app"

if [ ! -d "$APP" ]; then
    echo "UTM.app not found at: $APP" >&2
    exit 1
fi

echo "Before slimming:"
du -sh "$APP"

# Reuse the Pocket8 SideStore App ID slot.
# SideStore will append its own team suffix when it re-signs the IPA.
/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.jevon.pocket8" "$APP/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName UTM Lite" "$APP/Info.plist" || true

# Keep the embedded helper under the host bundle namespace.
HELPER_PLIST="$(find "$APP" -path '*/iOSHelper.appex/Info.plist' -print -quit || true)"
if [ -n "$HELPER_PLIST" ]; then
    /usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier com.jevon.pocket8.iOSHelper" "$HELPER_PLIST"
fi

# Biggest safe storage cut: keep only the two guest CPU families most useful
# on an iPhone. qemu-system-x86_64 also covers 32-bit x86 guests.
find "$APP" -type d -name 'qemu-*-softmmu.framework' -print0 |
while IFS= read -r -d '' FW; do
    case "$(basename "$FW")" in
        qemu-aarch64-softmmu.framework|qemu-x86_64-softmmu.framework)
            ;;
        *)
            echo "Removing unused guest backend: $(basename "$FW")"
            rm -rf "$FW"
            ;;
    esac
done

# Keep English and Base resources only. This does not touch VM firmware,
# graphics acceleration, SPICE, networking, or the JIT path.
find "$APP" -type d -name '*.lproj' -print0 |
while IFS= read -r -d '' LPROJ; do
    case "$(basename "$LPROJ")" in
        en.lproj|Base.lproj)
            ;;
        *)
            rm -rf "$LPROJ"
            ;;
    esac
done

# Remove archive-only metadata that is never needed inside the installed app.
find "$APP" -name '.DS_Store' -delete || true

echo "After slimming:"
du -sh "$APP"

echo "Main bundle ID: $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$APP/Info.plist")"
if [ -n "$HELPER_PLIST" ]; then
    echo "Helper bundle ID: $(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$HELPER_PLIST")"
fi
