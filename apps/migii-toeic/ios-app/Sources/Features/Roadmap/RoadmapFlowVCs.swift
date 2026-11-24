import UIKit

// Port of Migii_TOEIC_.RoadmapTabView (0x100525518), RoadmapEntranceVC (0x1001cf724), RoadmapEntranceResultVC (0x100254528)

public enum RoadmapCalculator {
    // Converts section accuracy into ETS-aligned 5..495 section band (rounded to 5)
    public static func scaledSectionScore(correct: Int, total: Int) -> Int {
        guard total > 0 else { return 5 }
        let raw = 5.0 + (Double(correct) / Double(total)) * 490.0
        let rounded = Int((raw / 5.0).rounded()) * 5
        return max(5, min(495, rounded))
    }

    public static func generatePlanDays(currentLevel: Int, targetScore: Int, totalDays: Int) -> [DetailRoadmapJSONObject.Detail] {
        let kinds = ["picture description", "question - response", "incomplete sentences", "short conversations", "reading comprehension"]
        return (1...max(7, totalDays)).map { day in
            let kind = kinds[(day - 1) % kinds.count]
            let isMilestone = (day % 7 == 0)
            return DetailRoadmapJSONObject.Detail(
                day: day,
                id_day: 1000 + day,
                status: day == 1 ? 1 : 0,
                process: [
                    DetailRoadmapJSONObject.Process(kind: kind, type: isMilestone ? "test" : "practice", practice_per_day: 10, time: 15, status: 0, id_process: day, result: nil)
                ],
                type: isMilestone ? "evaluate" : "practice",
                kind: kind,
                min_score: targetScore,
                dayPassList: nil,
                number_test: isMilestone ? 1 : 0
            )
        }
    }
}

public final class RoadmapTabView: UIView {
    private weak var hostVC: HomeVC?
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private var planDays: [DetailRoadmapJSONObject.Detail] = []

