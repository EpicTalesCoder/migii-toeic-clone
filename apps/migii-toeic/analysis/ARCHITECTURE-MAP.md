# Migii TOEIC® (v1.4.1 / Build 51) — Stage 1 Architecture & Evidence Map

> Target rebuild profile: **iPhone XS Max (`414×896 pt @3x`, Notch `44 pt` top / `34 pt` bottom, A12 `arm64`) running iOS 16.1.1**.

## 1. Binary & Security Verification (Observed)

| Artifact | Path (Extracted) | Arch / Platform | `cryptid` | Size | Notes |
|---|---|---|---|---|---|
| Main Binary | `Payload/Migii TOEIC®.app/Migii TOEIC®` | `arm64` / `IOS` (`minos 13.0`, `sdk 18.4`) | `0` (Decrypted) | 12,867,680 B | FairPlay clear |
| App Extension | `Payload/Migii TOEIC®.app/PlugIns/NotificationServiceExtension.appex/NotificationServiceExtension` | `arm64` / `IOS` (`minos 15.5`, `sdk 18.4`) | `0` (Decrypted) | 90,208 B | Rich push media |
| Frameworks (`46`) | `Payload/Migii TOEIC®.app/Frameworks/*.framework` | `arm64` | `0` (All 46 verified) | — | CocoaPods dynamic frameworks |

- **Bundle Identifier**: Original `com.eup.migiitoeic` -> Rebuild `com.rebuild.migiitoeic` (per `project.yml` isolation contract; display name `Migii TOEIC`, version `1.4.1`, build `51`).
- **Original Source Root Recovered**: `/Users/tuandv/IosProject/toeic/migii-toeic-ios/Migii Toeic/` (296 `.swift` files traced via `__cstring` assertions + 665 `Migii_TOEIC_*` ObjC/Swift classes + 877 Swift5 type metadata descriptors).

## 2. Runtime Stack & Framework Replacement Strategy

Migii TOEIC® is a pure **UIKit + SnapKit programmatic layout** application (NO SwiftUI screens; `SwiftUI` weak link originates from `MarketplaceKit` transitive dependency). Question bodies and explanations render inside `WKWebView` (`question.html`, `explain.html`) controlled via `WKWebViewJavascriptBridge`.

For zero-dependency self-contained **XcodeGen + GitHub Actions CI (`macos-15`)** builds without CocoaPods/network fragility, original third-party frameworks are mapped to pure iOS 16.0 SDK equivalents:

