import Foundation
import CoreData
import SQLite3
import AVFoundation
import Speech
import StoreKit

// MARK: - CoreDataManager (Port of NSPersistentContainer("CoreData") at 0x1004c93b8)
// Evidence: CoreData.momd entities: MigiiDB, WordDB, HistoryDB (key: String?, value: String?)

public final class CoreDataManager {
    public static let shared = CoreDataManager()

    public let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "CoreData")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                print("CoreData: Unresolved error \(error)")
            }
        }
        persistentContainer.viewContext.mergePolicy = NSMergePolicy.mergeByPropertyObjectTrump
    }

    public var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    public func saveContext() {
        guard context.hasChanges else { return }
        try? context.save()
    }

    public func upsert(entityName: String, key: String, value: String) {
        let req = NSFetchRequest<NSManagedObject>(entityName: entityName)
        req.predicate = NSPredicate(format: "key == %@", key)
        if let existing = try? context.fetch(req).first {
            existing.setValue(value, forKey: "value")
        } else if let desc = NSEntityDescription.entity(forEntityName: entityName, in: context) {
            let obj = NSManagedObject(entity: desc, insertInto: context)
            obj.setValue(key, forKey: "key")
            obj.setValue(value, forKey: "value")
        }
        saveContext()
    }

    public func fetchValue(entityName: String, key: String) -> String? {
        let req = NSFetchRequest<NSManagedObject>(entityName: entityName)
        req.predicate = NSPredicate(format: "key == %@", key)
        req.fetchLimit = 1
        return (try? context.fetch(req).first?.value(forKey: "value")) as? String
    }

    public func fetchAll(entityName: String) -> [(key: String, value: String)] {
        let req = NSFetchRequest<NSManagedObject>(entityName: entityName)
        let rows = (try? context.fetch(req)) ?? []
        return rows.compactMap { row in
            guard let k = row.value(forKey: "key") as? String,
                  let v = row.value(forKey: "value") as? String else { return nil }
            return (k, v)
        }
    }

    public func delete(entityName: String, key: String) {
        let req = NSFetchRequest<NSManagedObject>(entityName: entityName)
        req.predicate = NSPredicate(format: "key == %@", key)
        if let rows = try? context.fetch(req) {
            rows.forEach { context.delete($0) }
            saveContext()
        }
    }
}

// MARK: - TheoryDbHelper (Port of Migii_TOEIC_.TheoryDbHelper at 0x1001d6b08..0x1001d71a0)

public final class TheoryDbHelper {
    public static let shared = TheoryDbHelper()
    private var db: OpaquePointer?

