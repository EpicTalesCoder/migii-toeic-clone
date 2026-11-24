# iOS App Evidence Inventory — `migii-toeic`

- **Decryption Status**: **PASS — DECRYPTED (`cryptid == 0`)**: Ready for REA / Ghidra / Hopper / IDA decompilation.
- **App Bundle**: `Migii TOEIC®.app`
- **Main Executable**: `Migii TOEIC®` (12,867,680 B)
- **CFBundleIdentifier**: `com.eup.migiitoeic`
- **Display Name**: `Migii TOEIC®`
- **Version / Build**: `1.4.1` (`51`)
- **Original MinimumOSVersion**: `10.0` (Rebuild target: **`iOS 16.0` for iPhone XS Max iOS 16.1.1**)
- **Detected Runtime Stack**: SwiftUI, UIKit, Swift, Objective-C, Metal, SpriteKit/SceneKit, CoreData, SQLite
- **Assets.car**: Assets.car (5,480,888 B) — 342 renditions, 304 unique names
- **Exported Localizations**: 116 `.strings`/`.stringsdict` file(s) -> `analysis/metadata/strings-lproj/`

## 1. Main Mach-O Slices & FairPlay Check

| Arch | 64-bit | `cryptid` | Encrypted? | MinOS | SDK |
|---|---|---|---|---|---|
| `arm64` | True | `[0]` | NO (OK) | `13.0.0` | `18.4.0` |

## 2. Embedded Frameworks & Dynamic Libraries

| Framework / Dylib | Size | Archs | Encrypted? | MinOS |
|---|---:|---|---|---|
| `FBSDKCoreKit.framework` | 3,725,168 B | `arm64` | NO | `12.0.0` |
| `Alamofire.framework` | 2,828,656 B | `arm64` | NO | `13.0.0` |
| `FirebaseAuth.framework` | 2,756,592 B | `arm64` | NO | `13.0.0` |
| `SQLite.framework` | 1,260,640 B | `arm64` | NO | `13.0.0` |
| `FirebaseCrashlytics.framework` | 846,656 B | `arm64` | NO | `13.0.0` |
| `FBAEMKit.framework` | 733,648 B | `arm64` | NO | `12.0.0` |
| `SwiftTheme.framework` | 588,144 B | `arm64` | NO | `13.0.0` |
| `FirebaseSharedSwift.framework` | 541,360 B | `arm64` | NO | `13.0.0` |
| `FirebasePerformance.framework` | 535,728 B | `arm64` | NO | `13.0.0` |
| `FirebaseMessaging.framework` | 531,584 B | `arm64` | NO | `13.0.0` |
| `SwiftyStoreKit.framework` | 494,576 B | `arm64` | NO | `13.0.0` |
| `FirebaseRemoteConfig.framework` | 475,616 B | `arm64` | NO | `13.0.0` |
| `TikTokBusinessSDK.framework` | 438,576 B | `arm64` | NO | `13.0.0` |
| `GTMSessionFetcher.framework` | 405,792 B | `arm64` | NO | `13.0.0` |
| `FSPagerView.framework` | 396,880 B | `arm64` | NO | `13.0.0` |
| `GoogleDataTransport.framework` | 387,152 B | `arm64` | NO | `13.0.0` |
| `FirebaseCoreInternal.framework` | 359,456 B | `arm64` | NO | `13.0.0` |
| `FirebaseSessions.framework` | 358,096 B | `arm64` | NO | `13.0.0` |
| `NVActivityIndicatorView.framework` | 351,344 B | `arm64` | NO | `13.0.0` |
| `pop.framework` | 347,008 B | `arm64` | NO | `13.0.0` |
| `AppCheckCore.framework` | 334,448 B | `arm64` | NO | `13.0.0` |
| `SnapKit.framework` | 331,328 B | `arm64` | NO | `13.0.0` |
| `TTGSnackbar.framework` | 320,256 B | `arm64` | NO | `13.0.0` |
| `AppAuth.framework` | 320,176 B | `arm64` | NO | `13.0.0` |
| `GTMAppAuth.framework` | 318,528 B | `arm64` | NO | `13.0.0` |
| `Koloda.framework` | 316,512 B | `arm64` | NO | `13.0.0` |
| `GoogleSignIn.framework` | 310,320 B | `arm64` | NO | `13.0.0` |
| `GoogleUtilities.framework` | 309,408 B | `arm64` | NO | `13.0.0` |
| `MarqueeLabel.framework` | 281,056 B | `arm64` | NO | `13.0.0` |
| `FirebaseInstallations.framework` | 278,992 B | `arm64` | NO | `13.0.0` |
| `ChameleonFramework.framework` | 256,480 B | `arm64` | NO | `13.0.0` |
| `SSZipArchive.framework` | 236,656 B | `arm64` | NO | `13.0.0` |
| `AdvancedPageControl.framework` | 235,184 B | `arm64` | NO | `13.0.0` |
| `Promises.framework` | 223,360 B | `arm64` | NO | `13.0.0` |
| `FirebaseCore.framework` | 206,384 B | `arm64` | NO | `13.0.0` |
| `FBLPromises.framework` | 192,576 B | `arm64` | NO | `13.0.0` |
| `WKWebViewJavascriptBridge.framework` | 178,448 B | `arm64` | NO | `13.0.0` |
| `FBSDKCoreKit_Basics.framework` | 167,296 B | `arm64` | NO | `12.0.0` |
| `FirebaseRemoteConfigInterop.framework` | 148,480 B | `arm64` | NO | `13.0.0` |
| `BEMCheckBox.framework` | 133,056 B | `arm64` | NO | `13.0.0` |
| `FirebaseABTesting.framework` | 131,744 B | `arm64` | NO | `13.0.0` |
| `nanopb.framework` | 96,992 B | `arm64` | NO | `13.0.0` |
| `FirebaseAppCheckInterop.framework` | 88,064 B | `arm64` | NO | `13.0.0` |
| `FirebaseCoreExtension.framework` | 88,032 B | `arm64` | NO | `13.0.0` |
| `FirebaseAuthInterop.framework` | 87,968 B | `arm64` | NO | `13.0.0` |
| `RecaptchaInterop.framework` | 87,920 B | `arm64` | NO | `13.0.0` |