| Original Framework / SDK | Role in Migii TOEIC® | iOS 16 Native Replacement |
|---|---|---|
| `SnapKit` | Programmatic Auto Layout constraints | UIKit `NSLayoutAnchor` + tiny fluent layout DSL helper |
| `SwiftTheme` | Light/Dark theme switching (`ThemeManager.currentThemeIndex`) | Dynamic `UIColor { traitCollection in ... }` + reactive `ThemeManager` (`ThemeObserver`) matching `ColorHelper` hex pairs |
| `Alamofire` / `SwiftyJSON` | REST calls & JSON parsing (`AlamofireHelper`) | `URLSession` + `Codable` DTOs matching exact `__swift5_fieldmd` keys |
| `SQLite.swift` | Offline theory DB (`TheoryDbHelper`: `words`, `examples`, `grammars`) | System `libsqlite3.tbd` (`import SQLite3`) wrapper |
| `CoreData.momd` | Offline cache (`MigiiDB`, `WordDB`, `HistoryDB`) | Native `NSPersistentContainer(name: "CoreData")` + compiled `CoreData.xcdatamodeld` |
| `SSZipArchive` / `Zip` | Extracting downloaded `theory/{lang}/{lang}.zip` | Native DEFLATE/ZIP extractor (`Compression` / Foundation ZIP reader) |
| `WKWebViewJavascriptBridge` | Bidirectional JS bridge (`onHighlightClicked`, `onAnswerChoose`, `onSelectionChange`, `onImageClick`) | Native `WKScriptMessageHandler` + injected JS bridge shim compatible with original `question.html` / `explain.html` |
| `SDWebImage` / `CachedImageView` | Remote image loading & caching | `URLSession` + `NSCache<NSString, UIImage>` |
| `FSPagerView` / `Koloda` | Banner carousel & flashcard swipe deck | `UICollectionView` (`UICollectionViewFlowLayout` paging) & `UIPanGestureRecognizer` card stack (`FlashCardVC`) |
| `BEMCheckBox` / `TTGSnackbar` / `NVActivityIndicatorView` / `AdvancedPageControl` / `MarqueeLabel` / `Charts` | UI widgets, toasts, spinners, progress, line chart (`MLLineChart`) | Native UIKit / CoreGraphics (`CAShapeLayer`, `UIActivityIndicatorView`, custom `MLLineChart` / `ToastView` / `CircularProgressBar`) matching recovered Swift classes |
| `GoogleMobileAds`, `FBSDK*`, `TikTokBusinessSDK`, `FirebaseAnalytics/Crashlytics/Performance`, `AppTrackingTransparency` ads | Ads & third-party telemetry | Omitted / no-op ad stub (`AdsConfig` preserved in settings, ad banners clean & non-intrusive on iOS 16.1.1 sideload) |
| `SwiftyStoreKit` | In-App Purchase (`migii_toeic_*`) | Native `StoreKit` (`SKPaymentQueue` / StoreKit 1) with sandbox-safe local unlock fallback hook for testing |

## 3. Info.plist, Permissions, URL Schemes & Fonts

- **Permissions (`Info.plist`)**:
  - `NSMicrophoneUsageDescription`: `"Migii TOEIC needs to access your microphone to record your voice for the speaking skill"`
  - `NSSpeechRecognitionUsageDescription`: `"Migii TOEIC needs to access Speech Recognition to recognize your voice for the speaking skill"`
  - `NSPhotoLibraryUsageDescription`: `"Migii needs access to your camera roll to select and upload photos"`
  - `NSUserTrackingUsageDescription`: `"This allows Migii TOEIC to provide you with better ads experiences."`
  - `NSAppTransportSecurity`: `NSAllowsArbitraryLoads = true`
- **Custom Fonts (`UIAppFonts`)**:
  - `SVN-AVO.TTF` (postscript: `SVN-Avo`)
  - `SVN-AVO-BOLD.TTF` (postscript: `SVN-Avo-Bold`)
  - `SVN-AVO-ITALIC.TTF` (postscript: `SVN-AvoItalic`)
  - `Montserrat-SemiBold.ttf` (bundled in `.app` root; kept in Resources)
- **URL Schemes (`CFBundleURLTypes`)**: `migiitoeic`, Google reversed client ID (`com.googleusercontent.apps.971408275116-9456b267d378u4k62c771vsqjqqc42f1`)
- **Entitlements (`Entitlements.plist`)**: Removed APS/SignIn restricted entitlements that block ad-hoc/sideloaded profiles unless TrollStore-installed; clean app entitlements + keychain-access-groups compatible with `Sideloadly`/`AltStore`/`TrollStore 2`.

## 4. Exact Design System Tokens (Decoded from `ColorHelper` ASM `0x1000c7fc0..0x1000c8688`)

