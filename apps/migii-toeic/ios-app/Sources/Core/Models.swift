import Foundation

// Port of Migii_TOEIC_ Data Models & Codable DTOs (__swift5_fieldmd & Resource JSON seeds)

// MARK: - dataMigii*.json & Practice Catalog

public struct DataJSONObject: Codable {
    public var Listening: [Part]
    public var Reading: [Part]
    public var Speaking: [Part]
    public var Writing: [Part]

    public struct Part: Codable, Hashable {
        public var part: Int
        public var part_index: Int
        public var kind: String
        public var number_ques: Int
        public var name: String
        public var description: String
        public var description_en: String?
        public var icon: String
        public var isLock: Bool?

        public init(part: Int, part_index: Int, kind: String, number_ques: Int, name: String, description: String, description_en: String? = nil, icon: String, isLock: Bool? = false) {
            self.part = part
            self.part_index = part_index
            self.kind = kind
            self.number_ques = number_ques
            self.name = name
            self.description = description
            self.description_en = description_en
            self.icon = icon
            self.isLock = isLock
        }
    }

    public static func loadBundled(suffix: String = LanguageManager.shared.currentOption.dataSuffix) -> DataJSONObject? {
        let name = "dataMigii\(suffix)"
        let url = Bundle.main.url(forResource: name, withExtension: "json")
            ?? Bundle.main.url(forResource: "dataMigiiEN", withExtension: "json")
        guard let fileURL = url, let data = try? Data(contentsOf: fileURL) else { return nil }
        return try? JSONDecoder().decode(DataJSONObject.self, from: data)
    }
}

public struct ExamPreparationObject {
    public var type: String
    public var title: String
    public var icon: String
}

// MARK: - Practice & Question DTOs (Port of PracticeJSONObject)

public struct PracticeJSONObject: Codable {
    public var Questions: QuestionsPayload?

    public struct QuestionsPayload: Codable {
        public var Time: Int?
        public var Questions: [Question]?
    }

    public struct Question: Codable {
        public var id: Int
        public var general: General?
        public var content: [Content]?
        public var kind: String?
        public var correct_answers: [Int]?
        public var score: Int?
        public var isReady: Bool?
        public var userRecording: String?
    }

    public struct General: Codable {
        public var audio: String?
        public var txt_read: String?
        public var txt_read_audio: String?
        public var txt_read_vn: String?
        public var image: String?
        public var txt_audio: String?
        public var txt_audio_vn: String?
        public var txt_read_trans: String?
        public var txt_audio_trans: String?
    }

    public struct Content: Codable {
        public var question: String?
        public var answers: [String]?
        public var correctAnswer: String?
        public var image: String?
        public var explainAll: ExplainAll?
        public var chooseAnswer: Int?
        public var userRecording: String?
    }

    public struct ExplainAll: Codable {
        public var vn: String?
        public var en: String?
        public var vi: String?
        public var fr: String?
        public var ko: String?
        public var ja: String?
        public var zhCN: String?
        public var zhTW: String?
        public var es: String?
        public var id: String?
        public var th: String?
        public var pt: String?
        public var de: String?

        public func text(for explainKey: String = LanguageManager.shared.currentOption.explainKey) -> String {
            switch explainKey {
            case "vi": return vi ?? vn ?? en ?? ""
            case "fr": return fr ?? en ?? ""
            case "ko": return ko ?? en ?? ""
            case "ja": return ja ?? en ?? ""
            case "zhCN": return zhCN ?? en ?? ""
            case "zhTW": return zhTW ?? en ?? ""
            case "es": return es ?? en ?? ""
            case "id": return id ?? en ?? ""
            case "th": return th ?? en ?? ""
            case "pt": return pt ?? en ?? ""
            case "de": return de ?? en ?? ""
            default: return en ?? vi ?? vn ?? ""
            }
        }
    }
}

public struct NumberAnswerObject: Codable {
    public var numberTitle: Int
    public var answerChoose: Int
    public var answerCorrect: Int
    public var numberAnswer: Int
}

public struct PracticeHistoryResultObject: Codable {
    public var id: Int
    public var kind: String
    public var correct: Int
    public var total: Int
    public var number_ques: Int
    public var time: Double
    public var typeHistory: Int
    public var currentDayRoute: Int?
    public var tagKind: String?
}

public struct PracticeQuestionByID: Codable {
    public var Questions: [PracticeJSONObject.Question]?
}

public struct QuestionIdsWrong: Codable {
    public var question_id: Int
}

