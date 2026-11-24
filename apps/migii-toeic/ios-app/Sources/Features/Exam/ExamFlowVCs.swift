import UIKit

// Port of Migii_TOEIC_.ExamTabView (0x1001301e0), ExamListSeeMoreVC (0x100024e5c), ExamPrepareVC (0x1004bb3b8),
// ExamTestVC (0x1003cd930), ExamResultVC (0x1004b69e8), ExamSummaryAnswerVC (0x100223034),
// ExamOnlineEventVC (0x1004e23bc), DetailHappeningVC (0x100108c78)

public final class ExamTabView: UIView {
    private weak var hostVC: HomeVC?
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private var exams: [ExamListJSONObject.Question] = APIClient.offlineExamList()

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

        APIClient.shared.fetchExamList { [weak self] list in
            self?.exams = list
            self?.rebuildUI()
        }
    }

    public func refreshData() { rebuildUI() }

    private func rebuildUI() {
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let header = UILabel()
        header.text = tr("name_exams", "TOEIC Exams")
        header.font = AppFonts.bold(22)
        header.textColor = ColorHelper.textPrimary
        stack.addArrangedSubview(header)

        // Online Trial Exam Banner Card
        let eventCard = CardView()
        eventCard.backgroundColor = ColorHelper.softTealTint
        let evIcon = UIImageView(image: UIImage(named: "ic_trophy_exam_2"))
        evIcon.contentMode = .scaleAspectFit
        evIcon.translatesAutoresizingMaskIntoConstraints = false

        let evTitle = UILabel()
        evTitle.text = tr("exam_online", "Migii Global TOEIC Online Exam")
        evTitle.font = AppFonts.bold(15)
        evTitle.textColor = ColorHelper.deepTeal
        evTitle.translatesAutoresizingMaskIntoConstraints = false

        let evSub = UILabel()
        evSub.text = "Compete globally, get official certificate & leaderboard rank"
        evSub.font = AppFonts.regular(12)
        evSub.textColor = ColorHelper.textSecondary
        evSub.numberOfLines = 2
        evSub.translatesAutoresizingMaskIntoConstraints = false

        eventCard.addSubview(evIcon)
        eventCard.addSubview(evTitle)
        eventCard.addSubview(evSub)
        NSLayoutConstraint.activate([
            evIcon.leadingAnchor.constraint(equalTo: eventCard.leadingAnchor, constant: 14),
            evIcon.centerYAnchor.constraint(equalTo: eventCard.centerYAnchor),
            evIcon.widthAnchor.constraint(equalToConstant: 46),
            evIcon.heightAnchor.constraint(equalToConstant: 46),
            evTitle.topAnchor.constraint(equalTo: eventCard.topAnchor, constant: 14),
            evTitle.leadingAnchor.constraint(equalTo: evIcon.trailingAnchor, constant: 12),
            evTitle.trailingAnchor.constraint(equalTo: eventCard.trailingAnchor, constant: -12),
            evSub.topAnchor.constraint(equalTo: evTitle.bottomAnchor, constant: 4),
            evSub.leadingAnchor.constraint(equalTo: evTitle.leadingAnchor),
            evSub.trailingAnchor.constraint(equalTo: evTitle.trailingAnchor),
            evSub.bottomAnchor.constraint(equalTo: eventCard.bottomAnchor, constant: -14)
        ])
        eventCard.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openEvents)))
        stack.addArrangedSubview(eventCard)

        // Score Trend Chart if user has exam history
        let history = UserDefaultHelper.shared.loadExamHistoryList()
        if !history.isEmpty {
            let chartCard = CardView()
            let chartTitle = UILabel()
            chartTitle.text = tr("charts", "Exam Score History")
            chartTitle.font = AppFonts.bold(15)
            chartTitle.textColor = ColorHelper.textPrimary
            chartTitle.translatesAutoresizingMaskIntoConstraints = false

            let chart = MLLineChart()
            chart.dataEntries = history.prefix(8).reversed().map {
                MLPointEntry(value: CGFloat($0.scoreListening + $0.scoreReading), label: $0.title)
            }
            chart.translatesAutoresizingMaskIntoConstraints = false

            chartCard.addSubview(chartTitle)
            chartCard.addSubview(chart)
            NSLayoutConstraint.activate([
                chartTitle.topAnchor.constraint(equalTo: chartCard.topAnchor, constant: 12),
                chartTitle.leadingAnchor.constraint(equalTo: chartCard.leadingAnchor, constant: 14),
                chart.topAnchor.constraint(equalTo: chartTitle.bottomAnchor, constant: 8),
                chart.leadingAnchor.constraint(equalTo: chartCard.leadingAnchor, constant: 8),
                chart.trailingAnchor.constraint(equalTo: chartCard.trailingAnchor, constant: -8),
                chart.heightAnchor.constraint(equalToConstant: 140),
                chart.bottomAnchor.constraint(equalTo: chartCard.bottomAnchor, constant: -10)
            ])
            stack.addArrangedSubview(chartCard)
        }

        // Section Header: Full Mock Tests
        addExamSectionHeader(title: "Full Mock Exams (120 mins)", action: #selector(openSeeMore))
        for exam in exams.prefix(4) {
            stack.addArrangedSubview(makeExamCard(exam, isMini: false))
        }

        let miniLbl = UILabel()
        miniLbl.text = "Mini TOEIC Tests (45 mins)"
        miniLbl.font = AppFonts.bold(17)
        miniLbl.textColor = ColorHelper.textPrimary
        stack.addArrangedSubview(miniLbl)

        for (i, exam) in exams.prefix(3).enumerated() {
            var mini = exam
            mini.title = "Mini TOEIC Test \(String(format: "%02d", i + 1))"
            mini.time = 45
            stack.addArrangedSubview(makeExamCard(mini, isMini: true))
        }
    }

    private func addExamSectionHeader(title: String, action: Selector) {
        let row = UIView()
        let lbl = UILabel()
        lbl.text = title
        lbl.font = AppFonts.bold(17)
        lbl.textColor = ColorHelper.textPrimary
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let seeMore = UIButton(type: .system)
        seeMore.setTitle(tr("see_more", "See all"), for: .normal)
        seeMore.titleLabel?.font = AppFonts.bold(13)
        seeMore.setTitleColor(ColorHelper.primary, for: .normal)
        seeMore.addTarget(self, action: action, for: .touchUpInside)
        seeMore.translatesAutoresizingMaskIntoConstraints = false

        row.addSubview(lbl)
        row.addSubview(seeMore)
        NSLayoutConstraint.activate([
            row.heightAnchor.constraint(equalToConstant: 28),
            lbl.leadingAnchor.constraint(equalTo: row.leadingAnchor),
            lbl.centerYAnchor.constraint(equalTo: row.centerYAnchor),
            seeMore.trailingAnchor.constraint(equalTo: row.trailingAnchor),
            seeMore.centerYAnchor.constraint(equalTo: row.centerYAnchor)
        ])
        stack.addArrangedSubview(row)
    }

    private func makeExamCard(_ exam: ExamListJSONObject.Question, isMini: Bool) -> UIView {
        let card = CardView()
        let iv = UIImageView(image: UIImage(named: isMini ? "ic_exam_pre" : "ic_exam"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = exam.title
        title.font = AppFonts.bold(15)
        title.textColor = ColorHelper.textPrimary
        title.translatesAutoresizingMaskIntoConstraints = false

        let meta = UILabel()
        meta.text = "\(isMini ? 50 : 200) Questions • \(exam.time) min"
        meta.font = AppFonts.regular(12)
        meta.textColor = ColorHelper.textSecondary
        meta.translatesAutoresizingMaskIntoConstraints = false

        let startBadge = PaddingLabel()
        startBadge.text = tr("start", "Start")
        startBadge.font = AppFonts.bold(12)
        startBadge.textColor = .white
        startBadge.backgroundColor = ColorHelper.primary
        startBadge.layer.cornerRadius = 12
        startBadge.clipsToBounds = true
        startBadge.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iv)
        card.addSubview(title)
        card.addSubview(meta)
        card.addSubview(startBadge)

        NSLayoutConstraint.activate([
            iv.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            iv.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 36),
            iv.heightAnchor.constraint(equalToConstant: 36),

            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: iv.trailingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: startBadge.leadingAnchor, constant: -8),

            meta.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
            meta.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            meta.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12),

            startBadge.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            startBadge.centerYAnchor.constraint(equalTo: card.centerYAnchor)
        ])

        card.addGestureRecognizer(ExamTapRecognizer(exam: exam, isMini: isMini, target: self, action: #selector(handleExamTap(_:))))
        return card
    }

    @objc private func handleExamTap(_ sender: ExamTapRecognizer) {
        let vc = ExamPrepareVC(exam: sender.exam, isMini: sender.isMini)
        hostVC?.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openSeeMore() {
        hostVC?.navigationController?.pushViewController(ExamListSeeMoreVC(exams: exams), animated: true)
    }

    @objc private func openEvents() {
        hostVC?.navigationController?.pushViewController(ExamOnlineEventVC(), animated: true)
    }
}

private final class ExamTapRecognizer: UITapGestureRecognizer {
    let exam: ExamListJSONObject.Question
    let isMini: Bool
    init(exam: ExamListJSONObject.Question, isMini: Bool, target: Any?, action: Selector?) {
        self.exam = exam
        self.isMini = isMini
        super.init(target: target, action: action)
    }
}

public final class ExamListSeeMoreVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let exams: [ExamListJSONObject.Question]
    private let table = UITableView(frame: .zero, style: .plain)

    public init(exams: [ExamListJSONObject.Question]) {
        self.exams = exams
        super.init(nibName: nil, bundle: nil)
    }
    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: "All Mock Exams")
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(nav)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.topAnchor.constraint(equalTo: nav.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { exams.count }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let e = exams[indexPath.row]
        cell.textLabel?.text = e.title
        cell.textLabel?.font = AppFonts.bold(15)
        cell.detailTextLabel?.text = e.hidden_title ?? "\(e.time) mins"
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(ExamPrepareVC(exam: exams[indexPath.row], isMini: false), animated: true)
    }
}

