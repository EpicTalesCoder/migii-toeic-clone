import UIKit

// Port of Migii_TOEIC_.TheoryVC, VocabLessonVC, FlashCardVC, GameTheoryVC, GrammarLessonVC,
// NotebookVC, DetailWordDunnoVC, DownloadManagerVC

public final class TheoryVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var selectedTab = 0 // 0 = Vocabulary, 1 = Grammar
    private var level = UserDefaultHelper.shared.levelTheory
    private var vocabItems: [TheoryVocabObject] = []
    private var grammarItems: [TheoryGrammarObject] = []

    private let seg = SegmentTabView(titles: [tr("vocabulary", "Vocabulary"), tr("grammar", "Grammar")])
    private let levelStack = UIStackView()
    private var levelButtons: [UIButton] = []
    private let table = UITableView(frame: .zero, style: .plain)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: tr("theory", "TOEIC Theory"))
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        seg.translatesAutoresizingMaskIntoConstraints = false
        seg.onSelectIndex = { [weak self] idx in
            self?.selectedTab = idx
            self?.reloadItems()
        }

        levelStack.axis = .horizontal
        levelStack.spacing = 8
        levelStack.distribution = .fillEqually
        levelStack.translatesAutoresizingMaskIntoConstraints = false
        for lvl in ["450", "600", "750", "900"] {
            let b = UIButton(type: .system)
            b.setTitle("\(lvl)+", for: .normal)
            b.accessibilityIdentifier = lvl
            b.layer.cornerRadius = 10
            b.addTarget(self, action: #selector(selectLevel(_:)), for: .touchUpInside)
            levelStack.addArrangedSubview(b)
            levelButtons.append(b)
        }

        let quickActions = UIStackView()
        quickActions.axis = .horizontal
        quickActions.spacing = 10
        quickActions.distribution = .fillEqually
        quickActions.translatesAutoresizingMaskIntoConstraints = false

        let flashBtn = UIButton(type: .system)
        flashBtn.backgroundColor = ColorHelper.primary
        flashBtn.setTitle(tr("flash_card", "Flashcard Deck"), for: .normal)
        flashBtn.setTitleColor(.white, for: .normal)
        flashBtn.titleLabel?.font = AppFonts.bold(14)
        flashBtn.layer.cornerRadius = 12
        flashBtn.addTarget(self, action: #selector(openFlashcards), for: .touchUpInside)

        let gameBtn = UIButton(type: .system)
        gameBtn.backgroundColor = ColorHelper.orangeAccent
        gameBtn.setTitle("Word Match Game", for: .normal)
        gameBtn.setTitleColor(.white, for: .normal)
        gameBtn.titleLabel?.font = AppFonts.bold(14)
        gameBtn.layer.cornerRadius = 12
        gameBtn.addTarget(self, action: #selector(openGame), for: .touchUpInside)

        quickActions.addArrangedSubview(flashBtn)
        quickActions.addArrangedSubview(gameBtn)

        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(seg)
        view.addSubview(levelStack)
        view.addSubview(quickActions)
        view.addSubview(table)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            seg.topAnchor.constraint(equalTo: nav.bottomAnchor),
            seg.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            seg.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            seg.heightAnchor.constraint(equalToConstant: 44),

            levelStack.topAnchor.constraint(equalTo: seg.bottomAnchor, constant: 10),
            levelStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            levelStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            levelStack.heightAnchor.constraint(equalToConstant: 36),

            quickActions.topAnchor.constraint(equalTo: levelStack.bottomAnchor, constant: 10),
            quickActions.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            quickActions.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            quickActions.heightAnchor.constraint(equalToConstant: 42),

            table.topAnchor.constraint(equalTo: quickActions.bottomAnchor, constant: 10),
            table.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        reloadItems()
    }

    @objc private func selectLevel(_ sender: UIButton) {
        level = sender.accessibilityIdentifier ?? "450"
        UserDefaultHelper.shared.levelTheory = level
        reloadItems()
    }

    private func reloadItems() {
        for b in levelButtons {
            let active = b.accessibilityIdentifier == level
            b.backgroundColor = active ? ColorHelper.primary : ColorHelper.cardBackground
            b.setTitleColor(active ? .white : ColorHelper.textPrimary, for: .normal)
            b.titleLabel?.font = active ? AppFonts.bold(13) : AppFonts.regular(13)
        }
        vocabItems = TheoryDbHelper.shared.fetchWords(level: level, limit: 100)
        grammarItems = TheoryDbHelper.shared.fetchGrammars(level: level)
        table.reloadData()
    }

    @objc private func openFlashcards() {
        navigationController?.pushViewController(FlashCardVC(words: vocabItems), animated: true)
    }

    @objc private func openGame() {
        navigationController?.pushViewController(GameTheoryVC(words: vocabItems), animated: true)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        selectedTab == 0 ? vocabItems.count : grammarItems.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.backgroundColor = .clear
        if selectedTab == 0 {
            let v = vocabItems[indexPath.row]
            cell.textLabel?.text = "\(v.word)   \(v.pronounce ?? "")"
            cell.textLabel?.font = AppFonts.bold(15)
            cell.detailTextLabel?.text = v.short_mean
            cell.detailTextLabel?.font = AppFonts.regular(13)
            cell.detailTextLabel?.textColor = ColorHelper.textSecondary
        } else {
            let g = grammarItems[indexPath.row]
            let done = UserDefaultHelper.shared.checkedGrammarIds.contains(g.id)
            cell.textLabel?.text = (done ? "✓ " : "") + g.title
            cell.textLabel?.font = AppFonts.bold(15)
            cell.detailTextLabel?.text = g.parsedContents?.first?.sub_title ?? "Level \(level)"
            cell.detailTextLabel?.font = AppFonts.regular(13)
        }
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if selectedTab == 0 {
            navigationController?.pushViewController(VocabLessonVC(vocab: vocabItems[indexPath.row]), animated: true)
        } else {
            navigationController?.pushViewController(GrammarLessonVC(grammar: grammarItems[indexPath.row]), animated: true)
        }
    }
}

public final class VocabLessonVC: UIViewController {
    private let vocab: TheoryVocabObject
    public init(vocab: TheoryVocabObject) { self.vocab = vocab; super.init(nibName: nil, bundle: nil) }
    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: vocab.word)
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        let card = CardView()
        card.translatesAutoresizingMaskIntoConstraints = false

        let wordLbl = UILabel()
        wordLbl.text = vocab.word
        wordLbl.font = AppFonts.bold(28)
        wordLbl.textColor = ColorHelper.primary
        wordLbl.translatesAutoresizingMaskIntoConstraints = false

        let proLbl = UILabel()
        proLbl.text = vocab.pronounce ?? ""
        proLbl.font = AppFonts.italic(16)
        proLbl.textColor = ColorHelper.textSecondary
        proLbl.translatesAutoresizingMaskIntoConstraints = false

        let speakBtn = UIButton(type: .system)
        speakBtn.setImage(UIImage(named: "ic_speaker")?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "speaker.wave.2.fill"), for: .normal)
        speakBtn.tintColor = ColorHelper.primary
        speakBtn.addTarget(self, action: #selector(speak), for: .touchUpInside)
        speakBtn.translatesAutoresizingMaskIntoConstraints = false

        let meanLbl = UILabel()
        meanLbl.text = vocab.short_mean ?? ""
        meanLbl.font = AppFonts.regular(16)
        meanLbl.textColor = ColorHelper.textPrimary
        meanLbl.numberOfLines = 0
        meanLbl.translatesAutoresizingMaskIntoConstraints = false

        let saveBtn = UIButton(type: .system)
        saveBtn.backgroundColor = ColorHelper.primary
        saveBtn.setTitle(tr("add_note", "Save to Notebook"), for: .normal)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.titleLabel?.font = AppFonts.bold(15)
        saveBtn.layer.cornerRadius = 18
        saveBtn.addTarget(self, action: #selector(saveWord), for: .touchUpInside)
        saveBtn.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(card)
        card.addSubview(wordLbl)
        card.addSubview(proLbl)
        card.addSubview(speakBtn)
        card.addSubview(meanLbl)
        view.addSubview(saveBtn)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            card.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 20),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),

            wordLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 20),
            wordLbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            speakBtn.centerYAnchor.constraint(equalTo: wordLbl.centerYAnchor),
            speakBtn.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            speakBtn.widthAnchor.constraint(equalToConstant: 36),
            speakBtn.heightAnchor.constraint(equalToConstant: 36),

            proLbl.topAnchor.constraint(equalTo: wordLbl.bottomAnchor, constant: 4),
            proLbl.leadingAnchor.constraint(equalTo: wordLbl.leadingAnchor),
            meanLbl.topAnchor.constraint(equalTo: proLbl.bottomAnchor, constant: 14),
            meanLbl.leadingAnchor.constraint(equalTo: wordLbl.leadingAnchor),
            meanLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            meanLbl.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -20),

            saveBtn.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 20),
            saveBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            saveBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            saveBtn.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    @objc private func speak() { AudioPlayerManager.shared.speakWord(vocab.word) }

    @objc private func saveWord() {
        CoreDataManager.shared.upsert(entityName: "WordDB", key: vocab.word, value: vocab.short_mean ?? "")
        ToastView.show(tr("add_note_success", "Saved to Notebook"))
    }
}