public struct NumberQuestionJSONObject: Codable {
    public var Questions: Questions?
    public struct Questions: Codable {
        public var tag: [Tag]?
        public var kind: [Kind]?
    }
    public struct Kind: Codable {
        public var kind: String?
        public var detail: Int?
    }
    public struct Tag: Codable {
        public var tag: String?
        public var detail: Int?
    }
}

// MARK: - Exam & Exam Online DTOs (Port of ExamJSONObject, ExamListJSONObject, ObjectListEvent)

public struct ExamListJSONObject: Codable {
    public var Questions: [Question]?
    public struct Question: Codable {
        public var id: Int
        public var title: String
        public var hidden_title: String?
        public var time: Int
    }
}

public struct ExamTypeObject {
    public var type: Int
    public var title: String
    public var examList: [ExamListJSONObject.Question]
}

public struct ExamStatusObject: Codable {
    public var idExam: Int
    public var score: Int
    public var total: Int
    public var isDoing: Bool
    public var posQuestionContinue: Int
}

public struct ExamHistoryResultObject: Codable {
    public var id: Int
    public var title: String
    public var scoreListening: Int
    public var totalListening: Int
    public var scoreReading: Int
    public var totalReading: Int
    public var time: Double
    public var typeTest: Int // 0 = full exam, 1 = mini exam
}

public struct ExamJSONObject: Codable {
    public var Questions: Questions?
    public var date_test: String?
    public var name: String?
    public var id_user: Int?
    public var id_exam: Int?

    public struct Questions: Codable {
        public var id: Int
        public var title: String
        public var time: Int
        public var parts: [Part]
    }

    public struct Part: Codable {
        public var name: String
        public var content: [Content]
    }

    public struct Content: Codable {
        public var kind: String
        public var Questions: [PracticeJSONObject.Question]
    }
}

public struct ExamCachedObject: Codable {
    public var time: Int
    public var answerChoose: [String: Int]
}

public struct ObjectListEvent: Codable {
    public var Event: [Event]?
    public struct Event: Codable {
        public var event_id: Int
        public var kind: Int?
        public var start: Int?
        public var end: Int?
        public var count_question: Int?
        public var time: Int?
        public var status: Int?
        public var timeServer: Int?
        public var image: String?
        public var title: String?
    }
}

public struct ObjectTestOnlineDetail: Codable {
    public var Questions: ExamJSONObject.Questions?
}

public struct ObjectResultSendTestOnline: Codable {
    public var Err: UserStatusObject.Users?
    public var Event: Event?

    public struct Event: Codable {
        public var result_score_parts: [ResultScorePart]?
        public var score: Int?
        public var rank_index: Int?
        public var count_question: Int?
        public var result_score_total: Int?
        public var correct_count_question: Int?
        public var pass_score: Int?
    }

    public struct ResultScorePart: Codable {
        public var name: String?
        public var score: Int?
    }
}

public struct ObjectResultHistoryExamOnline: Codable {
    public var Event: [Event]?
    public struct Event: Codable {
        public var test_id: Int?
        public var event_id: Int?
        public var score: Int?
        public var count_question: Int?
        public var result_score_total: Int?
        public var work_time: Int?
        public var result_score_parts: [ObjectResultSendTestOnline.ResultScorePart]?
        public var created_at: String?
        public var answer: String?
    }
}

public struct ObjectRankHistoryExamOnline: Codable {
    public var Event: Event?
    public struct Event: Codable {
        public var myRank: Rank?
        public var ranks: [Rank]?
        public var previousRank: Rank?
    }
    public struct Rank: Codable {
        public var user_id: Int?
        public var name: String?
        public var work_time: Int?
        public var result_score_total: Int?
        public var score: Int?
        public var rank_index: Int?
        public var created_at: String?
        public var count_users: Int?
    }
}

public struct UserPrizeJSONObject: Codable {
    public var Event: [EventObject]?
    public struct EventObject: Codable {
        public var user_id: Int?
        public var event_id: Int?
        public var rank: Int?
        public var kind: Int?
        public var start: Int?
        public var end: Int?
        public var premium: Int?
        public var image: String?
        public var title: String?
    }
}

// MARK: - Roadmap DTOs (Port of DetailRoadmapJSONObject, RoadmapEntranceJSONObject)

public struct DetailRoadmapJSONObject: Codable {
    public var Route: Route?

    public struct Route: Codable {
        public var id_user: Int?
        public var level: Int?
        public var route: RouteDetail?
    }