| Slot Address | Offset | Light Hex | Dark / Paired Hex | Semantic Role |
|---|---|---|---|---|
| `0x100baa628` | `#1576` | `#48BCAA` | `#48BCAA` | Primary brand teal (`colorPrimary`) |
| `0x100baa630` | `#1584` | `#FF8000` | `#FF8000` | Brand orange accent (`colorAccent`) |
| `0x100baa638` / `640` | `#1592` / `#1600` | `#FAFAFA` | `#212121` | Screen background (`bgScreen`) |
| `0x100baa648` / `650` | `#1608` / `#1616` | `#FFFFFF` | `#333333` | Card / surface background (`bgCard`) |
| `0x100baa658` / `660` | `#1624` / `#1632` | `#212121` | `#FFFFFF` | Primary text (`textPrimary`) |
| `0x100baa668` / `670` | `#1640` / `#1648` | `#616161` | `#EEEEEE` | Secondary text (`textSecondary`) |
| `0x100baa678` / `680` | `#1656` / `#1664` | `#EF5350` | `#FF5F55` | Error / wrong answer red (`colorWrong`) |
| `0x100baa688` | `#1672` | `#F8F1AE` | — | Vocabulary highlight background (`colorHighlight`) |
| `0x100baa690` | `#1680` | `#F9AA33` | — | Premium gold / star / warn (`colorGold`) |
| `0x100baa698` / `6a0` | `#1688` / `#1696` | `#FFC107` | `#FF8801` | Amber / countdown badge |
| `0x100baa6a8` / `6b0` | `#1704` / `#1712` | `#2E7A71` | `#1EA684` | Deep teal / emerald contrast |
| `0x100baa6b8` / `6c0` | `#1720` / `#1728` | `#9E9E9E` | `#BDBDBD` | Muted text / unselected icon |
| `0x100baa6c8` | `#1736` | `#32BEA6` | `#32BEA6` | Correct answer green-teal (`colorCorrect`) |
| `0x100baa6d0` | `#1744` | `#509859` | — | Mastery green |
| `0x100baa6d8` | `#1752` | `#43887D` | — | Dark primary teal |
| `0x100baa6e0` | `#1760` | `#2196F3` | — | Info / blue link (`colorBlue`) |
| `0x100baa6e8` | `#1768` | `#121212` | — | Deep charcoal |
| `0x100baa6f0` | `#1776` | `#E0E0E0` | `#E0E0E0` | Separator / hairline border |

## 5. Screen Inventory & Navigation Architecture

### App Launch & Onboarding (`AppDelegate` `0x10023e800..0x100240500` -> `SplashVC` `0x1000f2b78..0x1000fd000`)
- `AppDelegate`: Checks `UserDefaultHelper` defaults, sets `AVAudioSession` playback + remote control events, hides `UINavigationBar.appearance()`, creates `UIWindow(frame: UIScreen.main.bounds)` with `UINavigationController(rootViewController: SplashVC())`.
- `SplashVC`: Initializes 16 TOEIC part types (`photographs`/`picture description`, `question - response`, `short conversations`, `short talks`, `incomplete sentences`, `text completion`/`reading comprehension`, `read a text aloud`, `describe a picture`, `respond to questions (1)`, `respond to questions (2)`, `propose a solution`, `express an opinion`, `write a sentence`, `respond a request`, `write an opinion essay`), fetches server time (`Users/timeServer`) & optional user sync (`Users/userSynchronizedGet`), then routes:
  - First launch (`!openOnboarding`): `OnboardingVC` (`OnboardingLanguageView` -> `OnboardingIntroduceView` -> `OnboardingReminderView` / `OnboardingReminderSetupView` -> `OnboardingStartView` / `OnboardingLoginView` / `OnboardingRegisterView`)
  - Subsequent launches: `HomeVC`