public final class FlashCardVC: UIViewController {
    private let words: [TheoryVocabObject]
    private var idx = 0
    private var showingBack = false
    private let card = CardView()
    private let frontLabel = UILabel()
    private let hintLabel = UILabel()

    public init(words: [TheoryVocabObject]) { self.words = words; super.init(nibName: nil, bundle: nil) }
    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: tr("flash_card", "Flashcards"))
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        card.translatesAutoresizingMaskIntoConstraints = false
        frontLabel.font = AppFonts.bold(24)
        frontLabel.textColor = ColorHelper.textPrimary
        frontLabel.textAlignment = .center
        frontLabel.numberOfLines = 0
        frontLabel.translatesAutoresizingMaskIntoConstraints = false

        hintLabel.text = "Tap card to flip"
        hintLabel.font = AppFonts.regular(13)
        hintLabel.textColor = ColorHelper.textMuted
        hintLabel.textAlignment = .center
        hintLabel.translatesAutoresizingMaskIntoConstraints = false

        let controls = UIStackView()
        controls.axis = .horizontal
        controls.spacing = 12
        controls.distribution = .fillEqually
        controls.translatesAutoresizingMaskIntoConstraints = false

        let audioBtn = UIButton(type: .system)
        audioBtn.backgroundColor = ColorHelper.cardBackground
        audioBtn.setTitle("Pronounce", for: .normal)
        audioBtn.setTitleColor(ColorHelper.primary, for: .normal)
        audioBtn.layer.cornerRadius = 18
        audioBtn.addTarget(self, action: #selector(pronounce), for: .touchUpInside)

        let nextBtn = UIButton(type: .system)
        nextBtn.backgroundColor = ColorHelper.primary
        nextBtn.setTitle(tr("next", "Next Card"), for: .normal)
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.titleLabel?.font = AppFonts.bold(15)
        nextBtn.layer.cornerRadius = 18
        nextBtn.addTarget(self, action: #selector(nextCard), for: .touchUpInside)

        controls.addArrangedSubview(audioBtn)
        controls.addArrangedSubview(nextBtn)

        view.addSubview(nav)
        view.addSubview(card)
        card.addSubview(frontLabel)
        card.addSubview(hintLabel)
        view.addSubview(controls)

        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flipCard)))

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            card.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 40),
            card.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            card.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            card.heightAnchor.constraint(equalToConstant: 320),
            frontLabel.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            frontLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 20),
            frontLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -20),
            hintLabel.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16),
            hintLabel.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            controls.topAnchor.constraint(equalTo: card.bottomAnchor, constant: 28),
            controls.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            controls.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            controls.heightAnchor.constraint(equalToConstant: 46)
        ])
        updateCard()
    }

    private func updateCard() {
        guard !words.isEmpty else { frontLabel.text = "No words available"; return }
        let w = words[idx % words.count]
        frontLabel.text = showingBack ? (w.short_mean ?? w.word) : "\(w.word)\n\(w.pronounce ?? "")"
        frontLabel.textColor = showingBack ? ColorHelper.deepTeal : ColorHelper.textPrimary
        hintLabel.text = "\(idx % words.count + 1) / \(words.count) • Tap card to flip"
    }

    @objc private func flipCard() {
        showingBack.toggle()
        UIView.transition(with: card, duration: 0.28, options: .transitionFlipFromRight) {
            self.updateCard()
        }
    }

    @objc private func pronounce() {
        guard !words.isEmpty else { return }
        AudioPlayerManager.shared.speakWord(words[idx % words.count].word)
    }

    @objc private func nextCard() {
        showingBack = false
        idx += 1
        updateCard()
    }
}

