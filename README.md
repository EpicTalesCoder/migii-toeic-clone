# Migii TOEIC (Clone)

1:1 native Swift rebuild targeting **iPhone XS Max (iPhone11,6 / 414x896 @3x / arm64)** on **iOS 16.1.1**.

## Project Metadata
- **Slug**: `migii-toeic`
- **XcodeGen Target**: `MigiiToeic`
- **Rebuild Version**: `v1.4.2` (`52`) — auto-incremented on every CI run/re-run
- **Original Source Version**: `1.4.1` (`com.eup.migiitoeic`)
- **Rebuild Bundle Identifier**: `com.rebuild.migiitoeic`
- **Deployment Target**: `iOS 16.0` (`arm64`, `SWIFT_VERSION: 5.0`)
- **Signing Mode**: `unsigned-adhoc-trollstore-sideloadly` (unsigned / inside-out ad-hoc signed `.ipa` for TrollStore 2, Sideloadly, AltStore, SideStore)

## Layout
- `apps/migii-toeic/ios-app/` — XcodeGen `project.yml`, Swift `Sources/`, resources, and `Tests/`
- `apps/migii-toeic/analysis/` — Static inventory, `ARCHITECTURE-MAP.md`, metadata, and disassembly evidence
- `.github/workflows/ios-build-ipa.yml` — Automated macOS CI pipeline building the `arm64` `.ipa` & publishing direct `.ipa` releases (`latest-migii-toeic`)

## Versioning, Verification & Local Project Generation
```bash
python3 tools/bump-ios-version.py migii-toeic
python3 tools/verify-ios-parity.py migii-toeic --ci
xcodegen generate --spec apps/migii-toeic/ios-app/project.yml --project apps/migii-toeic/ios-app
```
