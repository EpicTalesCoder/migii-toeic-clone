import Foundation
import Security
import UserNotifications

// Port of Migii_TOEIC_.UserDefaultHelper (0x100063214..0x100063ef8)
// Port of Migii_TOEIC_.LanguageManager & KeychainItem & PushNotiLocalHelper

public final class UserDefaultHelper {
    public static let shared = UserDefaultHelper()
    private let defaults: UserDefaults

    public enum Keys {
        public static let firstOpenApp = "first_open_app"
        public static let statusHeight = "status_height_v2"
        public static let fontSize = "font_size"
        public static let audioVolume = "audio_volume"
        public static let audioSpeed = "audio_speed"
        public static let autoNextQuestion = "auto_next_question"
        public static let highLightVocabulary = "highlight_vocabulary"
        public static let languageApp = "language_app"
        public static let countryCode = "country_code"
        public static let openOnboarding = "open_onboarding"
        public static let setupLanguage = "setup_language"
        public static let reminder = "reminder"
        public static let reminderActive = "reminder_active"
        public static let statusSignin = "status_signin"
        public static let userProfile = "user_profile"
        public static let userId = "user_id"
        public static let idDevice = "id_device"
        public static let timeServer = "time_server"
        public static let adsInHouse = "ads_in_house"
        public static let adsShowTop1 = "ads_show_top_1"
        public static let specialPremium24h = "special_premium_24h"
        public static let lastTimePushSale = "last_time_push_sale"
        public static let kListIdentifiersNoti = "kListIdentifiersNoti"
        public static let kCountOpenPremium = "kCountOpenPremium"
        public static let timeSaleBadge = "time_sale_badge"
        public static let isPremiumCheck = "is_premium_check"
        public static let isPremiumAccountCheck = "is_premium_account_check"
        public static let premiumPackage = "premium_package"
        public static let purchasedTime = "purchased_time"
        public static let numberQuestionStart = "number_question_start"
        public static let askSubmitPractice = "ask_submit_practice"
        public static let syncDeviceIdLater = "sync_device_id_later"
        public static let levelTheory = "level_theory_v3"
        public static let lessonTheory = "lesson_theory"
        public static let numberQuestionJson = "number_question_json"
        public static let idsDid = "ids_did"
        public static let idsDidCorrect = "ids_did_correct"
        public static let quesDidTotal = "ques_did_total"
        public static let quesDidTrue = "ques_did_true"
        public static let historyPracticeSync = "history_practice_sync"
        public static let examListJson = "exam_list_json"
        public static let examStatusList = "exam_status_list"
        public static let historyPractice = "history_practice"
        public static let hisPracticeV2 = "his_practice_v2"
        public static let hisExamV2 = "his_exam_v2"
        public static let syncDataHisPracticeLocal = "syncDataHisPracticeLocal"
        public static let listDataSyncPracticeLater = "listDataSyncPracticeLater"
        public static let skuPrice = "sku_price"
        public static let skuPriceLong = "sku_price_long"
        public static let skuCurrency = "sku_currency"
        public static let introduceRoadmap = "introduce_roadmap"
        public static let levelRoadmap = "level_roadmap"
        public static let targetRoadmap = "target_roadmap"
        public static let roadmapEntrance = "roadmap_entrance"
        public static let resultRoadmapEntrance = "result_roadmap_entrance"
        public static let syncRoadmapLater = "sync_roadmap_later"
        public static let startRoadmap = "start_roadmap"
        public static let dataEvaluateRoadmap = "data_evaluate_roadmap"
        public static let roadmapDataPractice = "roadmap_data_practice"
        public static let roadmapDataComplete = "roadmap_data_complete"
        public static let bannerIos = "banner_ios"
        public static let interstitialIos = "interstitial_ios"
        public static let probBannerIos = "prob_banner_ios"
        public static let probInterstitialIos = "prob_interstitial_ios"
        public static let probNativeIos = "prob_native_ios"
        public static let probAdpressIos = "prob_adpress_ios"
        public static let probIntervalAdsInterIos = "prob_intervalAdsInter_ios"
        public static let lastTimeClickAds = "last_time_click_ads"
        public static let lastTimeShowInterstitial = "last_time_show_interstitial"
        public static let allowShowInterstitial = "allow_show_interstitial"
        public static let partKindDownloaded = "part_kind_downloaded"
        public static let typeChoiceAnswer = "type_choice_answer"
        public static let showDialogTypeChoiceAnswer = "show_dialog_type_choice_answer"
        public static let synchronized = "synchronized"
        public static let syncProcessLocal = "syncProcessLocal"
        public static let synchronizedLater = "synchronizedLater"
        public static let autoLogOut = "auto_log_out"
        public static let listObjectNotifyExamOnline = "listObjectNotifyExamOnline"
        public static let listSyncExamOnlineLater = "listSyncExamOnlineLater"
        public static let showBadgeHotExamOnline = "showBadgeHotExamOnline"
        public static let syncPremiumAccount = "sync_premium_account"
        public static let jsonCustomDataNotify = "jsonCustomDataNotify"
        public static let appIconChange = "app_icon_change"
        public static let lastTimeEndEvent = "lastTimeEndEvent"
        public static let userPrize = "user_prize"
        public static let jsonTheoryTest = "json_theory_test"
        public static let listIdTheoryGrammarChecked = "listIdTheoryGrammarChecked"
        public static let roadmapExamCached = "roadmap_exam_cached"
        public static let transferInforConfig = "transfer_infor_config"
    }

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        self.defaults.register(defaults: [
            Keys.firstOpenApp: true,
            Keys.fontSize: 16,
            Keys.audioVolume: Float(1.0),
            Keys.audioSpeed: Float(1.0),
            Keys.autoNextQuestion: true,
            Keys.highLightVocabulary: true,
            Keys.askSubmitPractice: true,
            Keys.typeChoiceAnswer: 0, // 0 = bottom_screen, 1 = above_the_topic
            Keys.levelTheory: "450",
            Keys.lessonTheory: 1,
            Keys.reminder: "20:00",
            Keys.levelRoadmap: 450,
            Keys.targetRoadmap: 750
        ])
    }

    public var firstOpenApp: Bool {
        get { defaults.bool(forKey: Keys.firstOpenApp) }
        set { defaults.set(newValue, forKey: Keys.firstOpenApp) }
    }

    public var openOnboarding: Bool {
        get { defaults.bool(forKey: Keys.openOnboarding) }
        set { defaults.set(newValue, forKey: Keys.openOnboarding) }
    }

    public var languageApp: String {
        get { defaults.string(forKey: Keys.languageApp) ?? LanguageManager.defaultDeviceLanguageCode() }
        set { defaults.set(newValue, forKey: Keys.languageApp) }
    }

    public var countryCode: String {
        get { defaults.string(forKey: Keys.countryCode) ?? (Locale.current.region?.identifier ?? "US") }
        set { defaults.set(newValue, forKey: Keys.countryCode) }
    }

    public var fontSize: Int {
        get { max(12, defaults.integer(forKey: Keys.fontSize)) }
        set { defaults.set(newValue, forKey: Keys.fontSize) }
    }

    public var audioVolume: Float {
        get { defaults.float(forKey: Keys.audioVolume) }
        set { defaults.set(max(0.0, min(1.0, newValue)), forKey: Keys.audioVolume) }
    }

    public var audioSpeed: Float {
        get {
            let v = defaults.float(forKey: Keys.audioSpeed)
            return v > 0 ? v : 1.0
        }
        set { defaults.set(max(0.5, min(2.0, newValue)), forKey: Keys.audioSpeed) }
    }

    public var autoNextQuestion: Bool {
        get { defaults.bool(forKey: Keys.autoNextQuestion) }
        set { defaults.set(newValue, forKey: Keys.autoNextQuestion) }
    }

    public var highLightVocabulary: Bool {
        get { defaults.bool(forKey: Keys.highLightVocabulary) }
        set { defaults.set(newValue, forKey: Keys.highLightVocabulary) }
    }

    public var typeChoiceAnswer: Int {
        get { defaults.integer(forKey: Keys.typeChoiceAnswer) }
        set { defaults.set(newValue, forKey: Keys.typeChoiceAnswer) }
    }

    public var reminder: String {
        get { defaults.string(forKey: Keys.reminder) ?? "20:00" }
        set { defaults.set(newValue, forKey: Keys.reminder) }
    }

    public var reminderActive: Bool {
        get { defaults.bool(forKey: Keys.reminderActive) }
        set { defaults.set(newValue, forKey: Keys.reminderActive) }
    }

    public var statusSignin: Bool {
        get { defaults.bool(forKey: Keys.statusSignin) }
        set { defaults.set(newValue, forKey: Keys.statusSignin) }
    }

    public var userId: Int {
        get { defaults.integer(forKey: Keys.userId) }
        set { defaults.set(newValue, forKey: Keys.userId) }
    }

    public var idDevice: String {
        get {
            if let existing = defaults.string(forKey: Keys.idDevice), !existing.isEmpty {
                return existing
            }
            let generated = UUID().uuidString
            defaults.set(generated, forKey: Keys.idDevice)
            return generated
        }
        set { defaults.set(newValue, forKey: Keys.idDevice) }
    }

    public var isPremium: Bool {
        get { defaults.bool(forKey: Keys.isPremiumCheck) || defaults.bool(forKey: Keys.isPremiumAccountCheck) }
    }

    public var isPremiumCheck: Bool {
        get { defaults.bool(forKey: Keys.isPremiumCheck) }
        set { defaults.set(newValue, forKey: Keys.isPremiumCheck) }
    }

    public var isPremiumAccountCheck: Bool {
        get { defaults.bool(forKey: Keys.isPremiumAccountCheck) }
        set { defaults.set(newValue, forKey: Keys.isPremiumAccountCheck) }
    }

    public var premiumPackage: String {
        get { defaults.string(forKey: Keys.premiumPackage) ?? "" }
        set { defaults.set(newValue, forKey: Keys.premiumPackage) }
    }

    public var levelTheory: String {
        get { defaults.string(forKey: Keys.levelTheory) ?? "450" }
        set { defaults.set(newValue, forKey: Keys.levelTheory) }
    }

    public var lessonTheory: Int {
        get { max(1, defaults.integer(forKey: Keys.lessonTheory)) }
        set { defaults.set(newValue, forKey: Keys.lessonTheory) }
    }

    public var introduceRoadmap: Bool {
        get { defaults.bool(forKey: Keys.introduceRoadmap) }
        set { defaults.set(newValue, forKey: Keys.introduceRoadmap) }
    }

    public var levelRoadmap: Int {
        get { defaults.integer(forKey: Keys.levelRoadmap) }
        set { defaults.set(newValue, forKey: Keys.levelRoadmap) }
    }

    public var targetRoadmap: Int {
        get { defaults.integer(forKey: Keys.targetRoadmap) }
        set { defaults.set(newValue, forKey: Keys.targetRoadmap) }
    }

    public var startRoadmap: Bool {
        get { defaults.bool(forKey: Keys.startRoadmap) }
        set { defaults.set(newValue, forKey: Keys.startRoadmap) }
    }

    public var partKindDownloaded: [String] {
        get { defaults.stringArray(forKey: Keys.partKindDownloaded) ?? [] }
        set { defaults.set(newValue, forKey: Keys.partKindDownloaded) }
    }

    public var checkedGrammarIds: [Int] {
        get { (defaults.array(forKey: Keys.listIdTheoryGrammarChecked) as? [Int]) ?? [] }
        set { defaults.set(newValue, forKey: Keys.listIdTheoryGrammarChecked) }
    }

    public func saveCodable<T: Encodable>(_ value: T?, forKey key: String) {
        guard let value = value else {
            defaults.removeObject(forKey: key)
            return
        }
        if let data = try? JSONEncoder().encode(value) {
            defaults.set(data, forKey: key)
        }
    }

    public func loadCodable<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = defaults.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(type, from: data)
    }

    public func saveUserProfile(_ user: UserProfileJSONObject.User?) {
        saveCodable(user, forKey: Keys.userProfile)
        userId = user?.id ?? 0
        statusSignin = (user != nil)
    }

    public func loadUserProfile() -> UserProfileJSONObject.User? {
        loadCodable(UserProfileJSONObject.User.self, forKey: Keys.userProfile)
    }

    public func saveHistoryList(_ list: [PracticeHistoryResultObject]) {
        saveCodable(list, forKey: Keys.hisPracticeV2)
    }

    public func loadHistoryList() -> [PracticeHistoryResultObject] {
        loadCodable([PracticeHistoryResultObject].self, forKey: Keys.hisPracticeV2) ?? []
    }

    public func appendPracticeHistory(_ item: PracticeHistoryResultObject) {
        var list = loadHistoryList()
        list.insert(item, at: 0)
        saveHistoryList(list)
    }

    public func loadExamHistoryList() -> [ExamHistoryResultObject] {
        loadCodable([ExamHistoryResultObject].self, forKey: Keys.hisExamV2) ?? []
    }

    public func appendExamHistory(_ item: ExamHistoryResultObject) {
        var list = loadExamHistoryList()
        list.insert(item, at: 0)
        saveCodable(list, forKey: Keys.hisExamV2)
    }
}