public final class GameTheoryVC: UIViewController {
    private let words: [TheoryVocabObject]
    private var idx = 0
    private var score = 0
    private let promptLabel = UILabel()
    private let scoreLabel = UILabel()
    private let stack = UIStackView()
    private var currentChoices: [TheoryVocabObject] = []

    public init(words: [TheoryVocabObject]) { self.words = words; super.init(nibName: nil, bundle: nil) }
    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: "Word Match Game")
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        scoreLabel.font = AppFonts.bold(15)
        scoreLabel.textColor = ColorHelper.primary
        scoreLabel.textAlignment = .right
        scoreLabel.translatesAutoresizingMaskIntoConstraints = false

        promptLabel.font = AppFonts.bold(26)
        promptLabel.textColor = ColorHelper.textPrimary
        promptLabel.textAlignment = .center
        promptLabel.translatesAutoresizingMaskIntoConstraints = false

        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(scoreLabel)
        view.addSubview(promptLabel)
        view.addSubview(stack)

        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scoreLabel.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 12),
            scoreLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            promptLabel.topAnchor.constraint(equalTo: scoreLabel.bottomAnchor, constant: 28),
            promptLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            promptLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            stack.topAnchor.constraint(equalTo: promptLabel.bottomAnchor, constant: 28),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
        nextRound()
    }

    private func nextRound() {
        guard words.count >= 4 else { promptLabel.text = "Need 4+ words"; return }
        let target = words[idx % words.count]
        scoreLabel.text = "Score: \(score)"
        promptLabel.text = target.word
        var choices = [target]
        let pool = words.filter { $0.id != target.id }.shuffled()
        choices.append(contentsOf: pool.prefix(3))
        choices.shuffle()
        currentChoices = choices

        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (i, ch) in choices.enumerated() {
            let b = UIButton(type: .system)
            b.tag = i
            b.backgroundColor = ColorHelper.cardBackground
            b.setTitle(ch.short_mean ?? ch.word, for: .normal)
            b.setTitleColor(ColorHelper.textPrimary, for: .normal)
            b.titleLabel?.font = AppFonts.regular(14)
            b.titleLabel?.numberOfLines = 2
            b.layer.cornerRadius = 10
            b.layer.borderWidth = 1
            b.layer.borderColor = ColorHelper.separator.cgColor
            b.heightAnchor.constraint(greaterThanOrEqualToConstant: 52).isActive = true
            b.addTarget(self, action: #selector(pickChoice(_:)), for: .touchUpInside)
            stack.addArrangedSubview(b)
        }
    }

    @objc private func pickChoice(_ sender: UIButton) {
        let target = words[idx % words.count]
        if currentChoices[sender.tag].id == target.id {
            score += 10
            ToastView.show("Correct! +10")
        } else {
            ToastView.show("Try again: \(target.short_mean ?? "")", isError: true)
        }
        idx += 1
        nextRound()
    }
}

