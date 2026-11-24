import UIKit

// Port of Migii_TOEIC_.PartDescriptionVC (0x1005328d0), PartDesPracticeWrongVC (0x1005724e4),
// PartPracticeVC (0x1003d823c), PartResultVC (0x10041dc30), PartAnswerVC (0x100055ae0)

public final class PartDescriptionVC: UIViewController {
    private let part: DataJSONObject.Part
    private var selectedCount: Int
    private var countButtons: [UIButton] = []

    public init(part: DataJSONObject.Part) {
        self.part = part
        self.selectedCount = max(5, part.number_ques)
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground

        let navBar = MigiiNavBar(title: "Part \(part.part_index): \(part.name)")
        navBar.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.addSubview(navBar)

        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false

        let iv = UIImageView(image: UIImage(named: part.icon))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let desc = UILabel()
        desc.text = part.description + (part.description_en.map { "\n\n\($0)" } ?? "")
        desc.font = AppFonts.regular(15)
        desc.textColor = ColorHelper.textPrimary
        desc.numberOfLines = 0
        desc.translatesAutoresizingMaskIntoConstraints = false

        let countTitle = UILabel()
        countTitle.text = tr("choose_number_question", "Number of questions")
        countTitle.font = AppFonts.bold(15)
        countTitle.textColor = ColorHelper.textPrimary
        countTitle.translatesAutoresizingMaskIntoConstraints = false

        let pillStack = UIStackView()
        pillStack.axis = .horizontal
        pillStack.spacing = 10
        pillStack.distribution = .fillEqually
        pillStack.translatesAutoresizingMaskIntoConstraints = false

        for n in [5, 10, 20, 30] {
            let btn = UIButton(type: .system)
            btn.tag = n
            btn.setTitle("\(n) Qs", for: .normal)
            btn.layer.cornerRadius = 10
            btn.addTarget(self, action: #selector(selectCount(_:)), for: .touchUpInside)
            pillStack.addArrangedSubview(btn)
            countButtons.append(btn)
        }

        let startBtn = UIButton(type: .system)
        startBtn.backgroundColor = ColorHelper.primary
        startBtn.setTitle(tr("start", "Start Practice"), for: .normal)
        startBtn.setTitleColor(.white, for: .normal)
        startBtn.titleLabel?.font = AppFonts.bold(16)
        startBtn.layer.cornerRadius = LayoutMetrics.pillCornerRadius
        startBtn.addTarget(self, action: #selector(startTapped), for: .touchUpInside)
        startBtn.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(card)
        card.addSubview(iv)
        card.addSubview(desc)
        view.addSubview(countTitle)
        view.addSubview(pillStack)
        view.addSubview(startBtn)

        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            navBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            card.topAnchor.constraint(equalTo: navBar.bottomAnchor, constant: 16),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            iv.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            iv.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iv.widthAnchor.constraint(equalToConstant: 72),
            iv.heightAnchor.constraint(equalToConstant: 72),

            desc.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 14),
            desc.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            desc.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            desc.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),

            countTitle.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 20),
            countTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),

            pillStack.topAnchor.constraint(equalTo: countTitle.bottomAnchor, constant: 10),
            pillStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            pillStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            pillStack.heightAnchor.constraint(equalToConstant: 44),

            startBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            startBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            startBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            startBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
        refreshPills()
    }

    @objc private func selectCount(_ sender: UIButton) {
        selectedCount = sender.tag
        refreshPills()
    }

    private func refreshPills() {
        for btn in countButtons {
            let active = btn.tag == selectedCount
            btn.backgroundColor = active ? ColorHelper.primary : ColorHelper.cardBackground
            btn.setTitleColor(active ? .white : ColorHelper.textPrimary, for: .normal)
            btn.titleLabel?.font = active ? AppFonts.bold(14) : AppFonts.regular(14)
        }
    }

    @objc private func startTapped() {
        let vc = PartPracticeVC(kind: part.kind, titleText: "Part \(part.part_index): \(part.name)", partNumber: part.part, limit: selectedCount)
        navigationController?.pushViewController(vc, animated: true)
    }
}

