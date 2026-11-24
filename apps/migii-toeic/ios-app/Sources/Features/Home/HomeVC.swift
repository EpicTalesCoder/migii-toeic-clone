import UIKit

// Port of Migii_TOEIC_.HomeVC (0x100093840..0x1000a3000) + 5 TabViews

public final class HomeVC: UIViewController {
    public enum Tab: Int, CaseIterable {
        case practice = 0
        case exam = 1
        case roadmap = 2
        case premium = 3
        case settings = 4

        var selectedIcon: String {
            switch self {
            case .practice: return "ic_practice_selected"
            case .exam: return "ic_exam_select"
            case .roadmap: return "ic_route_select"
            case .premium: return "ic_premium_select"
            case .settings: return "ic_settings_select"
            }
        }

        var unselectedIcon: String {
            switch self {
            case .practice: return "ic_practice_unselected"
            case .exam: return "ic_exam_unselect"
            case .roadmap: return "ic_route_unselect"
            case .premium: return "ic_premium_unselect"
            case .settings: return "ic_setttings_unselect"
            }
        }

        var title: String {
            switch self {
            case .practice: return tr("practice_text", "Practice")
            case .exam: return tr("exam", "Exam")
            case .roadmap: return tr("route", "Roadmap")
            case .premium: return tr("premium", "Premium")
            case .settings: return tr("setting", "Setting")
            }
        }
    }

    private let contentContainer = UIView()
    private let tabBarContainer = UIView()
    private let tabStack = UIStackView()
    private var tabButtons: [UIButton] = []
    private var currentTab: Tab = .practice

    private lazy var practiceView = PracticeTabView(hostVC: self)
    private lazy var examView = ExamTabView(hostVC: self)
    private lazy var roadmapView = RoadmapTabView(hostVC: self)
    private lazy var premiumView = PremiumTabView(hostVC: self)
    private lazy var settingsView = SettingsTabView(hostVC: self)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        selectTab(.practice)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLanguageChanged), name: LanguageManager.languageDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handlePremiumChanged), name: StoreKitManager.premiumChangedNotification, object: nil)
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        practiceView.refreshData()
        examView.refreshData()
        roadmapView.refreshData()
        settingsView.refreshData()
    }

    private func setupLayout() {
        view.backgroundColor = ColorHelper.screenBackground
        contentContainer.translatesAutoresizingMaskIntoConstraints = false

        tabBarContainer.backgroundColor = ColorHelper.cardBackground
        tabBarContainer.layer.shadowColor = UIColor.black.cgColor
        tabBarContainer.layer.shadowOpacity = 0.08
        tabBarContainer.layer.shadowRadius = 6
        tabBarContainer.layer.shadowOffset = CGSize(width: 0, height: -2)
        tabBarContainer.translatesAutoresizingMaskIntoConstraints = false

        tabStack.axis = .horizontal
        tabStack.distribution = .fillEqually
        tabStack.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(contentContainer)
        view.addSubview(tabBarContainer)
        tabBarContainer.addSubview(tabStack)

        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: tabBarContainer.topAnchor),

            tabBarContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tabBarContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tabBarContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            tabStack.topAnchor.constraint(equalTo: tabBarContainer.topAnchor, constant: 6),
            tabStack.leadingAnchor.constraint(equalTo: tabBarContainer.leadingAnchor),
            tabStack.trailingAnchor.constraint(equalTo: tabBarContainer.trailingAnchor),
            tabStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -4),
            tabStack.heightAnchor.constraint(equalToConstant: LayoutMetrics.tabBarContentHeight)
        ])

        for tab in Tab.allCases {
            var config = UIButton.Configuration.plain()
            config.imagePlacement = .top
            config.imagePadding = 4
            config.baseForegroundColor = ColorHelper.textMuted
            let btn = UIButton(configuration: config)
            btn.tag = tab.rawValue
            btn.addTarget(self, action: #selector(tabTapped(_:)), for: .touchUpInside)
            tabStack.addArrangedSubview(btn)
            tabButtons.append(btn)
        }
    }

    @objc private func tabTapped(_ sender: UIButton) {
        guard let tab = Tab(rawValue: sender.tag) else { return }
        selectTab(tab)
    }

    public func selectTab(_ tab: Tab) {
        currentTab = tab
        contentContainer.subviews.forEach { $0.removeFromSuperview() }
        let targetView: UIView
        switch tab {
        case .practice: targetView = practiceView
        case .exam: targetView = examView
        case .roadmap: targetView = roadmapView
        case .premium: targetView = premiumView
        case .settings: targetView = settingsView
        }
        contentContainer.addSubview(targetView)
        targetView.pinEdges(to: contentContainer)
        updateTabButtons()
    }

    private func updateTabButtons() {
        for tab in Tab.allCases {
            let btn = tabButtons[tab.rawValue]
            let selected = (tab == currentTab)
            var config = UIButton.Configuration.plain()
            config.imagePlacement = .top
            config.imagePadding = 3
            let iconName = selected ? tab.selectedIcon : tab.unselectedIcon
            if let img = UIImage(named: iconName) {
                let renderer = UIGraphicsImageRenderer(size: CGSize(width: 24, height: 24))
                let scaled = renderer.image { _ in img.draw(in: CGRect(x: 0, y: 0, width: 24, height: 24)) }
                config.image = scaled.withRenderingMode(.alwaysOriginal)
            }
            config.title = tab.title
            config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = selected ? AppFonts.bold(11) : AppFonts.regular(11)
                outgoing.foregroundColor = selected ? (tab == .premium ? ColorHelper.orangeAccent : ColorHelper.primary) : ColorHelper.textMuted
                return outgoing
            }
            btn.configuration = config
        }
    }

    @objc private func handleLanguageChanged() {
        updateTabButtons()
        practiceView.refreshData()
        examView.refreshData()
        roadmapView.refreshData()
        premiumView.refreshData()
        settingsView.refreshData()
    }

    @objc private func handlePremiumChanged() {
        practiceView.refreshData()
        premiumView.refreshData()
        settingsView.refreshData()
    }
}