public final class GrammarLessonVC: UIViewController {
    private let grammar: TheoryGrammarObject
    public init(grammar: TheoryGrammarObject) { self.grammar = grammar; super.init(nibName: nil, bundle: nil) }
    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: grammar.title)
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        let tv = UITextView()
        tv.isEditable = false
        tv.backgroundColor = ColorHelper.cardBackground
        tv.layer.cornerRadius = 12
        tv.font = AppFonts.regular(15)
        tv.textColor = ColorHelper.textPrimary
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 14, bottom: 16, right: 14)
        tv.translatesAutoresizingMaskIntoConstraints = false

        var body = "\(grammar.title)\n\n"
        for section in grammar.parsedContents ?? [] {
            if let sub = section.sub_title { body += "• \(sub)\n" }
            for item in section.content ?? [] {
                if let c = item.c { body += "\(c)\n" }
                if let f = item.f { body += "Formula: \(f)\n" }
                for ex in item.e ?? [] {
                    if let e = ex.e { body += "  Example: \(e)\n" }
                }
                body += "\n"
            }
        }
        tv.text = body

        let doneBtn = UIButton(type: .system)
        doneBtn.backgroundColor = ColorHelper.primary
        doneBtn.setTitle("Mark Lesson Complete", for: .normal)
        doneBtn.setTitleColor(.white, for: .normal)
        doneBtn.titleLabel?.font = AppFonts.bold(15)
        doneBtn.layer.cornerRadius = 22
        doneBtn.addTarget(self, action: #selector(markComplete), for: .touchUpInside)
        doneBtn.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(tv)
        view.addSubview(doneBtn)
        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tv.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 14),
            tv.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tv.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tv.bottomAnchor.constraint(equalTo: doneBtn.topAnchor, constant: -14),
            doneBtn.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            doneBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            doneBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneBtn.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    @objc private func markComplete() {
        var ids = UserDefaultHelper.shared.checkedGrammarIds
        if !ids.contains(grammar.id) {
            ids.append(grammar.id)
            UserDefaultHelper.shared.checkedGrammarIds = ids
        }
        ToastView.show("Lesson marked completed")
    }
}