public final class PartDesPracticeWrongVC: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: tr("practice_wrong", "Incorrect Questions"))
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        view.addSubview(nav)

        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false
        let lbl = UILabel()
        lbl.text = "Practice missed questions filtered across Parts 1–7 to boost weak areas."
        lbl.font = AppFonts.regular(15)
        lbl.textColor = ColorHelper.textPrimary
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let btn = UIButton(type: .system)
        btn.backgroundColor = ColorHelper.orangeAccent
        btn.setTitle(tr("start", "Start Wrong Drill"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = AppFonts.bold(16)
        btn.layer.cornerRadius = LayoutMetrics.pillCornerRadius
        btn.addTarget(self, action: #selector(startWrong), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(card)
        card.addSubview(lbl)
        view.addSubview(btn)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            card.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            lbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 18),
            lbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -18),
            lbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            lbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            btn.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 24),
            btn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            btn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            btn.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func startWrong() {
        let vc = PartPracticeVC(kind: "incomplete sentences", titleText: "Wrong Questions Drill", partNumber: 5, limit: 10)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PartPracticeVC (Listening, Reading, Speaking, Writing UI)

public final class PartPracticeVC: UIViewController {
    private let kind: String
    private let titleText: String
    private let partNumber: Int
    private let limit: Int

    private var questions: [PracticeJSONObject.Question] = []
    private var currentIndex = 0
    private var selectedAnswers: [Int: Int] = [:] // questionIndex -> optionIndex
    private var writingNotes: [Int: String] = [:]
    private var elapsedSeconds = 0
    private var timer: Timer?
    private let speechAssist = SpeechAssist()
    private var isRecording = false

    private let headerView = UIView()
    private let qCounterLabel = UILabel()
    private let timerLabel = UILabel()
    private let progressBar = LinearProgressBar()
    private let audioBar = CardView()
    private let audioPlayBtn = UIButton(type: .system)
    private let audioStatusLabel = UILabel()
    private let webView = MyWebView()
    private let optionsStack = UIStackView()
    private let writingTextView = UITextView()
    private let recordButton = UIButton(type: .system)
    private let bottomNav = UIView()
    private let prevBtn = UIButton(type: .system)
    private let nextBtn = UIButton(type: .system)

    public init(kind: String, titleText: String, partNumber: Int, limit: Int) {
        self.kind = kind
        self.titleText = titleText
        self.partNumber = partNumber
        self.limit = limit
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    deinit {
        timer?.invalidate()
        AudioPlayerManager.shared.stop()
        speechAssist.stopRecording()
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadQuestions()
    }

    private func setupUI() {
        view.backgroundColor = ColorHelper.screenBackground

        headerView.backgroundColor = ColorHelper.cardBackground
        headerView.translatesAutoresizingMaskIntoConstraints = false

        let backBtn = UIButton(type: .system)
        backBtn.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "chevron.left"), for: .normal)
        backBtn.tintColor = ColorHelper.textPrimary
        backBtn.addTarget(self, action: #selector(handleClose), for: .touchUpInside)
        backBtn.translatesAutoresizingMaskIntoConstraints = false

        qCounterLabel.text = "0 / \(limit)"
        qCounterLabel.font = AppFonts.bold(16)
        qCounterLabel.textColor = ColorHelper.textPrimary
        qCounterLabel.translatesAutoresizingMaskIntoConstraints = false

        timerLabel.text = "00:00"
        timerLabel.font = AppFonts.regular(13)
        timerLabel.textColor = ColorHelper.textSecondary
        timerLabel.translatesAutoresizingMaskIntoConstraints = false

        let submitBtn = UIButton(type: .system)
        submitBtn.setTitle(tr("submit", "Submit"), for: .normal)
        submitBtn.titleLabel?.font = AppFonts.bold(14)
        submitBtn.setTitleColor(ColorHelper.primary, for: .normal)
        submitBtn.addTarget(self, action: #selector(handleSubmit), for: .touchUpInside)
        submitBtn.translatesAutoresizingMaskIntoConstraints = false

        headerView.addSubview(backBtn)
        headerView.addSubview(qCounterLabel)
        headerView.addSubview(timerLabel)
        headerView.addSubview(submitBtn)

        progressBar.translatesAutoresizingMaskIntoConstraints = false

        audioBar.translatesAutoresizingMaskIntoConstraints = false
        audioPlayBtn.setImage(UIImage(named: "ic_play_audio")?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "play.circle.fill"), for: .normal)
        audioPlayBtn.tintColor = ColorHelper.primary
        audioPlayBtn.addTarget(self, action: #selector(toggleAudio), for: .touchUpInside)
        audioPlayBtn.translatesAutoresizingMaskIntoConstraints = false

        audioStatusLabel.text = "Audio / TTS Ready (\(String(format: "%.1fx", UserDefaultHelper.shared.audioSpeed)))"
        audioStatusLabel.font = AppFonts.regular(13)
        audioStatusLabel.textColor = ColorHelper.textSecondary
        audioStatusLabel.translatesAutoresizingMaskIntoConstraints = false

        audioBar.addSubview(audioPlayBtn)
        audioBar.addSubview(audioStatusLabel)

        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.onSelectionChange = { [weak self] text in
            guard let self = self, !text.isEmpty, text.count <= 40 else { return }
            let vc = DetailWordDunnoVC(initialQuery: text)
            self.navigationController?.pushViewController(vc, animated: true)
        }

        optionsStack.axis = .vertical
        optionsStack.spacing = 8
        optionsStack.translatesAutoresizingMaskIntoConstraints = false

        writingTextView.font = AppFonts.regular(15)
        writingTextView.backgroundColor = ColorHelper.cardBackground
        writingTextView.textColor = ColorHelper.textPrimary
        writingTextView.layer.cornerRadius = 10
        writingTextView.layer.borderWidth = 1
        writingTextView.layer.borderColor = ColorHelper.separator.cgColor
        writingTextView.isHidden = true
        writingTextView.translatesAutoresizingMaskIntoConstraints = false

        recordButton.backgroundColor = ColorHelper.errorRed
        recordButton.setTitle("Hold / Tap to Record Speaking", for: .normal)
        recordButton.setTitleColor(.white, for: .normal)
        recordButton.titleLabel?.font = AppFonts.bold(15)
        recordButton.layer.cornerRadius = 22
        recordButton.isHidden = true
        recordButton.addTarget(self, action: #selector(toggleRecord), for: .touchUpInside)
        recordButton.translatesAutoresizingMaskIntoConstraints = false

        bottomNav.backgroundColor = ColorHelper.cardBackground
        bottomNav.translatesAutoresizingMaskIntoConstraints = false

        prevBtn.setTitle("← Prev", for: .normal)
        prevBtn.titleLabel?.font = AppFonts.bold(15)
        prevBtn.setTitleColor(ColorHelper.textPrimary, for: .normal)
        prevBtn.addTarget(self, action: #selector(goPrev), for: .touchUpInside)
        prevBtn.translatesAutoresizingMaskIntoConstraints = false

        nextBtn.setTitle("Next →", for: .normal)
        nextBtn.titleLabel?.font = AppFonts.bold(15)
        nextBtn.setTitleColor(ColorHelper.primary, for: .normal)
        nextBtn.addTarget(self, action: #selector(goNext), for: .touchUpInside)
        nextBtn.translatesAutoresizingMaskIntoConstraints = false

        bottomNav.addSubview(prevBtn)
        bottomNav.addSubview(nextBtn)

        view.addSubview(headerView)
        view.addSubview(progressBar)
        view.addSubview(audioBar)
        view.addSubview(webView)
        view.addSubview(optionsStack)
        view.addSubview(writingTextView)
        view.addSubview(recordButton)
        view.addSubview(bottomNav)

        let isSpeaking = partNumber >= 8 && partNumber <= 13
        let isWriting = partNumber >= 14
        audioBar.isHidden = (partNumber >= 5 && partNumber <= 7) || isWriting
        recordButton.isHidden = !isSpeaking
        writingTextView.isHidden = !isWriting
        optionsStack.isHidden = isSpeaking || isWriting

        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 50),

            backBtn.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 10),
            backBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            backBtn.widthAnchor.constraint(equalToConstant: 36),
            backBtn.heightAnchor.constraint(equalToConstant: 36),

            qCounterLabel.leadingAnchor.constraint(equalTo: backBtn.trailingAnchor, constant: 8),
            qCounterLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            timerLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            submitBtn.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -14),
            submitBtn.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),

            progressBar.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressBar.heightAnchor.constraint(equalToConstant: 4),

            audioBar.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 8),
            audioBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            audioBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            audioBar.heightAnchor.constraint(equalToConstant: audioBar.isHidden ? 0 : 48),

            audioPlayBtn.leadingAnchor.constraint(equalTo: audioBar.leadingAnchor, constant: 12),
            audioPlayBtn.centerYAnchor.constraint(equalTo: audioBar.centerYAnchor),
            audioPlayBtn.widthAnchor.constraint(equalToConstant: 32),
            audioPlayBtn.heightAnchor.constraint(equalToConstant: 32),

            audioStatusLabel.leadingAnchor.constraint(equalTo: audioPlayBtn.trailingAnchor, constant: 10),
            audioStatusLabel.centerYAnchor.constraint(equalTo: audioBar.centerYAnchor),

            webView.topAnchor.constraint(equalTo: audioBar.bottomAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            webView.heightAnchor.constraint(greaterThanOrEqualToConstant: 190),

            optionsStack.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 12),
            optionsStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            optionsStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            optionsStack.bottomAnchor.constraint(equalTo: bottomNav.topAnchor, constant: -12),

            writingTextView.topAnchor.constraint(equalTo: webView.bottomAnchor, constant: 12),
            writingTextView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 14),
            writingTextView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14),
            writingTextView.bottomAnchor.constraint(equalTo: bottomNav.topAnchor, constant: -12),

            recordButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            recordButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            recordButton.bottomAnchor.constraint(equalTo: bottomNav.topAnchor, constant: -18),
            recordButton.heightAnchor.constraint(equalToConstant: 46),

            bottomNav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomNav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomNav.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomNav.heightAnchor.constraint(equalToConstant: 52),

            prevBtn.leadingAnchor.constraint(equalTo: bottomNav.leadingAnchor, constant: 20),
            prevBtn.centerYAnchor.constraint(equalTo: bottomNav.centerYAnchor),
            nextBtn.trailingAnchor.constraint(equalTo: bottomNav.trailingAnchor, constant: -20),
            nextBtn.centerYAnchor.constraint(equalTo: bottomNav.centerYAnchor)
        ])
    }

    private func loadQuestions() {
        APIClient.shared.fetchPracticeQuestions(kind: kind, limit: limit) { [weak self] list in
            guard let self = self else { return }
            self.questions = list
            self.currentIndex = 0
            self.startTimer()
            self.renderQuestion()
        }
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedSeconds += 1
            self.timerLabel.text = String(format: "%02d:%02d", self.elapsedSeconds / 60, self.elapsedSeconds % 60)
        }
    }

    private func renderQuestion() {
        guard currentIndex < questions.count else { return }
        let q = questions[currentIndex]
        qCounterLabel.text = "\(currentIndex + 1) / \(questions.count)"
        progressBar.progress = CGFloat(currentIndex + 1) / CGFloat(max(1, questions.count))

        let passage = q.general?.txt_read ?? q.general?.txt_audio ?? ""
        let stem = q.content?.first?.question ?? "Choose the best answer."
        let bodyHTML = """
        \(passage.isEmpty ? "" : "<div class='box'>\(passage.replacingOccurrences(of: "\n", with: "<br>"))</div>")
        <div class='question'><p><b>Question \(currentIndex + 1):</b> \(stem)</p></div>
        """
        webView.loadTemplated(fileName: "question.html", bodyHTML: bodyHTML, fontSize: UserDefaultHelper.shared.fontSize)

        if partNumber >= 14 {
            writingTextView.text = writingNotes[currentIndex] ?? ""
        } else if partNumber < 8 {
            optionsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
            let labels = ["A", "B", "C", "D"]
            let answers = q.content?.first?.answers ?? ["Option A", "Option B", "Option C", "Option D"]
            let picked = selectedAnswers[currentIndex]
            for (idx, text) in answers.enumerated() {
                let isChosen = picked == idx
                let btn = UIButton(type: .system)
                btn.tag = idx
                btn.contentHorizontalAlignment = .leading
                btn.setTitle("  \(labels[idx % labels.count]). \(text)", for: .normal)
                btn.titleLabel?.font = isChosen ? AppFonts.bold(15) : AppFonts.regular(15)
                btn.titleLabel?.numberOfLines = 0
                btn.backgroundColor = isChosen ? ColorHelper.softTealTint : ColorHelper.cardBackground
                btn.setTitleColor(isChosen ? ColorHelper.primary : ColorHelper.textPrimary, for: .normal)
                btn.layer.cornerRadius = 10
                btn.layer.borderWidth = 1.2
                btn.layer.borderColor = (isChosen ? ColorHelper.primary : ColorHelper.separator).cgColor
                btn.addTarget(self, action: #selector(answerTapped(_:)), for: .touchUpInside)
                btn.heightAnchor.constraint(greaterThanOrEqualToConstant: 46).isActive = true
                optionsStack.addArrangedSubview(btn)
            }
        }
    }

    @objc private func answerTapped(_ sender: UIButton) {
        selectedAnswers[currentIndex] = sender.tag
        renderQuestion()
        if UserDefaultHelper.shared.autoNextQuestion && currentIndex + 1 < questions.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.goNext()
            }
        }
    }

    @objc private func toggleAudio() {
        guard currentIndex < questions.count else { return }
        if AudioPlayerManager.shared.isPlaying {
            AudioPlayerManager.shared.stop()
            audioStatusLabel.text = "Paused"
        } else if let url = questions[currentIndex].general?.audio, !url.isEmpty {
            audioStatusLabel.text = "Playing audio..."
            AudioPlayerManager.shared.playURL(url) { [weak self] cur, tot in
                self?.audioStatusLabel.text = String(format: "%02d:%02d / %02d:%02d", Int(cur)/60, Int(cur)%60, Int(tot)/60, Int(tot)%60)
            } onEnd: { [weak self] in
                self?.audioStatusLabel.text = "Completed"
            }
        } else {
            let script = questions[currentIndex].general?.txt_audio ?? questions[currentIndex].content?.first?.question ?? ""
            AudioPlayerManager.shared.speakWord(script)
            audioStatusLabel.text = "Speaking prompt via Speech Synth"
        }
    }

    @objc private func toggleRecord() {
        if isRecording {
            isRecording = false
            speechAssist.stopRecording()
            recordButton.backgroundColor = ColorHelper.errorRed
            recordButton.setTitle("Tap to Record Again", for: .normal)
        } else {
            speechAssist.requestPermissions { [weak self] granted in
                guard let self = self else { return }
                guard granted else {
                    ToastView.show("Enable Microphone & Speech permission in Settings.", isError: true)
                    return
                }
                self.isRecording = true
                self.recordButton.backgroundColor = ColorHelper.correctTeal
                self.recordButton.setTitle("Listening... Tap to Stop", for: .normal)
                self.speechAssist.onTranscriptUpdate = { text in
                    self.writingNotes[self.currentIndex] = text
                }
                self.speechAssist.startRecording()
            }
        }
    }

    @objc private func goPrev() {
        if partNumber >= 14 { writingNotes[currentIndex] = writingTextView.text }
        if currentIndex > 0 { currentIndex -= 1; renderQuestion() }
    }

    @objc private func goNext() {
        if partNumber >= 14 { writingNotes[currentIndex] = writingTextView.text }
        if currentIndex + 1 < questions.count { currentIndex += 1; renderQuestion() }
    }

    @objc private func handleClose() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func handleSubmit() {
        timer?.invalidate()
        AudioPlayerManager.shared.stop()
        speechAssist.stopRecording()
        if partNumber >= 14 { writingNotes[currentIndex] = writingTextView.text }

        var correct = 0
        for (i, q) in questions.enumerated() {
            let expected = Int(q.content?.first?.correctAnswer ?? "") ?? (q.correct_answers?.first ?? 0)
            if selectedAnswers[i] == expected {
                correct += 1
            } else if partNumber >= 8 && !(writingNotes[i] ?? "").isEmpty {
                correct += 1
            }
        }
        let history = PracticeHistoryResultObject(
            id: Int(Date().timeIntervalSince1970),
            kind: kind,
            correct: correct,
            total: questions.count,
            number_ques: questions.count,
            time: Double(elapsedSeconds),
            typeHistory: 0,
            currentDayRoute: nil,
            tagKind: nil
        )
        UserDefaultHelper.shared.appendPracticeHistory(history)
        let vc = PartResultVC(titleText: titleText, questions: questions, selectedAnswers: selectedAnswers, correctCount: correct, elapsedSeconds: elapsedSeconds)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - PartResultVC & PartAnswerVC

public final class PartResultVC: UIViewController {
    private let titleText: String
    private let questions: [PracticeJSONObject.Question]
    private let selectedAnswers: [Int: Int]
    private let correctCount: Int
    private let elapsedSeconds: Int

    public init(titleText: String, questions: [PracticeJSONObject.Question], selectedAnswers: [Int: Int], correctCount: Int, elapsedSeconds: Int) {
        self.titleText = titleText
        self.questions = questions
        self.selectedAnswers = selectedAnswers
        self.correctCount = correctCount
        self.elapsedSeconds = elapsedSeconds
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground

        let nav = MigiiNavBar(title: tr("result", "Practice Result"))
        nav.onBack = { [weak self] in self?.navigationController?.popToRootViewController(animated: true) }
        view.addSubview(nav)

        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false

        let ratio = questions.isEmpty ? 0 : CGFloat(correctCount) / CGFloat(questions.count)
        let ring = Circular2ProgressBar()
        ring.lineWidth = 12
        ring.progress = ratio
        ring.translatesAutoresizingMaskIntoConstraints = false

        let scoreLbl = UILabel()
        scoreLbl.text = "\(correctCount) / \(questions.count)"
        scoreLbl.font = AppFonts.bold(24)
        scoreLbl.textColor = ColorHelper.textPrimary
        scoreLbl.textAlignment = .center
        scoreLbl.translatesAutoresizingMaskIntoConstraints = false

        let detailLbl = UILabel()
        detailLbl.text = "\(titleText)\nAccuracy: \(Int(ratio * 100))%  •  Time: \(String(format: "%02d:%02d", elapsedSeconds / 60, elapsedSeconds % 60))"
        detailLbl.font = AppFonts.regular(14)
        detailLbl.textColor = ColorHelper.textSecondary
        detailLbl.textAlignment = .center
        detailLbl.numberOfLines = 0
        detailLbl.translatesAutoresizingMaskIntoConstraints = false

        let answerBtn = UIButton(type: .system)
        answerBtn.backgroundColor = ColorHelper.primary
        answerBtn.setTitle(tr("answers_explanations", "Answers and Explanations"), for: .normal)
        answerBtn.setTitleColor(.white, for: .normal)
        answerBtn.titleLabel?.font = AppFonts.bold(16)
        answerBtn.layer.cornerRadius = LayoutMetrics.pillCornerRadius
        answerBtn.addTarget(self, action: #selector(openAnswers), for: .touchUpInside)
        answerBtn.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(card)
        card.addSubview(ring)
        card.addSubview(scoreLbl)
        card.addSubview(detailLbl)
        view.addSubview(answerBtn)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            card.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 24),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            ring.topAnchor.constraint(equalTo: card.topAnchor, constant: 24),
            ring.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            ring.widthAnchor.constraint(equalToConstant: 140),
            ring.heightAnchor.constraint(equalToConstant: 140),

            scoreLbl.centerXAnchor.constraint(equalTo: ring.centerXAnchor),
            scoreLbl.centerYAnchor.constraint(equalTo: ring.centerYAnchor),

            detailLbl.topAnchor.constraint(equalTo: ring.bottomAnchor, constant: 18),
            detailLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            detailLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            detailLbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -24),

            answerBtn.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 24),
            answerBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            answerBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            answerBtn.heightAnchor.constraint(equalToConstant: 50)
        ])
    }

    @objc private func openAnswers() {
        let vc = PartAnswerVC(questions: questions, selectedAnswers: selectedAnswers)
        navigationController?.pushViewController(vc, animated: true)
    }
}