public final class ExamPrepareVC: UIViewController {
    private let exam: ExamListJSONObject.Question
    private let isMini: Bool

    public init(exam: ExamListJSONObject.Question, isMini: Bool) {
        self.exam = exam
        self.isMini = isMini
        super.init(nibName: nil, bundle: nil)
    }
    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: exam.title)
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        let iv = UIImageView(image: UIImage(named: "img_prepare_1"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        let lbl = UILabel()
        lbl.text = "• Duration: \(exam.time) minutes\n• Format: Authentic ETS Listening & Reading structure\n• Instant score conversion (10 – 990) and full explanations"
        lbl.font = AppFonts.regular(15)
        lbl.textColor = ColorHelper.textPrimary
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false
        card.addSubview(lbl)

        let btn = UIButton(type: .system)
        btn.backgroundColor = ColorHelper.primary
        btn.setTitle(tr("start", "Begin Exam"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = AppFonts.bold(16)
        btn.layer.cornerRadius = LayoutMetrics.pillCornerRadius
        btn.addTarget(self, action: #selector(startExam), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(iv)
        view.addSubview(card)
        view.addSubview(btn)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            iv.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 24),
            iv.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            iv.widthAnchor.constraint(equalToConstant: 200),
            iv.heightAnchor.constraint(equalToConstant: 180),
            card.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            lbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            lbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            lbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            lbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            btn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            btn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func startExam() {
        APIClient.shared.fetchExamTest(examId: exam.id, title: exam.title, isMini: isMini) { [weak self] payload in
            guard let self = self else { return }
            self.navigationController?.pushViewController(ExamTestVC(examData: payload, isMini: self.isMini), animated: true)
        }
    }
}

public final class ExamTestVC: UIViewController {
    private let examData: ExamJSONObject.Questions
    private let isMini: Bool
    private var flattened: [(part: String, q: PracticeJSONObject.Question)] = []
    private var answers: [Int: Int] = [:]
    private var idx = 0
    private var remainingSeconds: Int
    private var timer: Timer?

    private let timerLabel = UILabel()
    private let counterLabel = UILabel()
    private let webView = MyWebView()
    private let optionsStack = UIStackView()

    public init(examData: ExamJSONObject.Questions, isMini: Bool) {
        self.examData = examData
        self.isMini = isMini
        self.remainingSeconds = max(60, examData.time * 60)
        super.init(nibName: nil, bundle: nil)
        for p in examData.parts {
            for c in p.content {
                for q in c.Questions {
                    flattened.append((p.name, q))
                }
            }
        }
    }
    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }
    deinit { timer?.invalidate() }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground

        let nav = MigiiNavBar(title: examData.title)
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        let submit = UIButton(type: .system)
        submit.setTitle(tr("submit", "Submit"), for: .normal)
        submit.titleLabel?.font = AppFonts.bold(14)
        submit.setTitleColor(ColorHelper.primary, for: .normal)
        submit.addTarget(self, action: #selector(finishExam), for: .touchUpInside)
        submit.translatesAutoresizingMaskIntoConstraints = false

        let statusBar = UIView()
        statusBar.backgroundColor = ColorHelper.cardBackground
        statusBar.translatesAutoresizingMaskIntoConstraints = false

        counterLabel.font = AppFonts.bold(14)
        counterLabel.textColor = ColorHelper.textPrimary
        counterLabel.translatesAutoresizingMaskIntoConstraints = false

        timerLabel.font = AppFonts.bold(14)
        timerLabel.textColor = ColorHelper.orangeAccent
        timerLabel.translatesAutoresizingMaskIntoConstraints = false

        statusBar.addSubview(counterLabel)
        statusBar.addSubview(timerLabel)
        statusBar.addSubview(submit)

        webView.translatesAutoresizingMaskIntoConstraints = false
        optionsStack.axis = .vertical
        optionsStack.spacing = 8
        optionsStack.translatesAutoresizingMaskIntoConstraints = false

        let footer = UIStackView()
        footer.axis = .horizontal
        footer.distribution = .fillEqually
        footer.translatesAutoresizingMaskIntoConstraints = false
        let prev = UIButton(type: .system)
        prev.setTitle("← Prev", for: .normal)
        prev.addTarget(self, action: #selector(onPrev), for: .touchUpInside)
        let next = UIButton(type: .system)
        next.setTitle("Next →", for: .normal)
        next.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        footer.addArrangedSubview(prev)
        footer.addArrangedSubview(next)

        view.addSubview(nav)
        view.addSubview(statusBar)
        view.addSubview(webView)
        view.addSubview(optionsStack)
        view.addSubview(footer)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            statusBar.topAnchor.constraint(equalTo: nav.bottomAnchor),
            statusBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statusBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            statusBar.heightAnchor.constraint(equalToConstant: 42),

            counterLabel.leadingAnchor.constraint(equalTo: statusBar.leadingAnchor, constant: 16),
            counterLabel.centerYAnchor.constraint(equalTo: statusBar.centerYAnchor),
            timerLabel.centerXAnchor.constraint(equalTo: statusBar.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: statusBar.centerYAnchor),
            submit.trailingAnchor.constraint(equalTo: statusBar.trailingAnchor, constant: -16),
            submit.centerYAnchor.constraint(equalTo: statusBar.centerYAnchor),

            webView.topAnchor.constraint(equalTo: statusBar.bottomAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            webView.heightAnchor.constraint(greaterThanOrEqualToConstant: 190),

            optionsStack.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 12),
            optionsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            optionsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            optionsStack.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -12),

            footer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            footer.heightAnchor.constraint(equalToConstant: 48)
        ])

        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.remainingSeconds = max(0, self.remainingSeconds - 1)
            self.timerLabel.text = String(format: "%02d:%02d", self.remainingSeconds / 60, self.remainingSeconds % 60)
            if self.remainingSeconds == 0 { self.finishExam() }
        }
        renderCurrent()
    }

    private func renderCurrent() {
        guard idx < flattened.count else { return }
        let entry = flattened[idx]
        counterLabel.text = "\(entry.part) • \(idx + 1)/\(flattened.count)"
        let passage = entry.q.general?.txt_read ?? entry.q.general?.txt_audio ?? ""
        let stem = entry.q.content?.first?.question ?? ""
        let html = "\(passage.isEmpty ? "" : "<div class='box'>\(passage)</div>")<div class='question'><p>\(stem)</p></div>"
        webView.loadTemplated(fileName: "question.html", bodyHTML: html, fontSize: UserDefaultHelper.shared.fontSize)

        optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        let opts = entry.q.content?.first?.answers ?? ["A", "B", "C", "D"]
        let picked = answers[idx]
        for (i, text) in opts.enumerated() {
            let b = UIButton(type: .system)
            b.tag = i
            b.contentHorizontalAlignment = .leading
            b.setTitle("  \(text)", for: .normal)
            b.backgroundColor = picked == i ? ColorHelper.softTealTint : ColorHelper.cardBackground
            b.setTitleColor(picked == i ? ColorHelper.primary : ColorHelper.textPrimary, for: .normal)
            b.titleLabel?.font = picked == i ? AppFonts.bold(15) : AppFonts.regular(15)
            b.layer.cornerRadius = 10
            b.layer.borderWidth = 1
            b.layer.borderColor = (picked == i ? ColorHelper.primary : ColorHelper.separator).cgColor
            b.addTarget(self, action: #selector(pickOption(_:)), for: .touchUpInside)
            b.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
            optionsStack.addArrangedSubview(b)
        }
    }

    @objc private func pickOption(_ sender: UIButton) {
        answers[idx] = sender.tag
        renderCurrent()
    }
    @objc private func onPrev() { if idx > 0 { idx -= 1; renderCurrent() } }
    @objc private func onNext() { if idx + 1 < flattened.count { idx += 1; renderCurrent() } }

    @objc private func finishExam() {
        timer?.invalidate()
        var lCorrect = 0, lTotal = 0, rCorrect = 0, rTotal = 0
        for (i, entry) in flattened.enumerated() {
            let expected = Int(entry.q.content?.first?.correctAnswer ?? "") ?? (entry.q.correct_answers?.first ?? 0)
            let isCorrect = (answers[i] == expected)
            if entry.part.lowercased().contains("listen") {
                lTotal += 1; if isCorrect { lCorrect += 1 }
            } else {
                rTotal += 1; if isCorrect { rCorrect += 1 }
            }
        }
        let lScore = RoadmapCalculator.scaledSectionScore(correct: lCorrect, total: max(1, lTotal))
        let rScore = RoadmapCalculator.scaledSectionScore(correct: rCorrect, total: max(1, rTotal))
        let record = ExamHistoryResultObject(id: examData.id, title: examData.title, scoreListening: lScore, totalListening: 495, scoreReading: rScore, totalReading: 495, time: Double(examData.time * 60 - remainingSeconds), typeTest: isMini ? 1 : 0)
        UserDefaultHelper.shared.appendExamHistory(record)
        let vc = ExamResultVC(record: record, flattened: flattened, answers: answers)
        navigationController?.pushViewController(vc, animated: true)
    }
}