// MARK: - NotebookVC, DetailWordDunnoVC, DownloadManagerVC

public final class NotebookVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private var savedWords: [(key: String, value: String)] = []
    private let table = UITableView(frame: .zero, style: .plain)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: tr("notebook", "My Notebook"), rightIconName: "ic_add")
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        nav.rightButton.addTarget(self, action: #selector(addWord), for: .touchUpInside)

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

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        savedWords = CoreDataManager.shared.fetchAll(entityName: "WordDB")
        table.reloadData()
    }

    @objc private func addWord() {
        let alert = UIAlertController(title: tr("add_word_yourself", "Add Vocabulary"), message: nil, preferredStyle: .alert)
        alert.addTextField { $0.placeholder = "English word" }
        alert.addTextField { $0.placeholder = "Meaning / note" }
        alert.addAction(UIAlertAction(title: tr("cancel", "Cancel"), style: .cancel))
        alert.addAction(UIAlertAction(title: tr("add", "Add"), style: .default) { [weak self] _ in
            guard let w = alert.textFields?[0].text?.trimmingCharacters(in: .whitespaces), !w.isEmpty else { return }
            let m = alert.textFields?[1].text ?? ""
            CoreDataManager.shared.upsert(entityName: "WordDB", key: w, value: m)
            self?.savedWords = CoreDataManager.shared.fetchAll(entityName: "WordDB")
            self?.table.reloadData()
        })
        present(alert, animated: true)
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { savedWords.count }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let row = savedWords[indexPath.row]
        cell.textLabel?.text = row.key
        cell.textLabel?.font = AppFonts.bold(15)
        cell.detailTextLabel?.text = row.value
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(DetailWordDunnoVC(initialQuery: savedWords[indexPath.row].key), animated: true)
    }
}

public final class DetailWordDunnoVC: UIViewController {
    private let initialQuery: String
    private let searchField = CustomTextField(placeholder: "Look up English word or phrase...", iconName: nil)
    private let resultText = UITextView()