### Main Shell: `HomeVC` (`0x100093840..0x1000a3000`) — 5 Bottom Tabs
1. **Tab 0 — Practice (`PracticeTabView` + `ic_practice_selected`)**:
   - Header: quick shortcuts to **Theory** (`TheoryVC`), **Notebook** (`NotebookVC`), **Exam Online** (`ExamOnlineEventVC`), Download Manager (`DownloadManagerVC`)
   - **Listening (Kinds 1–4)**: Photos (`picture description`), Q&A (`question - response`), Short Conversations (`short conversations`), Short Talks (`short talks`)
   - **Reading (Kinds 5–7)**: Incomplete Sentences, Text Completion / Single Passage, Multiple Passages (`reading comprehension`)
   - **Speaking (Kinds 8–13)**: Read a text aloud, Describe a picture, Respond to questions (1/2), Propose a solution, Express an opinion
   - **Writing (Kinds 14–16)**: Write a sentence, Respond to a written request, Write an opinion essay
   - Practice flow: `PartDescriptionVC` / `PartDesPracticeWrongVC` -> `KindPracticeVC` / `PartPracticeVC` (audio + `MyWebView` HTML + choice/split/speak/write cells) -> `PartResultVC` / `PartSpeakWriteResultVC` -> `PartAnswerVC` / `PartSpeakWriteAnswerVC`
2. **Tab 1 — Exam (`ExamTabView` + `ic_exam_unselect`)**:
   - Mock tests, Mini tests, Recent Training (`TestPracticeVC`), Online Trial Events (`ExamOnlineEventVC` -> `DetailHappeningVC` / `LearnMoreExamOnline` -> `PreparePracticeExamOnline` -> `PracticeExamOnline` -> `ExamOnlineResultVC` -> `ExamOnlineSummaryAnswerVC` / `ExamOnlineAnswerVC` / `DetailHistoryExamOnlineVC`).
   - Standard Exam flow: `ExamListSeeMoreVC` -> `ExamPrepareVC` -> `ExamTestVC` -> `ExamResultVC` / `ExamSpeakWriteResultVC` -> `ExamSummaryAnswerVC` / `ExamAnswerVC` -> `ExamAnswerDetailVC` / `ExamSpeakWriteAnswerVC`.
3. **Tab 2 — Roadmap (`RoadmapTabView` + `ic_route_unselect`)**:
   - `RoadmapIntroduceView` (`TutorialRoadmap1..4`) -> `RoadmapLevelView` -> `RoadmapDayView` -> `RoadmapEntranceView` / `RoadmapEntranceVC` -> `RoadmapEntranceResultVC` -> `RoadmapLoadDataView` -> `RoadmapDailyView` / `RoadmapDetailView` -> `RoadmapEvaluatePrepareVC` -> `RoadmapEvaluateVC` -> `RoadmapEvaluateResultVC` + daily lesson/test/completion dialogs.
4. **Tab 3 — Premium (`PremiumTabView` + `ic_premium_unselect`)**:
   - Countdown banner (`PremiumCountdownView`), in-house sale banner (`PremiumBannerView`), recent upgrades ticker (`PremiumRecentlyUpgradeView`), plan selection (`PremiumPurchaseView` / `ForeverPurchaseView`), store SKU mapping (`migii_toeic_3_days`, `migii_toeic_5_days`, `migii_toeic_7_days`, `migii_toeic_15_days`, `migii_toeic_1months_auto`, `migii_toeic_3months_auto`, `migii_toeic_6months_auto`, `migii_toeic_12months_auto`, `migii_toeic_preforever`, `migii_toeic_custom`), virtual bill / payment methods (`InvoicesSkuVC`).
5. **Tab 4 — Settings (`SettingsTabView` + `ic_setttings_unselect`)**:
   - 16 `SettingsType` rows: `ACCOUNT` (`SignInVC` / `RegisterVC` / `UserProfileVC` / `ChangePasswordVC`), `LANGUAGE_DEVICE`, `THEME_APP` (Light/Dark), `DOWNLOAD_MANAGER` (`DownloadManagerVC`), `FANPAGE`, `ANSWER_INTERFACE` (`OptionDisplayAnswerDialog`), `SHOWS` (`SettingShowsDialog`: `FontSizeDialog`, `TypeChoiceAnswerDialog`, `AudioVolumeDialog`, `AudioSpeedDialog`), `SHARE`, `REMINDER` (`ReminderDialog`), `FEEDBACK`, `RATE`, `POLICY`, `VERSION`, `MORE_APP`, `INTRODUCE_APP` (`IntroduceAppVC`), `FAQ` (`FaqVC`).