// MARK: - Tab 0: PracticeTabView (Port of Migii_TOEIC_.PracticeTabView at 0x100301970)

public final class PracticeTabView: UIView {
    private weak var hostVC: HomeVC?
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private var dataModel: DataJSONObject?

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
        dataModel = DataJSONObject.loadBundled()
        stack.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // Top Greeting + Crown + Quick Dictionary/Search Button
        let headerRow = UIView()
        let logo = UIImageView(image: UIImage(named: "text_migii_toeic"))
        logo.contentMode = .scaleAspectFit
        logo.translatesAutoresizingMaskIntoConstraints = false

        let searchBtn = UIButton(type: .system)
        searchBtn.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)
        searchBtn.tintColor = ColorHelper.primary
        searchBtn.addTarget(self, action: #selector(openDictionary), for: .touchUpInside)
        searchBtn.translatesAutoresizingMaskIntoConstraints = false

        let crownBtn = UIButton(type: .system)
        crownBtn.setImage(UIImage(named: "ic_crown")?.withRenderingMode(.alwaysOriginal), for: .normal)
        crownBtn.imageView?.contentMode = .scaleAspectFit
        crownBtn.addTarget(self, action: #selector(openPremium), for: .touchUpInside)
        crownBtn.translatesAutoresizingMaskIntoConstraints = false

        headerRow.addSubview(logo)
        headerRow.addSubview(searchBtn)
        headerRow.addSubview(crownBtn)
        NSLayoutConstraint.activate([
            headerRow.heightAnchor.constraint(equalToConstant: 40),
            logo.leadingAnchor.constraint(equalTo: headerRow.leadingAnchor),
            logo.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            logo.widthAnchor.constraint(equalToConstant: 145),
            logo.heightAnchor.constraint(equalToConstant: 32),

            crownBtn.trailingAnchor.constraint(equalTo: headerRow.trailingAnchor),
            crownBtn.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            crownBtn.widthAnchor.constraint(equalToConstant: 32),
            crownBtn.heightAnchor.constraint(equalToConstant: 32),

            searchBtn.trailingAnchor.constraint(equalTo: crownBtn.leadingAnchor, constant: -10),
            searchBtn.centerYAnchor.constraint(equalTo: headerRow.centerYAnchor),
            searchBtn.widthAnchor.constraint(equalToConstant: 32),
            searchBtn.heightAnchor.constraint(equalToConstant: 32)
        ])
        stack.addArrangedSubview(headerRow)

        // 4 Quick Shortcut Cards (Theory, Notebook, Online Exam, Offline Downloads)
        let shortcuts = UIStackView()
        shortcuts.axis = .horizontal
        shortcuts.distribution = .fillEqually
        shortcuts.spacing = 10
        shortcuts.addArrangedSubview(makeShortcutTile(icon: "ic_theory", title: tr("theory", "Theory"), action: #selector(openTheory)))
        shortcuts.addArrangedSubview(makeShortcutTile(icon: "ic_notebook", title: tr("notebook", "Notebook"), action: #selector(openNotebook)))
        shortcuts.addArrangedSubview(makeShortcutTile(icon: "ic_exam_online", title: tr("exam_online", "Event"), action: #selector(openExamOnline)))
        shortcuts.addArrangedSubview(makeShortcutTile(icon: "ic_download_manager", title: tr("download", "Offline"), action: #selector(openDownloadManager)))
        stack.addArrangedSubview(shortcuts)

        // Practice Wrong Mistakes Banner
        stack.addArrangedSubview(makeWrongQuestionsBanner())

        guard let data = dataModel else { return }
        addSkillSection(title: tr("listening", "Listening (Parts 1 - 4)"), parts: data.Listening, accent: ColorHelper.primary)
        addSkillSection(title: tr("reading", "Reading (Parts 5 - 7)"), parts: data.Reading, accent: ColorHelper.infoBlue)
        addSkillSection(title: tr("speaking", "Speaking (Parts 8 - 13)"), parts: data.Speaking, accent: ColorHelper.orangeAccent)
        addSkillSection(title: tr("writing", "Writing (Parts 14 - 16)"), parts: data.Writing, accent: ColorHelper.deepTeal)
    }

    private func makeShortcutTile(icon: String, title: String, action: Selector) -> UIView {
        let card = CardView()
        let iv = UIImageView(image: UIImage(named: icon))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let lbl = UILabel()
        lbl.text = title
        lbl.font = AppFonts.bold(12)
        lbl.textColor = ColorHelper.textPrimary
        lbl.textAlignment = .center
        lbl.numberOfLines = 1
        lbl.adjustsFontSizeToFitWidth = true
        lbl.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iv)
        card.addSubview(lbl)
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 78),
            iv.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            iv.centerXAnchor.constraint(equalTo: card.centerXAnchor),
            iv.widthAnchor.constraint(equalToConstant: 32),
            iv.heightAnchor.constraint(equalToConstant: 32),
            lbl.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 6),
            lbl.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 4),
            lbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -4)
        ])
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: action))
        return card
    }

    private func makeWrongQuestionsBanner() -> UIView {
        let card = CardView()
        card.backgroundColor = ColorHelper.warmBannerBg
        let iv = UIImageView(image: UIImage(named: "ic_part_wrong"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = tr("practice_wrong", "Review Incorrect Questions")
        title.font = AppFonts.bold(15)
        title.textColor = ColorHelper.textPrimary
        title.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = "Retry questions you answered incorrectly in recent drills"
        sub.font = AppFonts.regular(12)
        sub.textColor = ColorHelper.textSecondary
        sub.translatesAutoresizingMaskIntoConstraints = false

        let arrow = UIImageView(image: UIImage(named: "ic_arrow_right"))
        arrow.contentMode = .scaleAspectFit
        arrow.translatesAutoresizingMaskIntoConstraints = false

        card.addSubview(iv)
        card.addSubview(title)
        card.addSubview(sub)
        card.addSubview(arrow)
        NSLayoutConstraint.activate([
            card.heightAnchor.constraint(equalToConstant: 66),
            iv.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            iv.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            iv.widthAnchor.constraint(equalToConstant: 38),
            iv.heightAnchor.constraint(equalToConstant: 38),
            title.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: iv.trailingAnchor, constant: 12),
            title.trailingAnchor.constraint(equalTo: arrow.leadingAnchor, constant: -8),
            sub.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 3),
            sub.leadingAnchor.constraint(equalTo: title.leadingAnchor),
            sub.trailingAnchor.constraint(equalTo: title.trailingAnchor),
            arrow.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
            arrow.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            arrow.widthAnchor.constraint(equalToConstant: 18),
            arrow.heightAnchor.constraint(equalToConstant: 18)
        ])
        card.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openPracticeWrong)))
        return card
    }

    private func addSkillSection(title: String, parts: [DataJSONObject.Part], accent: UIColor) {
        let lbl = UILabel()
        lbl.text = title
        lbl.font = AppFonts.bold(17)
        lbl.textColor = ColorHelper.textPrimary
        stack.addArrangedSubview(lbl)

        let history = UserDefaultHelper.shared.loadHistoryList()

        for part in parts {
            let card = CardView()
            let iv = UIImageView(image: UIImage(named: part.icon))
            iv.contentMode = .scaleAspectFit
            iv.translatesAutoresizingMaskIntoConstraints = false

            let nameLbl = UILabel()
            nameLbl.text = "Part \(part.part_index): \(part.name)"
            nameLbl.font = AppFonts.bold(15)
            nameLbl.textColor = ColorHelper.textPrimary
            nameLbl.translatesAutoresizingMaskIntoConstraints = false

            let descLbl = UILabel()
            descLbl.text = part.description
            descLbl.font = AppFonts.regular(12)
            descLbl.textColor = ColorHelper.textSecondary
            descLbl.numberOfLines = 2
            descLbl.translatesAutoresizingMaskIntoConstraints = false

            let partHis = history.filter { $0.kind == part.kind }
            let totalDone = partHis.reduce(0) { $0 + $1.total }
            let totalRight = partHis.reduce(0) { $0 + $1.correct }
            let ratio: CGFloat = totalDone > 0 ? CGFloat(totalRight) / CGFloat(totalDone) : 0

            let bar = LinearProgressBar()
            bar.progressColor = accent
            bar.progress = ratio
            bar.translatesAutoresizingMaskIntoConstraints = false

            let statLbl = UILabel()
            statLbl.text = totalDone > 0 ? "\(Int(ratio * 100))% (\(totalRight)/\(totalDone))" : "\(part.number_ques) Qs / set"
            statLbl.font = AppFonts.regular(11)
            statLbl.textColor = accent
            statLbl.translatesAutoresizingMaskIntoConstraints = false

            card.addSubview(iv)
            card.addSubview(nameLbl)
            card.addSubview(descLbl)
            card.addSubview(bar)
            card.addSubview(statLbl)

            NSLayoutConstraint.activate([
                iv.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                iv.centerYAnchor.constraint(equalTo: card.centerYAnchor),
                iv.widthAnchor.constraint(equalToConstant: 46),
                iv.heightAnchor.constraint(equalToConstant: 46),

                nameLbl.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
                nameLbl.leadingAnchor.constraint(equalTo: iv.trailingAnchor, constant: 12),
                nameLbl.trailingAnchor.constraint(equalTo: statLbl.leadingAnchor, constant: -8),

                statLbl.centerYAnchor.constraint(equalTo: nameLbl.centerYAnchor),
                statLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

                descLbl.topAnchor.constraint(equalTo: nameLbl.bottomAnchor, constant: 4),
                descLbl.leadingAnchor.constraint(equalTo: nameLbl.leadingAnchor),
                descLbl.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),

                bar.topAnchor.constraint(equalTo: descLbl.bottomAnchor, constant: 8),
                bar.leadingAnchor.constraint(equalTo: nameLbl.leadingAnchor),
                bar.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                bar.heightAnchor.constraint(equalToConstant: 5),
                bar.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
            ])

            let tap = PartTapRecognizer(part: part, target: self, action: #selector(handlePartTap(_:)))
            card.addGestureRecognizer(tap)
            stack.addArrangedSubview(card)
        }
    }

    @objc private func handlePartTap(_ sender: PartTapRecognizer) {
        let vc = PartDescriptionVC(part: sender.part)
        hostVC?.navigationController?.pushViewController(vc, animated: true)
    }

    @objc private func openTheory() { hostVC?.navigationController?.pushViewController(TheoryVC(), animated: true) }
    @objc private func openNotebook() { hostVC?.navigationController?.pushViewController(NotebookVC(), animated: true) }
    @objc private func openExamOnline() { hostVC?.navigationController?.pushViewController(ExamOnlineEventVC(), animated: true) }
    @objc private func openDownloadManager() { hostVC?.navigationController?.pushViewController(DownloadManagerVC(), animated: true) }
    @objc private func openDictionary() { hostVC?.navigationController?.pushViewController(DetailWordDunnoVC(initialQuery: ""), animated: true) }
    @objc private func openPremium() { hostVC?.selectTab(.premium) }
    @objc private func openPracticeWrong() { hostVC?.navigationController?.pushViewController(PartDesPracticeWrongVC(), animated: true) }
}

private final class PartTapRecognizer: UITapGestureRecognizer {
    let part: DataJSONObject.Part
    init(part: DataJSONObject.Part, target: Any?, action: Selector?) {
        self.part = part
        super.init(target: target, action: action)
    }
}