## 3. Permissions, URL Schemes, Extensions & Resources

- **Permissions (`NS*UsageDescription`)**: `NSMicrophoneUsageDescription`, `NSPhotoLibraryUsageDescription`, `NSSpeechRecognitionUsageDescription`, `NSUserTrackingUsageDescription`
- **URL Schemes (`CFBundleURLTypes`)**: `com.googleusercontent.apps.971408275116-156rlg1slnaavfnldjv6g79jv83kg6od`, `fb961489275293873`, `migiitoeic`
- **App Extensions (`PlugIns/*.appex`)**: `PlugIns/NotificationServiceExtension.appex`
- **Bundled Fonts**: `Frameworks/GoogleSignIn.framework/GoogleSignIn.bundle/Roboto-Bold.ttf`, `SVN-AVO-BOLD.TTF`, `SVN-AVO-ITALIC.TTF`, `SVN-AVO.TTF`
- **CoreData / Databases**: `CoreData.momd`
- **Interface Builder (`.nib` / `.storyboardc`)**: 6 item(s) — samples: `Base.lproj/LaunchScreen.storyboardc`, `Base.lproj/LaunchScreen.storyboardc/01J-lp-oVM-view-Ze5-6b-2t3.nib`, `Base.lproj/LaunchScreen.storyboardc/UIViewController-01J-lp-oVM.nib`, `Base.lproj/Main.storyboardc`, `Base.lproj/Main.storyboardc/BYZ-38-t0r-view-8bC-Xf-vdC.nib`, `Base.lproj/Main.storyboardc/UIViewController-BYZ-38-t0r.nib`

## 4. File Type Breakdown

| Extension | Count |
|---|---:|
| `.strings` | 116 |
| `(no-ext)` | 96 |
| `.plist` | 75 |
| `.xcprivacy` | 22 |
| `.json` | 15 |
| `.png` | 5 |
| `.nib` | 4 |
| `.ttf` | 4 |
| `.sinf` | 2 |
| `.supf` | 2 |
| `.supp` | 2 |
| `.supx` | 2 |
| `.html` | 2 |
| `.txt` | 1 |
| `.car` | 1 |
| `.mom` | 1 |
| `.gif` | 1 |

## 5. Next Steps (Stage 1 -> Stage 4)
1. Verify **Decryption Status** above is `PASS (cryptid == 0)`.
2. Run REA `open_bundle_resources` (`inspect_plist`, `decode_interface_builder`, `inspect_asset_catalog`, `inspect_keyed_archive`) and `open_binary` (`project_apple_application_graph`, `inspect_macho`, `inspect_signature`, Ghidra/Hopper/IDA).
3. Write `apps/migii-toeic/analysis/ARCHITECTURE-MAP.md` before coding `ios-app/Sources/`.