    public var databaseURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return docs.appendingPathComponent("theory_\(LanguageManager.shared.currentOption.dataSuffix.lowercased()).db")
    }

    public var isDatabaseDownloaded: Bool {
        FileManager.default.fileExists(atPath: databaseURL.path)
    }

    @discardableResult
    public func openIfAvailable() -> Bool {
        if db != nil { return true }
        guard isDatabaseDownloaded else { return false }
        return sqlite3_open_v2(databaseURL.path, &db, SQLITE_OPEN_READONLY, nil) == SQLITE_OK
    }

    public func close() {
        if let db = db {
            sqlite3_close(db)
            self.db = nil
        }
    }

    // Port of query: "SELECT count(word) FROM words WHERE level == " (0x1001d71a0)
    public func countWords(level: String) -> Int {
        guard openIfAvailable(), let db = db else {
            return seededVocab(level: level).count
        }
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT count(word) FROM words WHERE level == ?"
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return 0 }
        sqlite3_bind_text(stmt, 1, level, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        if sqlite3_step(stmt) == SQLITE_ROW {
            return Int(sqlite3_column_int(stmt, 0))
        }
        return 0
    }

    public func fetchWords(level: String, limit: Int = 50, offset: Int = 0) -> [TheoryVocabObject] {
        guard openIfAvailable(), let db = db else {
            return seededVocab(level: level)
        }
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = "SELECT id, word, pronounce, level, descript_level, short_mean, means, snym, conjugation FROM words WHERE level == ? LIMIT ? OFFSET ?"
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            return seededVocab(level: level)
        }
        sqlite3_bind_text(stmt, 1, level, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        sqlite3_bind_int(stmt, 2, Int32(limit))
        sqlite3_bind_int(stmt, 3, Int32(offset))

        var out: [TheoryVocabObject] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(stmt, 0))
            let word = Self.colText(stmt, 1) ?? ""
            let pronounce = Self.colText(stmt, 2)
            let lvl = Self.colText(stmt, 3)
            let descLvl = Self.colText(stmt, 4)
            let shortMean = Self.colText(stmt, 5)
            let means = Self.colText(stmt, 6)
            let snym = Self.colText(stmt, 7)
            let conj = Self.colText(stmt, 8)
            var obj = TheoryVocabObject(id: id, word: word, pronounce: pronounce, level: lvl, descript_level: descLvl, short_mean: shortMean, means: means, snym: snym, conjugation: conj)
            if let meansData = means?.data(using: .utf8),
               let parsed = try? JSONDecoder().decode([TheoryVocabObject.MeansList].self, from: meansData) {
                obj.parsedMeans = parsed
            }
            out.append(obj)
        }
        return out.isEmpty ? seededVocab(level: level) : out
    }

    // Port of query: "SELECT count(id) FROM grammars WHERE level == " (0x10025a648)
    public func countGrammars(level: String? = nil) -> Int {
        guard openIfAvailable(), let db = db else {
            return seededGrammar(level: level).count
        }
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = level == nil ? "SELECT count(id) FROM grammars" : "SELECT count(id) FROM grammars WHERE level == ?"
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else { return 0 }
        if let lvl = level {
            sqlite3_bind_text(stmt, 1, lvl, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        }
        if sqlite3_step(stmt) == SQLITE_ROW {
            return Int(sqlite3_column_int(stmt, 0))
        }
        return 0
    }

    public func fetchGrammars(level: String? = nil) -> [TheoryGrammarObject] {
        guard openIfAvailable(), let db = db else {
            return seededGrammar(level: level)
        }
        var stmt: OpaquePointer?
        defer { sqlite3_finalize(stmt) }
        let sql = level == nil
            ? "SELECT id, level, title, tag, related, contents FROM grammars"
            : "SELECT id, level, title, tag, related, contents FROM grammars WHERE level == ?"
        guard sqlite3_prepare_v2(db, sql, -1, &stmt, nil) == SQLITE_OK else {
            return seededGrammar(level: level)
        }
        if let lvl = level {
            sqlite3_bind_text(stmt, 1, lvl, -1, unsafeBitCast(-1, to: sqlite3_destructor_type.self))
        }
        var out: [TheoryGrammarObject] = []
        while sqlite3_step(stmt) == SQLITE_ROW {
            let id = Int(sqlite3_column_int(stmt, 0))
            let lvl = Self.colText(stmt, 1)
            let title = Self.colText(stmt, 2) ?? ""
            let tag = Self.colText(stmt, 3)
            let related = Self.colText(stmt, 4)
            let contents = Self.colText(stmt, 5)
            var obj = TheoryGrammarObject(id: id, level: lvl, title: title, tag: tag, related: related, contents: contents)
            if let data = contents?.data(using: .utf8),
               let parsed = try? JSONDecoder().decode([TheoryGrammarObject.ContentObject].self, from: data) {
                obj.parsedContents = parsed
            }
            out.append(obj)
        }
        return out.isEmpty ? seededGrammar(level: level) : out
    }

    private static func colText(_ stmt: OpaquePointer?, _ idx: Int32) -> String? {
        guard let cstr = sqlite3_column_text(stmt, idx) else { return nil }
        return String(cString: cstr)
    }

    // Core TOEIC curriculum vocabulary so Vocabulary/Flashcard/Game flows are immediately usable offline
    public func seededVocab(level: String) -> [TheoryVocabObject] {
        let items: [(Int, String, String, String, String)] = [
            (1, "accomplish", "/əˈkɑːmplɪʃ/", level, "v. To succeed in finishing something"),
            (2, "allocate", "/ˈæləkeɪt/", level, "v. To distribute resources or duties for a purpose"),
            (3, "annual", "/ˈænjuəl/", level, "adj. Happening once every year"),
            (4, "approve", "/əˈpruːv/", level, "v. To officially agree to a request or budget"),
            (5, "candidate", "/ˈkændɪdət/", level, "n. A person applying for a job position"),
            (6, "collaborate", "/kəˈlæbəreɪt/", level, "v. To work jointly with others on a project"),
            (7, "comply", "/kəmˈplaɪ/", level, "v. To obey an official rule, safety standard, or policy"),
            (8, "conference", "/ˈkɑːnfərəns/", level, "n. A formal meeting for discussion"),
            (9, "confirm", "/kənˈfɜːrm/", level, "v. To verify attendance or a reservation"),
            (10, "deadline", "/ˈdedlaɪn/", level, "n. The latest time or date by which work must be finished"),
            (11, "delegate", "/ˈdelɪɡeɪt/", level, "v. To entrust a task to another team member"),
            (12, "efficient", "/ɪˈfɪʃnt/", level, "adj. Working productively with minimum wasted effort"),
            (13, "evaluate", "/ɪˈvæljueɪt/", level, "v. To assess performance or value carefully"),
            (14, "itinerary", "/aɪˈtɪnəreri/", level, "n. A planned business travel schedule"),
            (15, "merchandise", "/ˈmɜːrtʃəndaɪs/", level, "n. Goods to be bought and sold"),
            (16, "negotiate", "/nɪˈɡoʊʃieɪt/", level, "v. To try to reach a contract agreement"),
            (17, "postpone", "/poʊˈspoʊn/", level, "v. To reschedule to a later time"),
            (18, "reimburse", "/ˌriːɪmˈbɜːrs/", level, "v. To pay back business expenses incurred"),
            (19, "renovate", "/ˈrenəveɪt/", level, "v. To repair and improve a facility or office"),
            (20, "supervisor", "/ˈsuːpərvaɪzər/", level, "n. A person who manages workers or operations")
        ]
        return items.map {
            TheoryVocabObject(id: $0.0, word: $0.1, pronounce: $0.2, level: $0.3, descript_level: "TOEIC \($0.3)", short_mean: $0.4, means: nil, snym: nil, conjugation: nil)
        }
    }

    public func seededGrammar(level: String?) -> [TheoryGrammarObject] {
        let lvl = level ?? "450"
        return [
            TheoryGrammarObject(
                id: 1,
                level: lvl,
                title: "Subject-Verb Agreement",
                tag: "grammar",
                related: nil,
                contents: nil,
                parsedContents: [
                    TheoryGrammarObject.ContentObject(
                        sub_title: "Core Rule",
                        content: [
                            TheoryGrammarObject.Content(c: "A singular subject requires a singular verb, while a plural subject requires a plural verb.", f: "S(singular) + V(s/es)", e: [
                                TheoryGrammarObject.Example(e: "The annual report summarizes our quarterly growth."),
                                TheoryGrammarObject.Example(e: "Several employees attend the workshop every Friday.")
                            ])
                        ]
                    )
                ]
            ),
            TheoryGrammarObject(
                id: 2,
                level: lvl,
                title: "Conditional Sentences (Types 1, 2, 3)",
                tag: "grammar",
                related: nil,
                contents: nil,
                parsedContents: [
                    TheoryGrammarObject.ContentObject(
                        sub_title: "Business Conditionals",
                        content: [
                            TheoryGrammarObject.Content(c: "Type 1 states a realistic condition; Type 2 states an unreal present; Type 3 refers to past hypothetical results.", f: "If + Present Simple, will + V", e: [
                                TheoryGrammarObject.Example(e: "If the client signs today, we will ship tomorrow."),
                                TheoryGrammarObject.Example(e: "Had the team arrived earlier, the presentation would have started on time.")
                            ])
                        ]
                    )
                ]
            ),
            TheoryGrammarObject(
                id: 3,
                level: lvl,
                title: "Passive Voice in Business Writing",
                tag: "grammar",
                related: nil,
                contents: nil,
                parsedContents: [
                    TheoryGrammarObject.ContentObject(
                        sub_title: "Structure",
                        content: [
                            TheoryGrammarObject.Content(c: "Use passive voice when the action or recipient matters more than the agent.", f: "be + Past Participle (V3)", e: [
                                TheoryGrammarObject.Example(e: "All expense forms must be approved by Friday.")
                            ])
                        ]
                    )
                ]
            ),
            TheoryGrammarObject(
                id: 4,
                level: lvl,
                title: "Relative Clauses & Reduced Relatives",
                tag: "grammar",
                related: nil,
                contents: nil,
                parsedContents: [
                    TheoryGrammarObject.ContentObject(
                        sub_title: "Participle Reductions",
                        content: [
                            TheoryGrammarObject.Content(c: "Reduce active clauses with V-ing and passive clauses with V3.", f: "Noun + V-ing / V3", e: [
                                TheoryGrammarObject.Example(e: "Applicants submitting forms late will not be considered."),
                                TheoryGrammarObject.Example(e: "The proposal prepared by Marketing won approval.")
                            ])
                        ]
                    )
                ]
            ),
            TheoryGrammarObject(
                id: 5,
                level: lvl,
                title: "Prepositions vs Conjunctions",
                tag: "grammar",
                related: nil,
                contents: nil,
                parsedContents: [
                    TheoryGrammarObject.ContentObject(
                        sub_title: "High-Frequency TOEIC Part 5 Contrast",
                        content: [
                            TheoryGrammarObject.Content(c: "Despite / In spite of / During take noun phrases; Although / While / Because take S + V clauses.", f: "Prep + NP | Conj + S + V", e: [
                                TheoryGrammarObject.Example(e: "Despite the delay, the shipment arrived intact."),
                                TheoryGrammarObject.Example(e: "Although traffic was heavy, we arrived early.")
                            ])
                        ]
                    )
                ]
            )
        ]
    }
}