// MARK: - LanguageManager (Port of Migii_TOEIC_.LanguageManager + 12 .lproj bundles)

public final class LanguageManager {
    public static let shared = LanguageManager()
    public static let languageDidChangeNotification = Notification.Name("MigiiLanguageDidChange")

    public struct LanguageOption {
        public let code: String        // lproj folder name
        public let dataSuffix: String  // dataMigii<Suffix>.json
        public let explainKey: String  // ExplainAll property code
        public let displayName: String
        public let iconName: String
    }

    public static let supportedLanguages: [LanguageOption] = [
        LanguageOption(code: "en", dataSuffix: "EN", explainKey: "en", displayName: "English", iconName: "ic_flag_english_round"),
        LanguageOption(code: "vi", dataSuffix: "VN", explainKey: "vi", displayName: "Tiếng Việt", iconName: "ic_flag_vietnam_round"),
        LanguageOption(code: "ja", dataSuffix: "JA", explainKey: "ja", displayName: "日本語", iconName: "ic_flag_japan_round"),
        LanguageOption(code: "ko", dataSuffix: "KO", explainKey: "ko", displayName: "한국어", iconName: "ic_flag_korea_round"),
        LanguageOption(code: "zh-Hans", dataSuffix: "CN", explainKey: "zhCN", displayName: "简体中文", iconName: "ic_flag_china_round"),
        LanguageOption(code: "zh-Hant", dataSuffix: "TW", explainKey: "zhTW", displayName: "繁體中文", iconName: "ic_flag_taiwan_round"),
        LanguageOption(code: "fr", dataSuffix: "FR", explainKey: "fr", displayName: "Français", iconName: "ic_flag_french_round"),
        LanguageOption(code: "de", dataSuffix: "DE", explainKey: "de", displayName: "Deutsch", iconName: "ic_flag_germany_round"),
        LanguageOption(code: "es", dataSuffix: "ES", explainKey: "es", displayName: "Español", iconName: "ic_flag_spain_round"),
        LanguageOption(code: "pt-PT", dataSuffix: "PT", explainKey: "pt", displayName: "Português", iconName: "ic_flag_portugal_round"),
        LanguageOption(code: "id", dataSuffix: "ID", explainKey: "id", displayName: "Bahasa Indonesia", iconName: "ic_flag_indonesia_round"),
        LanguageOption(code: "th", dataSuffix: "TH", explainKey: "th", displayName: "ภาษาไทย", iconName: "ic_flag_thailand_round")
    ]