    public struct RouteDetail: Codable {
        public var max_score: Int?
        public var min_score: Int?
        public var days: Int?
        public var route: [RouteItem]?
    }

    public struct RouteItem: Codable {
        public var type: String?
        public var kind: String?
        public var name_vn: String?
        public var name_en: String?
        public var max_score: Int?
        public var min_score: Int?
        public var difficult: Int?
        public var count_day: Int?
        public var practice_per_day: Int?
        public var id_route: Int?
        public var status: Int?
        public var detail: [Detail]?
        public var day_start: Int?
        public var day_end: Int?
        public var number_test: Int?
        public var is_score_target: Int?
        public var type_pos: Int?
    }

    public struct Detail: Codable {
        public var day: Int?
        public var id_day: Int?
        public var status: Int?
        public var process: [Process]?
        public var type: String?
        public var kind: String?
        public var min_score: Int?
        public var dayPassList: [DayPass]?
        public var number_test: Int?
    }

    public struct DayPass: Codable {
        public var day: Int?
        public var score: Int?
    }

    public struct Process: Codable {
        public var kind: String?
        public var type: String?
        public var practice_per_day: Int?
        public var time: Int?
        public var status: Int?
        public var id_process: Int?
        public var result: Result?
    }

    public struct Result: Codable {
        public var questions: [Question]?
        public var time_end_process: Int?
        public var time_start_process: Int?
        public var max_score: Int?
        public var sum_score: Int?
        public var grammar_score: Int?
        public var listen_score: Int?
        public var read_score: Int?
        public var word_score: Int?
        public var pass: Int?
    }

    public struct Question: Codable {
        public var id: Int?
        public var _true: Int?
        public var _false: Int?
        public var answer: Int?
    }
}

public struct RoadmapEntranceJSONObject: Codable {
    public var Route: Route?
    public struct Route: Codable {
        public var id: Int?
        public var content: [Content]?
        public var level: Int?
        public var time: Int?
        public var count_question: Int?
        public var sum_score: Int?
    }
    public struct Content: Codable {
        public var kind: String?
        public var time: Int?
        public var Questions: [PracticeJSONObject.Question]?
    }
}

// MARK: - User, Auth, Premium, Reviews & Settings DTOs

public struct UserProfileJSONObject: Codable {
    public var Err: ErrorObj?
    public var User: User?

    public struct ErrorObj: Codable {
        public var statusCode: Int?
        public var message: String?
    }

    public struct User: Codable {
        public var id: Int?
        public var name: String?
        public var email: String?
        public var avatar: String?
        public var sex: String?
        public var day_of_birth: Int?
        public var month_of_birth: Int?
        public var year_of_birth: Int?
        public var country: String?
        public var language: String?
        public var phone: String?
        public var accessToken: String?
        public var is_premium: Bool?
        public var premium: Premium?
    }

    public struct Premium: Codable {
        public var product_id: String?
        public var purchase_date: String?
        public var time_expired: String?
    }
}

public struct UserStatusObject: Codable {
    public var Err: Users?
    public var User: Users?
    public struct Users: Codable {
        public var statusCode: Int?
        public var message: String?
    }
}

public struct TimeServerJSONObject: Codable {
    public var User: UserObject?
    public struct UserObject: Codable {
        public var time: Int?
    }
}

public struct CheckPremiumObject: Codable {
    public var Err: ErrorObj?
    public var User: User?
    public struct ErrorObj: Codable {
        public var statusCode: Int?
        public var message: String?
    }
    public struct User: Codable {
        public var is_premium: Bool?
        public var premium: UserProfileJSONObject.Premium?
    }
}

public struct CountPurchaseJSONObject: Codable {
    public var User: UserObject?
    public struct UserObject: Codable {
        public var count: Int?
        public var user_list: [UserPurchased]?
    }
    public struct UserPurchased: Codable {
        public var name: String?
        public var email: String?
        public var avatar: String?
        public var time: String?
        public var count: Int?
        public var user_id: Int?
    }
}

public struct PremiumReviewObject: Codable {
    public var name: String?
    public var star: Int?
    public var time: String?
    public var date: String?
    public var content: String?
    public var urlImage: String?
    public var language: String?