// MARK: - AudioPlayerManager (Port of PartAudioView / ExamAudioView / SpeakTextHelper)

public final class AudioPlayerManager: NSObject {
    public static let shared = AudioPlayerManager()
    private var player: AVPlayer?
    private var timeObserver: Any?
    private let synthesizer = AVSpeechSynthesizer()

    public var isPlaying: Bool {
        (player?.timeControlStatus == .playing) || synthesizer.isSpeaking
    }

    public func playURL(_ urlString: String, onProgress: ((Double, Double) -> Void)? = nil, onEnd: (() -> Void)? = nil) {
        stop()
        let fullString: String
        if urlString.hasPrefix("http") {
            fullString = urlString
        } else {
            fullString = "https://audio.eupgroup.net/audios/\(urlString)"
        }
        guard let url = URL(string: fullString) else { return }
        let item = AVPlayerItem(url: url)
        let p = AVPlayer(playerItem: item)
        p.volume = UserDefaultHelper.shared.audioVolume
        p.playImmediately(atRate: UserDefaultHelper.shared.audioSpeed)
        self.player = p

        timeObserver = p.addPeriodicTimeObserver(forInterval: CMTime(seconds: 0.25, preferredTimescale: 600), queue: .main) { [weak p] time in
            let current = time.seconds.isFinite ? time.seconds : 0
            let total = p?.currentItem?.duration.seconds ?? 0
            onProgress?(current, total.isFinite ? total : 0)
        }
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime, object: item, queue: .main) { _ in
            onEnd?()
        }
    }

    public func speakWord(_ text: String, slow: Bool = false) {
        synthesizer.stopSpeaking(at: .immediate)
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        utterance.rate = slow ? 0.36 : 0.48
        utterance.volume = UserDefaultHelper.shared.audioVolume
        synthesizer.speak(utterance)
    }

    public func togglePlayPause() {
        guard let player = player else { return }
        if player.timeControlStatus == .playing {
            player.pause()
        } else {
            player.playImmediately(atRate: UserDefaultHelper.shared.audioSpeed)
        }
    }

    public func stop() {
        if let obs = timeObserver, let player = player {
            player.removeTimeObserver(obs)
            timeObserver = nil
        }
        player?.pause()
        player = nil
        synthesizer.stopSpeaking(at: .immediate)
    }
}

