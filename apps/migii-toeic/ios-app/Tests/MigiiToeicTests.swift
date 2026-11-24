import XCTest
@testable import MigiiToeic

// Evidence: Stage 4 1:1 Parity Tests for Migii TOEIC (iOS 16.1.1 / iPhone XS Max)

final class MigiiToeicTests: XCTestCase {
    func testBundleMetadataAndFonts() {
        XCTAssertEqual(AppFonts.regularName, "SVN-Avo")
        XCTAssertEqual(AppFonts.boldName, "SVN-Avobold")
        XCTAssertEqual(AppFonts.italicName, "SVN-Avoitalic")
        XCTAssertEqual(LayoutMetrics.referenceWidth, 414.0)
        XCTAssertEqual(LayoutMetrics.referenceHeight, 896.0)
    }

    func testColorHelperHexDecoding() {
        XCTAssertEqual(ColorHelper.primary.hexString, "#48BCAA")
        XCTAssertEqual(ColorHelper.orangeAccent.hexString, "#FF8000")
        XCTAssertEqual(ColorHelper.bgLight.hexString, "#FAFAFA")
        XCTAssertEqual(ColorHelper.bgDark.hexString, "#212121")
        XCTAssertEqual(ColorHelper.highlightYellow.hexString, "#F8F1AE")
        XCTAssertEqual(ColorHelper.correctTeal.hexString, "#32BEA6")
    }

    func testBundledDataMigiiENAndVNDecode() {
        let en = DataJSONObject.loadBundled(suffix: "EN")
        XCTAssertNotNil(en)
        XCTAssertEqual(en?.Listening.count, 4)
        XCTAssertEqual(en?.Reading.count, 3)
        XCTAssertEqual(en?.Speaking.count, 6)
        XCTAssertEqual(en?.Writing.count, 3)
        XCTAssertEqual(en?.Listening.first?.kind, "picture description")
        XCTAssertEqual(en?.Listening.first?.icon, "ic_part_1")

        let vn = DataJSONObject.loadBundled(suffix: "VN")
        XCTAssertNotNil(vn)
        XCTAssertEqual(vn?.Reading.first?.kind, "incomplete sentences")
    }

    func testBundledReviewsAndExamOnlineSchemas() {
        let reviews = PremiumReviewObject.loadBundledReviews()
        XCTAssertFalse(reviews.isEmpty)

        let pack = APIClient.offlinePracticePack(kind: "incomplete sentences", count: 8)
        XCTAssertEqual(pack.count, 8)
        XCTAssertEqual(pack.first?.content?.first?.answers?.count, 4)

        let exam = APIClient.offlineExamTest(id: 1, title: "Test 01", isMini: false)
        XCTAssertEqual(exam.parts.count, 2)
    }

    func testRoadmapScoringAndPlanGeneration() {
        XCTAssertEqual(RoadmapCalculator.scaledSectionScore(correct: 0, total: 100), 5)
        XCTAssertEqual(RoadmapCalculator.scaledSectionScore(correct: 100, total: 100), 495)
        let days = RoadmapCalculator.generatePlanDays(currentLevel: 450, targetScore: 750, totalDays: 30)
        XCTAssertEqual(days.count, 30)
        XCTAssertEqual(days[6].number_test, 1)
    }

    func testUserDefaultHelperKeysAndPersistence() {
        XCTAssertEqual(UserDefaultHelper.Keys.fontSize, "font_size")
        XCTAssertEqual(UserDefaultHelper.Keys.openOnboarding, "open_onboarding")
        XCTAssertEqual(UserDefaultHelper.Keys.hisPracticeV2, "his_practice_v2")
        XCTAssertEqual(StoreKitManager.allProductIDs.count, 14)
        XCTAssertTrue(StoreKitManager.allProductIDs.contains("migii_toeic_preforever"))
    }

    func testWebViewTemplateInjection() {
        let html = MyWebView.renderTemplate(
            fileName: "question.html",
            bodyHTML: "<p>Sample TOEIC Question</p>",
            fontSizePt: 18,
            style: .light
        )
        XCTAssertTrue(html.contains("<p>Sample TOEIC Question</p>"))
        XCTAssertTrue(html.contains("18px"))
        XCTAssertTrue(html.contains("SVN-Avo"))
        XCTAssertFalse(html.contains("<news_body>"))
        XCTAssertFalse(html.contains("<font_size>"))
    }
}