6. **Theory & Notebook Modals/Stacks**:
   - **Theory (`TheoryVC`)**: `TheoryDownloadView`, `TheoryContentView`, `VocabLessonView` (`VocabLessonVC` -> `FlashCardVC` -> `GameTheoryVC` with `DefineGameView` / `ChooseWordView`), `GrammarLessonView` (`GrammarLessonVC`).
   - **Notebook (`NotebookVC`)**: `MoreNotebookVC`, `DetailNotebookVC`, `MoreMyVocabVC`, `MoreMyQuesVC`, `DownloadDBVC`, `DetailWordDunnoVC` (`DunnoWordJSONObject` / Google Translate fallback).

## 6. Persistence Schemas (`CoreData`, `SQLite`, `UserDefaults`)

- **CoreData (`CoreData.momd`)**: 3 entities, each with `key: String?` and `value: String?`: `MigiiDB`, `WordDB`, `HistoryDB`.
- **SQLite Theory DB (`TheoryDbHelper` `0x1001d6b08..0x1001d71a0`)**:
  - `words(id, word, pronounce, level, descript_level, short_mean, means, snym, conjugation)`
  - `examples(id, e, m)`
  - `grammars(id, level, title, tag, related, contents)`
- **`UserDefaultHelper` (`0x100063214..0x100063ef8`)**: 90 documented keys including `language_app`, `font_size`, `audio_volume`, `audio_speed`, `auto_next_question`, `highlight_vocabulary`, `open_onboarding`, `setup_language`, `reminder`, `reminder_active`, `status_signin`, `user_profile`, `user_id`, `id_device`, `is_premium_check`, `is_premium_account_check`, `premium_package`, `history_practice`, `his_practice_v2`, `his_exam_v2`, `introduce_roadmap`, `level_roadmap`, `target_roadmap`, `part_kind_downloaded`, `type_choice_answer`, `listIdTheoryGrammarChecked`, `app_icon_change`, etc.

## 7. Backend API Contract (`https://toeic.migii.net/resapi/...` & Auxiliary Hosts)

- **Questions**: `Questions/{practice, practiceOffline, listExam, testExam, testMiniExam, evaluate, getQuestionById, getQuestionByIds, getQuantityQuestionIncorrect, getQuestionByIncorrect, errorQuestionReport}`
- **Users & Auth**: `Users/{timeServer, register, signin, signinWithApple, signinWithGmail, userDevice, updateUserDevice, userSynchronizedGet, userSynchronizedUpdate, userSyncPracticeList, userSyncPracticeInsert, userSyncPracticeGet, updateHistory, userPremiumGet, premiumTrial, countPurchaseGet, updateUserInformation, updateUserPassword, deleteAccount}`
- **Routes (Roadmap)**: `Routes/{detail, resetRoute, updateRoute, testEvaluateLevel, testEvaluateLevelResult}`
- **Events (Online Exam)**: `Events/{eventList, testOnline, testOnlineDetail, testOnlineResult, testOnlineHistory, testOnlineRank, userPrizeGet}`
- **Theories / History / IAP / Audio / Dict**: `Theories/userTheoryUpdate`, `History/userQuestionHistory`, `Devices/userDeviceManagerUpdate`, `verifieds/verifiedAppStore`, `https://migiitoeic.eupgroup.net/uploads/theory/{lang}/{lang}.zip`, `https://audio.eupgroup.net/audios/`, `https://audio.eupgroup.net/audio/getLink`, `https://api.dunno.ai/api/search/{language}/{type}/{key}`, `https://payments.eup.ai/migii-toeic/virtual-bill`, `https://product.eupgroup.net/resapi/ads/{adsInhouse, adsInhouseAction}`.