// MARK: - SpeechAssist (Port of Migii_TOEIC_.SpeechAssist)

public final class SpeechAssist {
    public var onTranscriptUpdate: ((String) -> Void)?
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))

    public func requestPermissions(completion: @escaping (Bool) -> Void) {
        SFSpeechRecognizer.requestAuthorization { authStatus in
            DispatchQueue.main.async {
                completion(authStatus == .authorized)
            }
        }
    }

    public func startRecording() {
        stopRecording()
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playAndRecord, mode: .measurement, options: .duckOthers)
        try? session.setActive(true, options: .notifyOthersOnDeactivation)

        let req = SFSpeechAudioBufferRecognitionRequest()
        req.shouldReportPartialResults = true
        self.recognitionRequest = req

        let inputNode = audioEngine.inputNode
        let format = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: format) { buffer, _ in
            req.append(buffer)
        }

        audioEngine.prepare()
        try? audioEngine.start()

        recognitionTask = speechRecognizer?.recognitionTask(with: req) { [weak self] result, _ in
            if let text = result?.bestTranscription.formattedString {
                DispatchQueue.main.async { self?.onTranscriptUpdate?(text) }
            }
        }
    }

    public func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}

// MARK: - StoreKitManager (Port of SwiftyStoreKit / InvoicesSkuVC / HomeVC SKUs)