    public init(hostVC: HomeVC) {
        self.hostVC = hostVC
        super.init(frame: .zero)
        setup()
        refreshData()
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    private func setup() {
        backgroundColor = ColorHelper.screenBackground
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.spacing = 14
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)
        scrollView.addSubview(stack)
        scrollView.pinEdges(to: self)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -24),
            stack.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -32)
        ])
    }

    public func refreshData() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let currentLvl = UserDefaultHelper.shared.levelRoadmap
        let targetLvl = UserDefaultHelper.shared.targetRoadmap
        planDays = RoadmapCalculator.generatePlanDays(currentLevel: currentLvl, targetScore: targetLvl, totalDays: 30)

        let title = UILabel()
        title.text = tr("route", "My TOEIC Roadmap")
        title.font = AppFonts.bold(22)
        title.textColor = ColorHelper.textPrimary
        stack.addArrangedSubview(title)

        // Hero Card: Current -> Target Score
        let hero = CardView()
        hero.backgroundColor = ColorHelper.softTealTint

        let scoreLbl = UILabel()
        scoreLbl.text = "Current: \(currentLvl)  →  Target: \(targetLvl)"
        scoreLbl.font = AppFonts.bold(18)
        scoreLbl.textColor = ColorHelper.deepTeal
        scoreLbl.translatesAutoresizingMaskIntoConstraints = false

        let subLbl = UILabel()
        subLbl.text = "30-day adaptive daily study schedule"
        subLbl.font = AppFonts.regular(13)
        subLbl.textColor = ColorHelper.textSecondary
        subLbl.translatesAutoresizingMaskIntoConstraints = false

        let btnRow = UIStackView()
        btnRow.axis = .horizontal
        btnRow.spacing = 10
        btnRow.distribution = .fillEqually
        btnRow.translatesAutoresizingMaskIntoConstraints = false

        let entranceBtn = UIButton(type: .system)
        entranceBtn.backgroundColor = ColorHelper.primary
        entranceBtn.setTitle("Placement Test", for: .normal)
        entranceBtn.setTitleColor(.white, for: .normal)
        entranceBtn.titleLabel?.font = AppFonts.bold(14)
        entranceBtn.layer.cornerRadius = 18
        entranceBtn.addTarget(self, action: #selector(openEntranceTest), for: .touchUpInside)

        let changeGoalBtn = UIButton(type: .system)
        changeGoalBtn.backgroundColor = ColorHelper.cardBackground
        changeGoalBtn.setTitle("Set Target", for: .normal)
        changeGoalBtn.setTitleColor(ColorHelper.primary, for: .normal)
        changeGoalBtn.titleLabel?.font = AppFonts.bold(14)
        changeGoalBtn.layer.cornerRadius = 18
        changeGoalBtn.layer.borderWidth = 1
        changeGoalBtn.layer.borderColor = ColorHelper.primary.cgColor
        changeGoalBtn.addTarget(self, action: #selector(pickTargetGoal), for: .touchUpInside)

        btnRow.addArrangedSubview(entranceBtn)
        btnRow.addArrangedSubview(changeGoalBtn)

        hero.addSubview(scoreLbl)
        hero.addSubview(subLbl)
        hero.addSubview(btnRow)
        NSLayoutConstraint.activate([
            scoreLbl.topAnchor.constraint(equalTo: hero.topAnchor, constant: 16),
            scoreLbl.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 16),
            scoreLbl.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -16),

            subLbl.topAnchor.constraint(equalTo: scoreLbl.bottomAnchor, constant: 4),
            subLbl.leadingAnchor.constraint(equalTo: scoreLbl.leadingAnchor),

            btnRow.topAnchor.constraint(equalTo: subLbl.bottomAnchor, constant: 14),
            btnRow.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 16),
            btnRow.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -16),
            btnRow.heightAnchor.constraint(equalToConstant: 38),
            btnRow.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -16)
        ])
        stack.addArrangedSubview(hero)

        // Daily Roadmap Items
        for item in planDays.prefix(14) {
            let dayNum = item.day ?? 1
            let kind = item.kind ?? "incomplete sentences"
            let card = CardView()

            let badge = PaddingLabel()
            badge.text = "Day \(dayNum)"
            badge.font = AppFonts.bold(12)
            badge.textColor = .white
            badge.backgroundColor = dayNum % 7 == 0 ? ColorHelper.orangeAccent : ColorHelper.primary
            badge.layer.cornerRadius = 10
            badge.clipsToBounds = true
            badge.translatesAutoresizingMaskIntoConstraints = false

            let lbl = UILabel()
            lbl.text = dayNum % 7 == 0 ? "Milestone Assessment (\(kind.capitalized))" : "Daily Focus: \(kind.capitalized)"
            lbl.font = AppFonts.bold(14)
            lbl.textColor = ColorHelper.textPrimary
            lbl.numberOfLines = 0
            lbl.translatesAutoresizingMaskIntoConstraints = false

            let arrow = UIImageView(image: UIImage(named: "ic_arrow_right"))
            arrow.contentMode = .scaleAspectFit
            arrow.translatesAutoresizingMaskIntoConstraints = false

            card.addSubview(badge)
            card.addSubview(lbl)
            card.addSubview(arrow)
            NSLayoutConstraint.activate([
                badge.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                badge.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                lbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                lbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
                lbl.leadingAnchor.constraint(equalTo: badge.trailingAnchor, constant: 12),
                lbl.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -8),
                arrow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                arrow.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                arrow.widthAnchor.constraint(equalToConstant: 16),
                arrow.heightAnchor.constraint(equalToConstant: 16)
            ])
            card.addGestureRecognizer(RoadmapDayTap(kind: kind, day: dayNum, target: self, action: #selector(openDay(_:))))
            stack.addArrangedSubview(card)
        }
    }

    @objc private func openEntranceTest() {
        hostVC?.navigationController?.pushViewController(RoadmapEntranceVC(), animated: true)
    }

    @objc private func pickTargetGoal() {
        let sheet = UIAlertController(title: "Select Target TOEIC Score", message: "Choose your goal band", preferredStyle: .actionSheet)
        for score in [500, 600, 750, 850, 950] {
            sheet.addAction(UIAlertAction(title: "\(score)+ Points", style: .default) { [weak self] _ in
                UserDefaultHelper.shared.targetRoadmap = score
                self?.refreshData()
            })
        }
        sheet.addAction(UIAlertAction(title: tr("cancel", "Cancel"), style: .cancel))
        hostVC?.present(sheet, animated: true)
    }

    @objc private func openDay(_ sender: RoadmapDayTap) {
        let vc = PartPracticeVC(kind: sender.kind, titleText: "Roadmap Day \(sender.day)", partNumber: 5, limit: 10)
        hostVC?.navigationController?.pushViewController(vc, animated: true)
    }
}

private final class RoadmapDayTap: UITapGestureRecognizer {
    let kind: String
    let day: Int
    init(kind: String, day: Int, target: Any?, action: Selector?) {
        self.kind = kind
        self.day = day
        super.init(target: target, action: action)
    }
}

public final class RoadmapEntranceVC: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: "Placement Assessment")
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        let iv = UIImageView(image: UIImage(named: "img_character_exam_2"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        let lbl = UILabel()
        lbl.text = "Complete a quick 15-question Listening & Reading diagnostic test to calibrate your personalized TOEIC starting band."
        lbl.font = AppFonts.regular(15)
        lbl.textColor = ColorHelper.textPrimary
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(lbl)

        let start = UIButton(type: .system)
        start.backgroundColor = ColorHelper.primary
        start.setTitle("Start Diagnostic Test", for: .normal)
        start.setTitleColor(.white, for: .normal)
        start.titleLabel?.font = AppFonts.bold(16)
        start.layer.cornerRadius = LayoutMetrics.pillCornerRadius
        start.addTarget(self, action: #selector(beginTest), for: .touchUpInside)
        start.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(iv)
        view.addSubview(card)
        view.addSubview(start)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            iv.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 24),
            iv.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iv.widthAnchor.constraint(equalToConstant: 180),
            iv.heightAnchor.constraint(equalToConstant: 180),
            card.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            lbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            lbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            lbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            start.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            start.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            start.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            start.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func beginTest() {
        let vc = PartPracticeVC(kind: "incomplete sentences", titleText: "Placement Test", partNumber: 5, limit: 15)
        navigationController?.pushViewController(vc, animated: true)
    }
}