public final class ExamResultVC: UIViewController {
    private let record: ExamHistoryResultObject
    private let flattened: [(part: String, q: PracticeJSONObject.Question)]
    private let answers: [Int: Int]

    public init(record: ExamHistoryResultObject, flattened: [(part: String, q: PracticeJSONObject.Question)], answers: [Int: Int]) {
        self.record = record
        self.flattened = flattened
        self.answers = answers
        super.init(nibName: nil, bundle: nil)
    }
    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: tr("result", "Exam Score Report"))
        nav.onBack = { [weak self] in self?.navigationController?.popToRootViewController(animated: true) }

        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        let totalScore = record.scoreListening + record.scoreReading

        let ring = Circular2ProgressBar()
        ring.lineWidth = 12
        ring.progress = CGFloat(totalScore) / 990.0
        ring.translatesAutoresizingMaskIntoConstraints = false

        let totalLbl = UILabel()
        totalLbl.text = "\(totalScore)\n/ 990"
        totalLbl.font = AppFonts.bold(22)
        totalLbl.textAlignment = .center
        totalLbl.numberOfLines = 2
        totalLbl.textColor = ColorHelper.textPrimary
        totalLbl.translatesAutoresizingMaskIntoConstraints = false

        let breakdown = UILabel()
        breakdown.text = "Listening: \(record.scoreListening) / 495\nReading: \(record.scoreReading) / 495"
        breakdown.font = AppFonts.bold(16)
        breakdown.textAlignment = .center
        breakdown.numberOfLines = 0
        breakdown.textColor = ColorHelper.deepTeal
        breakdown.translatesAutoresizingMaskIntoConstraints = false

        let reviewBtn = UIButton(type: .system)
        reviewBtn.backgroundColor = ColorHelper.primary
        reviewBtn.setTitle(tr("answers_explanations", "Review All Explanations"), for: .normal)
        reviewBtn.setTitleColor(.white, for: .normal)
        reviewBtn.titleLabel?.font = AppFonts.bold(16)
        reviewBtn.layer.cornerRadius = LayoutMetrics.pillCornerRadius
        reviewBtn.addTarget(self, action: #selector(openReview), for: .touchUpInside)
        reviewBtn.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(card)
        card.addSubview(ring)
        card.addSubview(totalLbl)
        card.addSubview(breakdown)
        view.addSubview(reviewBtn)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            card.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 24),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ring.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            ring.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            ring.widthAnchor.constraint(equalToConstant: 150),
            ring.heightAnchor.constraint(equalToConstant: 150),
            totalLbl.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            totalLbl.centerYAnchor.constraint(equalTo: ring.centerYAnchor),
            breakdown.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 18),
            breakdown.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            breakdown.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            breakdown.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),
            reviewBtn.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 24),
            reviewBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            reviewBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            reviewBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func openReview() {
        let vc = PartAnswerVC(questions: flattened.map { $0.q }, selectedAnswers: answers)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - ExamOnlineEventVC (Port of Migii_TOEIC_.ExamOnlineEventVC)

public final class ExamOnlineEventVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var events: [ObjectListEvent.Event] = []
    private let table = UITableView(frame: .zero, style: .plain)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: "TOEIC Online Events")
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(table)
        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 8),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        APIClient.shared.fetchOnlineEvents { [weak self] items in
            self?.events = items
            self?.table.reloadData()
        }
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { events.count }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let ev = events[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = .clear
        cell.textLabel?.text = ev.title ?? "Online Event #\(ev.event_id)"
        cell.textLabel?.font = AppFonts.bold(15)
        cell.detailTextLabel?.text = "\(ev.count_question ?? 200) Qs • \(ev.time ?? 120) min • \(ev.status == 1 ? "Live Now" : "Upcoming")"
        cell.detailTextLabel?.textColor = ev.status == 1 ? ColorHelper.correctTeal : ColorHelper.textSecondary
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let ev = events[indexPath.row]
        let mockExam = ExamListJSONObject.Question(id: ev.event_id, title: ev.title ?? "Online Trial", hidden_title: nil, time: ev.time ?? 120)
        navigationController?.pushViewController(ExamPrepareVC(exam: mockExam, isMini: false), animated: true)
    }
}