    public private(set) var currentCode: String

    private init() {
        let saved = UserDefaults.standard.string(forKey: UserDefaultHelper.Keys.languageApp)
        self.currentCode = saved ?? Self.defaultDeviceLanguageCode()
    }

    public static func defaultDeviceLanguageCode() -> String {
        let preferred = Locale.preferredLanguages.first ?? "en"
        if preferred.hasPrefix("vi") { return "vi" }
        if preferred.hasPrefix("ja") { return "ja" }
        if preferred.hasPrefix("ko") { return "ko" }
        if preferred.hasPrefix("zh-Hans") || preferred.hasPrefix("zh-CN") { return "zh-Hans" }
        if preferred.hasPrefix("zh-Hant") || preferred.hasPrefix("zh-TW") { return "zh-Hant" }
        if preferred.hasPrefix("fr") { return "fr" }
        if preferred.hasPrefix("de") { return "de" }
        if preferred.hasPrefix("es") { return "es" }
        if preferred.hasPrefix("pt") { return "pt-PT" }
        if preferred.hasPrefix("id") { return "id" }
        if preferred.hasPrefix("th") { return "th" }
        return "en"
    }

    public var currentOption: LanguageOption {
        Self.supportedLanguages.first { $0.code == currentCode } ?? Self.supportedLanguages[0]
    }