public final class PartAnswerVC: UIViewController {
    private let questions: [PracticeJSONObject.Question]
    private let selectedAnswers: [Int: Int]
    private var idx = 0
    private let webView = MyWebView()
    private let nav = MigiiNavBar(title: tr("answers_explanations", "Explanations"))

    public init(questions: [PracticeJSONObject.Question], selectedAnswers: [Int: Int]) {
        self.questions = questions
        self.selectedAnswers = selectedAnswers
        super.init(nibName: nil, bundle: nil)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        webView.translatesAutoresizingMaskIntoConstraints = false

        let bar = UIStackView()
        bar.axis = .horizontal
        bar.distribution = .fillEqually
        bar.translatesAutoresizingMaskIntoConstraints = false
        let prev = UIButton(type: .system)
        prev.setTitle("← Prev", for: .normal)
        prev.addTarget(self, action: #selector(onPrev), for: .touchUpInside)
        let next = UIButton(type: .system)
        next.setTitle("Next →", for: .normal)
        next.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        bar.addArrangedSubview(prev)
        bar.addArrangedSubview(next)

        view.addSubview(nav)
        view.addSubview(webView)
        view.addSubview(bar)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 8),
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),
            webView.bottomAnchor.constraint(equalTo: bar.topAnchor, constant: -8),
            bar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bar.heightAnchor.constraint(equalToConstant: 48)
        ])
        renderExplain()
    }

    private func renderExplain() {
        guard idx < questions.count else { return }
        nav.titleLabel.text = "Explanation \(idx + 1)/\(questions.count)"
        let q = questions[idx]
        let c = q.content?.first
        let expected = Int(c?.correctAnswer ?? "") ?? (q.correct_answers?.first ?? 0)
        let picked = selectedAnswers[idx]
        let letters = ["A", "B", "C", "D"]
        let pickedText = picked.map { letters[$0 % letters.count] } ?? "None"
        let correctText = letters[expected % letters.count]
        let expl = c?.explainAll?.text() ?? ""
        let body = """
        <div class='question'><p><b>Q\(idx + 1):</b> \(c?.question ?? "")</p></div>
        <div class='box'><p>Your answer: <b>\(pickedText)</b> &nbsp;|&nbsp; Correct: <b style='color:#32BEA6;'>\(correctText)</b></p></div>
        <div style='background:#48BCAA;padding:12px;border-radius:10px;color:#fff;' class='explain'><b>Explanation</b><br>\(expl)</div>
        """
        webView.loadTemplated(fileName: "explain.html", bodyHTML: body, fontSize: UserDefaultHelper.shared.fontSize)
    }

    @objc private func onPrev() { if idx > 0 { idx -= 1; renderExplain() } }
    @objc private func onNext() { if idx + 1 < questions.count { idx += 1; renderExplain() } }
}
