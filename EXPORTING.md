# Exporting Macopardy

The export script builds a Release version of the app with Hardened Runtime and an ad-hoc code signature, then creates both a standalone app and a compressed DMG:

```sh
./scripts/export.sh
```

The outputs are written to `build/exports/`. To choose another output directory:

```sh
./scripts/export.sh /path/to/exports
```

The script requires Tuist, Xcode command-line tools, and the macOS `codesign`, `ditto`, `diskutil`, and `hdiutil` utilities. It verifies the app signature and DMG before exporting.

## Sharing limits

An ad-hoc signature does not identify a developer and cannot be notarized. macOS may warn recipients that the app is from an unidentified developer or cannot be checked for malicious software. A DMG does not remove this warning. For a recipient who trusts the copy, Finder may allow opening it by Control-clicking the app, choosing **Open**, then confirming **Open** again. System policies may still block it.

For a smoother install for other people, the app must be signed with a Developer ID certificate and notarized by Apple. The export produced here is intended for trusted sharing, not Mac App Store distribution.
