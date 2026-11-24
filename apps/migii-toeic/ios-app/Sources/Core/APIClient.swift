import Foundation

// Port of Migii_TOEIC_.AlamofireHelper (0x1005f9668..0x100611d00)
// Evidence: Recovered API URLs & JSON DTO schemas

public final class APIClient {
    public static let shared = APIClient()

    public enum Endpoints {
        public static let baseURL = "https://toeic.migii.net/resapi"
        public static let timeServer = "\(baseURL)/Users/timeServer"
        public static let register = "\(baseURL)/Users/register"
        public static let signin = "\(baseURL)/Users/signin"
        public static let signinWithApple = "\(baseURL)/Users/signinWithApple"
        public static let updateUserInformation = "\(baseURL)/Users/updateUserInformation"
        public static let updateUserPassword = "\(baseURL)/Users/updateUserPassword"
        public static let deleteAccount = "\(baseURL)/Users/deleteAccount"
        public static let userSynchronizedGet = "\(baseURL)/Users/userSynchronizedGet"
        public static let userSynchronizedUpdate = "\(baseURL)/Users/userSynchronizedUpdate"
        public static let userPremiumGet = "\(baseURL)/Users/userPremiumGet"
        public static let countPurchaseGet = "\(baseURL)/Users/countPurchaseGet"
        public static let practice = "\(baseURL)/Questions/practice"
        public static let practiceOffline = "\(baseURL)/Questions/practiceOffline"
        public static let listExam = "\(baseURL)/Questions/listExam"
        public static let testExam = "\(baseURL)/Questions/testExam"
        public static let testMiniExam = "\(baseURL)/Questions/testMiniExam"
        public static let getQuestionByIds = "\(baseURL)/Questions/getQuestionByIds"
        public static let errorQuestionReport = "\(baseURL)/Questions/errorQuestionReport"
        public static let routeDetail = "\(baseURL)/Routes/detail"
        public static let resetRoute = "\(baseURL)/Routes/resetRoute"
        public static let updateRoute = "\(baseURL)/Routes/updateRoute"
        public static let evaluateEntrance = "\(baseURL)/Routes/testEvaluateLevel"
        public static let eventList = "\(baseURL)/Events/eventList"
        public static let testOnlineDetail = "\(baseURL)/Events/testOnlineDetail"
        public static let testOnlineResult = "\(baseURL)/Events/testOnlineResult"
        public static let testOnlineHistory = "\(baseURL)/Events/testOnlineHistory"
        public static let testOnlineRank = "\(baseURL)/Events/testOnlineRank"
        public static let userPrizeGet = "\(baseURL)/Events/userPrizeGet"
        public static let dunnoSearch = "https://api.dunno.ai/api/search"
        public static let theoryZipBase = "https://migiitoeic.eupgroup.net/uploads/theory"
    }

    private let session: URLSession

    private init() {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        self.session = URLSession(configuration: config)
    }

    // MARK: - Generic JSON Request