    public static func loadBundledReviews() -> [PremiumReviewObject] {
        guard let url = Bundle.main.url(forResource: "json_feedback_user", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let items = try? JSONDecoder().decode([PremiumReviewObject].self, from: data) else {
            return []
        }
        return items
    }
}

// MARK: - Theory, Notebook & Dictionary DTOs

public struct TheoryVocabObject: Codable {
    public var id: Int
    public var word: String
    public var pronounce: String?
    public var level: String?
    public var descript_level: String?
    public var short_mean: String?
    public var means: String?
    public var snym: String?
    public var conjugation: String?
    public var parsedMeans: [MeansList]?
    public var indexSort: Int?

    public struct MeansList: Codable {
        public var kind: String?
        public var means: [Mean]?
    }

    public struct Mean: Codable {
        public var mean: String?
        public var examples: [Int]?
        public var exampleList: [TheoryExampleObject]?
    }
}

public struct TheoryExampleObject: Codable {
    public var id: Int
    public var e: String
    public var m: String
}

public struct TheoryGrammarObject: Codable {
    public var id: Int
    public var level: String?
    public var title: String
    public var tag: String?
    public var related: String?
    public var contents: String?
    public var parsedContents: [ContentObject]?

    public struct ContentObject: Codable {
        public var sub_title: String?
        public var content: [Content]?
    }

    public struct Content: Codable {
        public var c: String?
        public var f: String?
        public var e: [Example]?
    }

    public struct Example: Codable {
        public var e: String?
    }
}

public struct DunnoWordJSONObject: Codable {
    public var found: Bool?
    public var result: [Result]?

    public struct Result: Codable {
        public var id: Int?
        public var language: String?
        public var type: String?
        public var word: String?
        public var keyword: String?
        public var pronounce: Pronounce?
        public var snym: [Snym]?
        public var word_family: [WordFamily]?
        public var content: [ResultContent]?
    }

    public struct Pronounce: Codable {
        public var us: String?
        public var gb: String?
    }

    public struct Snym: Codable {
        public var kind: String?
        public var content: [ContentObject]?
    }

    public struct ContentObject: Codable {
        public var syno: [String]?
        public var anto: [String]?
    }

    public struct WordFamily: Codable {
        public var field: String?
        public var content: [String]?
    }

    public struct ResultContent: Codable {
        public var kind: String?
        public var means: [Mean]?
    }

    public struct Mean: Codable {
        public var mean: String?
        public var examples: [Example]?
    }

    public struct Example: Codable {
        public var id: Int?
        public var language: String?
        public var type: String?
        public var e: String?
        public var m: String?
    }
}

public struct SyncDataVocabQues: Codable {
    public var user: User?
    public struct User: Codable {
        public var notebooksData: [NotebooksDatum]?
        public var grammarData: [Int]?
        public var questionData: [MyQuestionSave]?
        public var vocabData: [MyVocabulary]?
    }

    public struct NotebooksDatum: Codable {
        public var intColor: Int
        public var listWord: [ChildNote]
        public var name: String
        public var timeCreate: Double
    }

    public struct ChildNote: Codable {
        public var example: String?
        public var idFromDBTheory: Int?
        public var kindWord: String?
        public var meanOfExample: String?
        public var note: String?
        public var pro: String?
        public var shortMen: String?
        public var timeCreate: Double
        public var type: Int?
        public var word: String
    }
}

public struct MyVocabulary: Codable, Equatable {
    public var word: String
    public var pro: String
    public var kind: String
    public var shortMean: String
    public var mNote: String
    public var mIsSave: Bool
}

public struct MyQuestionSave: Codable {
    public var listContent: [PracticeJSONObject.Question]
    public var idKind: String
    public var id: Int
}

public struct ItemDownloadObject: Codable {
    public enum ItemDownloadType: Int, Codable { case typePart = 0, typeExam = 1 }
    public enum ItemDownloadStatus: Int, Codable { case notDownload = 0, downloading = 1, downloaded = 2, failed = 3 }

    public var typeDownload: ItemDownloadType
    public var partNumber: Int
    public var partName: String
    public var partKind: String
    public var partIcon: String
    public var statusDownload: ItemDownloadStatus
    public var processDownload: Float
}

// Port of Migii_TOEIC_.SettingsType enum (16 cases verified in __swift5_fieldmd)
public enum SettingsType: CaseIterable {
    case ACCOUNT
    case LANGUAGE_DEVICE
    case THEME_APP
    case DOWNLOAD_MANAGER
    case FANPAGE
    case ANSWER_INTERFACE
    case SHOWS
    case SHARE
    case REMINDER
    case FEEDBACK
    case RATE
    case POLICY
    case VERSION
    case MORE_APP
    case INTRODUCE_APP
    case FAQ
}
