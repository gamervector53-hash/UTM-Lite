# UTM Lite iOS build

This branch keeps the regular UTM iOS JIT build but trims installed storage.

## Bundle ID

The archive is rewritten to use:

- Main app: `com.jevon.pocket8`
- iOS helper: `com.jevon.pocket8.iOSHelper`

When SideStore re-signs the main app on Vector's current account, the expected final main identifier is `com.jevon.pocket8.55CB4Z939B`.

## What is removed

To cut installed size without removing the JIT path, the build keeps only these QEMU guest backends:

- `aarch64-softmmu`
- `x86_64-softmmu`

It also keeps only English/Base localizations.

The build intentionally keeps graphics acceleration, SPICE/display support, networking, firmware, and the regular `iOS` scheme with `WITH_JIT`.

## Build

Run the **Build UTM Lite iOS** workflow manually on the `vector-lite` branch. The workflow uploads `VectorUTM-Lite.ipa` plus `SIZE.txt`.