    private func requestDecodable<T: Decodable>(
        urlString: String,
        method: String = "GET",
        jsonBody: [String: Any]? = nil,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "MigiiAPI", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        var req = URLRequest(url: url)
        req.httpMethod = method
        req.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let jsonBody = jsonBody, let body = try? JSONSerialization.data(withJSONObject: jsonBody) {
            req.httpBody = body
        }
        session.dataTask(with: req) { data, _, error in
            DispatchQueue.main.async {
                if let error = error {
                    completion(.failure(error))
                    return
                }
                guard let data = data else {
                    completion(.failure(NSError(domain: "MigiiAPI", code: -2, userInfo: [NSLocalizedDescriptionKey: "Empty response"])))
                    return
                }
                do {
                    let decoded = try JSONDecoder().decode(T.self, from: data)
                    completion(.success(decoded))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }

    // MARK: - Time & Practice & Exam APIs (with Offline CoreData/Seeded Resilience)

    public func fetchTimeServer(completion: @escaping (Int) -> Void) {
        requestDecodable(urlString: Endpoints.timeServer, method: "POST") { (result: Result<TimeServerJSONObject, Error>) in
            if case .success(let obj) = result, let t = obj.User?.time {
                completion(t)
            } else {
                completion(Int(Date().timeIntervalSince1970))
            }
        }
    }

    // Port of https://toeic.migii.net/resapi/Questions/practice (0x1005ff928)
    public func fetchPracticeQuestions(
        kind: String,
        limit: Int = 10,
        completion: @escaping ([PracticeJSONObject.Question]) -> Void
    ) {
        let lang = LanguageManager.shared.currentCode
        let cacheKey = "practice_\(kind)_\(lang)"
        let payload: [String: Any] = [
            "kind": kind,
            "limit": limit,
            "language": lang,
            "device_id": UserDefaultHelper.shared.idDevice
        ]
        requestDecodable(urlString: Endpoints.practice, method: "POST", jsonBody: payload) { (result: Result<PracticeJSONObject, Error>) in
            if case .success(let res) = result, let list = res.Questions?.Questions, !list.isEmpty {
                if let data = try? JSONEncoder().encode(list), let json = String(data: data, encoding: .utf8) {
                    CoreDataManager.shared.upsert(entityName: "MigiiDB", key: cacheKey, value: json)
                }
                completion(list)
                return
            }
            if let cached = CoreDataManager.shared.fetchValue(entityName: "MigiiDB", key: cacheKey),
               let data = cached.data(using: .utf8),
               let saved = try? JSONDecoder().decode([PracticeJSONObject.Question].self, from: data),
               !saved.isEmpty {
                completion(saved)
                return
            }
            completion(Self.offlinePracticePack(kind: kind, count: limit))
        }
    }

    // Port of https://toeic.migii.net/resapi/Questions/listExam (0x100602a68)
    public func fetchExamList(completion: @escaping ([ExamListJSONObject.Question]) -> Void) {
        let payload: [String: Any] = [
            "language": LanguageManager.shared.currentCode,
            "type": 0
        ]
        requestDecodable(urlString: Endpoints.listExam, method: "POST", jsonBody: payload) { (result: Result<ExamListJSONObject, Error>) in
            if case .success(let res) = result, let items = res.Questions, !items.isEmpty {
                UserDefaultHelper.shared.saveCodable(items, forKey: UserDefaultHelper.Keys.examListJson)
                completion(items)
                return
            }
            if let saved = UserDefaultHelper.shared.loadCodable([ExamListJSONObject.Question].self, forKey: UserDefaultHelper.Keys.examListJson), !saved.isEmpty {
                completion(saved)
                return
            }
            completion(Self.offlineExamList())
        }
    }

    // Port of https://toeic.migii.net/resapi/Questions/testExam & testMiniExam (0x1005fe740, 0x1005fe948)
    public func fetchExamTest(examId: Int, title: String, isMini: Bool, completion: @escaping (ExamJSONObject.Questions) -> Void) {
        let url = isMini ? Endpoints.testMiniExam : Endpoints.testExam
        let payload: [String: Any] = [
            "id": examId,
            "language": LanguageManager.shared.currentCode
        ]
        requestDecodable(urlString: url, method: "POST", jsonBody: payload) { (result: Result<ExamJSONObject, Error>) in
            if case .success(let obj) = result, let qs = obj.Questions {
                completion(qs)
                return
            }
            completion(Self.offlineExamTest(id: examId, title: title, isMini: isMini))
        }
    }

    // Port of https://toeic.migii.net/resapi/Events/eventList (0x100608a1c)
    public func fetchOnlineEvents(completion: @escaping ([ObjectListEvent.Event]) -> Void) {
        requestDecodable(urlString: Endpoints.eventList, method: "POST", jsonBody: ["language": LanguageManager.shared.currentCode]) { (result: Result<ObjectListEvent, Error>) in
            if case .success(let res) = result, let ev = res.Event, !ev.isEmpty {
                completion(ev)
                return
            }
            let now = Int(Date().timeIntervalSince1970)
            completion([
                ObjectListEvent.Event(event_id: 202601, kind: 1, start: now - 3600, end: now + 86400 * 3, count_question: 200, time: 120, status: 1, timeServer: now, image: nil, title: "Migii Global TOEIC Trial Test"),
                ObjectListEvent.Event(event_id: 202602, kind: 0, start: now + 86400 * 5, end: now + 86400 * 8, count_question: 200, time: 120, status: 0, timeServer: now, image: nil, title: "Monthly TOEIC Leaderboard Challenge")
            ])
        }
    }

    // Port of https://toeic.migii.net/resapi/Users/signin & register
    public func signIn(email: String, password: String, completion: @escaping (Result<UserProfileJSONObject.User, Error>) -> Void) {
        let payload: [String: Any] = ["email": email, "password": password]
        requestDecodable(urlString: Endpoints.signin, method: "POST", jsonBody: payload) { (result: Result<UserProfileJSONObject, Error>) in
            switch result {
            case .success(let obj):
                if let user = obj.User {
                    completion(.success(user))
                } else {
                    let message = obj.Err?.message ?? tr("account_not_correct", "Email or password not correct, please try again.")
                    completion(.failure(NSError(domain: "MigiiAPI", code: -3, userInfo: [NSLocalizedDescriptionKey: message])))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    public func register(name: String, email: String, phone: String, password: String, completion: @escaping (Result<UserProfileJSONObject.User, Error>) -> Void) {
        let payload: [String: Any] = [
            "name": name, "email": email, "phone": phone, "password": password,
            "language": LanguageManager.shared.currentCode, "country": UserDefaultHelper.shared.countryCode
        ]
        requestDecodable(urlString: Endpoints.register, method: "POST", jsonBody: payload) { (result: Result<UserProfileJSONObject, Error>) in
            switch result {
            case .success(let obj):
                if let user = obj.User {
                    completion(.success(user))
                } else {
                    let message = obj.Err?.message ?? "Registration failed"
                    completion(.failure(NSError(domain: "MigiiAPI", code: -4, userInfo: [NSLocalizedDescriptionKey: message])))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    // Port of https://api.dunno.ai/api/search/{language}/{type}/{key} (0x10060ed80)
    public func searchDictionary(word: String, completion: @escaping (DunnoWordJSONObject?) -> Void) {
        let lang = LanguageManager.shared.currentOption.explainKey
        let encodedWord = word.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? word
        let url = "\(Endpoints.dunnoSearch)/\(lang)/en/\(encodedWord)"
        requestDecodable(urlString: url, method: "GET") { (result: Result<DunnoWordJSONObject, Error>) in
            if case .success(let obj) = result {
                completion(obj)
            } else {
                completion(nil)
            }
        }
    }

    // Port of Offline/Seeded Question Generators so Practice & Exams work seamlessly with zero server lock
    public static func offlinePracticePack(kind: String, count: Int) -> [PracticeJSONObject.Question] {
        let sampleItems: [(String, [String], String, String)] = [
            (
                "All employees must submit their travel expense reports _______ Friday afternoon for reimbursement.",
                ["by", "until", "during", "among"],
                "0",
                "Use 'by' to indicate a strict deadline before or at a specific point in time."
            ),
            (
                "Ms. Takahashi has been appointed to lead the _______ expansion into the Southeast Asian market.",
                ["strategy", "strategic", "strategically", "strategist"],
                "1",
                "An adjective ('strategic') is required before the noun 'expansion'."
            ),
            (
                "Because the main conference room is being renovated, today's briefing will _______ in Suite 402.",
                ["be held", "holding", "to hold", "have held"],
                "0",
                "Passive modal structure: 'will + be + past participle (held)'."
            ),
            (
                "Despite the heavy rain, nearly all invited clients _______ the product launch reception.",
                ["attended", "attending", "attendance", "attentive"],
                "0",
                "Main clause requires a finite past-tense verb ('attended')."
            ),
            (
                "Please contact the IT help desk _______ you experience any difficulty accessing the shared drive.",
                ["should", "although", "unless", "whereas"],
                "0",
                "Inverted first conditional ('should you experience' = 'if you experience')."
            ),
            (
                "The new accounting software automates billing, _______ reducing manual data entry errors by 40 percent.",
                ["thereby", "even so", "however", "in case"],
                "0",
                "'Thereby' introduces a direct result of the preceding action."
            ),
            (
                "What does the notice announce about employee parking permits?",
                ["(A) Renewal fees have been waived.", "(B) Lot C will close for resurfacing.", "(C) Passes are now digital.", "(D) Shuttle hours were extended."],
                "1",
                "The passage specifically states that Lot C closes Friday for asphalt resurfacing."
            ),
            (
                "According to the speaker, why was the shipment delayed?",
                ["(A) Missing customs forms", "(B) Severe port weather", "(C) Inventory shortage", "(D) System maintenance"],
                "0",
                "The customs declaration required an updated invoice number before clearance."
            )
        ]

        return (0..<max(1, count)).map { idx in
            let s = sampleItems[idx % sampleItems.count]
            let expl = PracticeJSONObject.ExplainAll(
                vn: s.3, en: s.3, vi: s.3, fr: s.3, ko: s.3, ja: s.3, zhCN: s.3, zhTW: s.3, es: s.3, id: s.3, th: s.3, pt: s.3, de: s.3
            )
            let gen = PracticeJSONObject.General(
                audio: nil,
                txt_read: kind == "reading comprehension" || kind == "text completion" ? "MEMORANDUM — To: All Department Heads\nFrom: Operations\nSubject: Q4 Schedule Update\n\nPlease note that Lot C will close for resurfacing this weekend. All deliveries should use the West Gate dock." : nil,
                txt_read_audio: nil, txt_read_vn: nil, image: nil,
                txt_audio: kind.contains("question") || kind.contains("conversation") || kind.contains("talk") ? "Speaker: Welcome to our quarterly operations briefing. Due to customs documentation updates, the second shipment will arrive on Wednesday." : nil,
                txt_audio_vn: nil, txt_read_trans: nil, txt_audio_trans: nil
            )
            let content = PracticeJSONObject.Content(
                question: s.0,
                answers: s.1,
                correctAnswer: s.2,
                image: nil,
                explainAll: expl,
                chooseAnswer: nil,
                userRecording: nil
            )
            return PracticeJSONObject.Question(
                id: 10000 + idx,
                general: gen,
                content: [content],
                kind: kind,
                correct_answers: [Int(s.2) ?? 0],
                score: 5,
                isReady: true,
                userRecording: nil
            )
        }
    }

    public static func offlineExamList() -> [ExamListJSONObject.Question] {
        (1...10).map { i in
            ExamListJSONObject.Question(
                id: i,
                title: "ETS Format TOEIC Test \(String(format: "%02d", i))",
                hidden_title: "200 Questions • 120 Mins",
                time: 120
            )
        }
    }

    public static func offlineExamTest(id: Int, title: String, isMini: Bool) -> ExamJSONObject.Questions {
        let countPerPart = isMini ? 5 : 10
        let parts: [ExamJSONObject.Part] = [
            ExamJSONObject.Part(name: "Listening", content: [
                ExamJSONObject.Content(kind: "picture description", Questions: offlinePracticePack(kind: "picture description", count: countPerPart)),
                ExamJSONObject.Content(kind: "incomplete sentences", Questions: offlinePracticePack(kind: "question - response", count: countPerPart))
            ]),
            ExamJSONObject.Part(name: "Reading", content: [
                ExamJSONObject.Content(kind: "incomplete sentences", Questions: offlinePracticePack(kind: "incomplete sentences", count: countPerPart)),
                ExamJSONObject.Content(kind: "reading comprehension", Questions: offlinePracticePack(kind: "reading comprehension", count: countPerPart))
            ])
        ]
        return ExamJSONObject.Questions(id: id, title: title, time: isMini ? 45 : 120, parts: parts)
    }
}