public final class StoreKitManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    public static let shared = StoreKitManager()
    public static let premiumChangedNotification = Notification.Name("MigiiPremiumChanged")

    // Exact SKU IDs from HomeVC (0x100096470..0x100096be8)
    public static let allProductIDs: [String] = [
        "migii_toeic_3_days",
        "migii_toeic_5_days",
        "migii_toeic_7_days",
        "migii_toeic_15_days",
        "migii_toeic_1months_auto",
        "migii_toeic_3months_auto",
        "migii_toeic_3months_auto_sale",
        "migii_toeic_6months_auto",
        "migii_toeic_6months_auto_sale",
        "migii_toeic_12months_auto",
        "migii_toeic_12months_auto_sale",
        "migii_toeic_preforever",
        "migii_toeic_preforever_sale",
        "migii_toeic_custom"
    ]

    public struct DisplayPlan {
        public let productID: String
        public let title: String
        public let subtitle: String
        public let defaultPrice: String
        public let badge: String?
    }

    public static let defaultPlans: [DisplayPlan] = [
        DisplayPlan(productID: "migii_toeic_3months_auto", title: "3 Months", subtitle: "Flexible short-term sprint", defaultPrice: "$9.99", badge: nil),
        DisplayPlan(productID: "migii_toeic_12months_auto", title: "12 Months", subtitle: "Full TOEIC roadmap + All parts", defaultPrice: "$19.99", badge: "Popular"),
        DisplayPlan(productID: "migii_toeic_preforever", title: "Lifetime", subtitle: "One-time purchase, forever access", defaultPrice: "$34.99", badge: "Best Choice")
    ]

    public private(set) var products: [SKProduct] = []
    private var request: SKProductsRequest?

    private override init() {
        super.init()
        SKPaymentQueue.default().add(self)
    }

    public func fetchProducts() {
        request?.cancel()
        let req = SKProductsRequest(productIdentifiers: Set(Self.allProductIDs))
        req.delegate = self
        req.start()
        self.request = req
    }

    public func purchase(productID: String) {
        if let product = products.first(where: { $0.productIdentifier == productID }), SKPaymentQueue.canMakePayments() {
            SKPaymentQueue.default().add(SKPayment(product: product))
        }
    }

    public func restorePurchases() {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }

    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async { self.products = response.products }
    }

    public func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for tx in transactions {
            switch tx.transactionState {
            case .purchased, .restored:
                UserDefaultHelper.shared.isPremiumCheck = true
                UserDefaultHelper.shared.premiumPackage = tx.payment.productIdentifier
                NotificationCenter.default.post(name: Self.premiumChangedNotification, object: nil)
                queue.finishTransaction(tx)
            case .failed:
                queue.finishTransaction(tx)
            default:
                break
            }
        }
    }
}