    public init(initialQuery: String) {
        self.initialQuery = initialQuery
        super.init(nibName: nil, bundle: nil)
    }
    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: "Dictionary (Dunno AI)")
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        searchField.textField.text = initialQuery
        searchField.translatesAutoresizingMaskIntoConstraints = false

        let searchBtn = UIButton(type: .system)
        searchBtn.backgroundColor = ColorHelper.primary
        searchBtn.setTitle("Search", for: .normal)
        searchBtn.setTitleColor(.white, for: .normal)
        searchBtn.layer.cornerRadius = 10
        searchBtn.addTarget(self, action: #selector(runSearch), for: .touchUpInside)
        searchBtn.translatesAutoresizingMaskIntoConstraints = false

        resultText.isEditable = false
        resultText.font = AppFonts.regular(15)
        resultText.backgroundColor = ColorHelper.cardBackground
        resultText.layer.cornerRadius = 12
        resultText.textContainerInset = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
        resultText.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(searchField)
        view.addSubview(searchBtn)
        view.addSubview(resultText)
        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            searchField.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 12),
            searchField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            searchField.trailingAnchor.constraint(equalTo: searchBtn.leadingAnchor, constant: -8),
            searchBtn.centerYAnchor.constraint(equalTo: searchField.containerView.centerYAnchor),
            searchBtn.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            searchBtn.widthAnchor.constraint(equalToConstant: 80),
            searchBtn.heightAnchor.constraint(equalToConstant: 44),
            resultText.topAnchor.constraint(equalTo: searchField.bottomAnchor, constant: 14),
            resultText.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            resultText.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            resultText.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
        if !initialQuery.isEmpty { runSearch() }
    }

    @objc private func runSearch() {
        let q = (searchField.textField.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        guard !q.isEmpty else { return }
        resultText.text = "Searching \"\(q)\"..."
        APIClient.shared.searchDictionary(word: q) { [weak self] res in
            guard let self = self else { return }
            if let first = res?.result?.first {
                var out = "\(first.word ?? q)\n"
                if let us = first.pronounce?.us { out += "US: /\(us)/\n" }
                for blk in first.content ?? [] {
                    if let k = blk.kind { out += "\n[\(k)]\n" }
                    for m in blk.means ?? [] {
                        out += "  • \(m.mean ?? "")\n"
                    }
                }
                self.resultText.text = out
            } else {
                let localMatch = TheoryDbHelper.shared.seededVocab(level: "450").first { $0.word.caseInsensitiveCompare(q) == .orderedSame }
                self.resultText.text = localMatch.map { "\($0.word) \($0.pronounce ?? "")\n\n\($0.short_mean ?? "")" }
                    ?? "Offline lookup: tap Pronunciation or save \"\(q)\" to your Notebook."
            }
        }
    }
}

public final class DownloadManagerVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    private let parts: [DataJSONObject.Part] = {
        let d = DataJSONObject.loadBundled()
        return (d?.Listening ?? []) + (d?.Reading ?? [])
    }()
    private let table = UITableView(frame: .zero, style: .plain)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: tr("download_manager", "Offline Manager"))
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

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { parts.count }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        let p = parts[indexPath.row]
        let isDownloaded = UserDefaultHelper.shared.partKindDownloaded.contains(p.kind)
        cell.textLabel?.text = "Part \(p.part_index): \(p.name)"
        cell.textLabel?.font = AppFonts.bold(15)
        cell.detailTextLabel?.text = isDownloaded ? "Downloaded for Offline Practice" : "Tap to cache offline pack"
        cell.detailTextLabel?.textColor = isDownloaded ? ColorHelper.correctTeal : ColorHelper.textSecondary
        return cell
    }
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let kind = parts[indexPath.row].kind
        APIClient.shared.fetchPracticeQuestions(kind: kind, limit: 20) { _ in
            var set = Set(UserDefaultHelper.shared.partKindDownloaded)
            set.insert(kind)
            UserDefaultHelper.shared.partKindDownloaded = Array(set)
            ToastView.show("Downloaded Part \(self.parts[indexPath.row].part_index)")
            tableView.reloadData()
        }
    }
}