    public func setLanguage(_ code: String) {
        currentCode = code
        UserDefaultHelper.shared.languageApp = code
        NotificationCenter.default.post(name: Self.languageDidChangeNotification, object: nil)
    }

    public func localized(_ key: String, defaultValue: String? = nil) -> String {
        if let path = Bundle.main.path(forResource: currentCode, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            let value = bundle.localizedString(forKey: key, value: "\u{0}", table: nil)
            if value != "\u{0}" { return value }
        }
        if let enPath = Bundle.main.path(forResource: "en", ofType: "lproj"),
           let enBundle = Bundle(path: enPath) {
            let value = enBundle.localizedString(forKey: key, value: "\u{0}", table: nil)
            if value != "\u{0}" { return value }
        }
        return defaultValue ?? NSLocalizedString(key, comment: "")
    }
}

public func tr(_ key: String, _ fallback: String? = nil) -> String {
    LanguageManager.shared.localized(key, defaultValue: fallback)
}

// MARK: - KeychainItem (Port of Migii_TOEIC_.KeychainItem)

public struct KeychainItem {
    public enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError(status: OSStatus)
    }

    public let service: String
    public let account: String

    public init(service: String = "com.rebuild.migiitoeic", account: String) {
        self.service = service
        self.account = account
    }

    public func readPassword() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecMatchLimit as String: kSecMatchLimitOne,
            kSecReturnAttributes as String: true,
            kSecReturnData as String: true
        ]
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        guard let existing = item as? [String: Any],
              let passwordData = existing[kSecValueData as String] as? Data,
              let password = String(data: passwordData, encoding: .utf8) else {
            throw KeychainError.unexpectedPasswordData
        }
        return password
    }

    public func savePassword(_ password: String) throws {
        guard let encoded = password.data(using: .utf8) else { throw KeychainError.unexpectedPasswordData }
        do {
            _ = try readPassword()
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account
            ]
            let attributes: [String: Any] = [kSecValueData as String: encoded]
            let status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        } catch KeychainError.noPassword {
            let newItem: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: service,
                kSecAttrAccount as String: account,
                kSecValueData as String: encoded
            ]
            let status = SecItemAdd(newItem as CFDictionary, nil)
            guard status == noErr else { throw KeychainError.unhandledError(status: status) }
        }
    }

    public func deleteItem() throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        let status = SecItemDelete(query as CFDictionary)
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError(status: status) }
    }
}

// MARK: - PushNotiLocalHelper (Port of Migii_TOEIC_.PushNotiLocalHelper)

public final class PushNotiLocalHelper {
    public static let shared = PushNotiLocalHelper()
    private let dailyIdentifier = "migii_toeic_daily_reminder"

    public func scheduleDailyReminder(timeString: String, active: Bool) {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: [dailyIdentifier])
        guard active else { return }

        let parts = timeString.split(separator: ":").compactMap { Int($0) }
        guard parts.count == 2 else { return }

        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = "Migii TOEIC"
            content.body = tr("reminder_content", "It's time to study TOEIC! Keep up your daily goal.")
            content.sound = .default

            var dc = DateComponents()
            dc.hour = parts[0]
            dc.minute = parts[1]
            let trigger = UNCalendarNotificationTrigger(dateMatching: dc, repeats: true)
            let request = UNNotificationRequest(identifier: self.dailyIdentifier, content: content, trigger: trigger)
            center.add(request)
        }
    }
}
