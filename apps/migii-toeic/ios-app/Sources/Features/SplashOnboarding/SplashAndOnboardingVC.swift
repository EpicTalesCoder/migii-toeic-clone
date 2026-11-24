import UIKit

// Port of Migii_TOEIC_.SplashVC (0x1000f2b78..0x1000fd000) & OnboardingVC (7 subviews)

public final class SplashVC: UIViewController {
    private let bgImageView = UIImageView(image: UIImage(named: "bg_splash"))
    private let characterView = UIImageView(image: UIImage(named: "ic_logo_migii_character"))
    private let titleImageView = UIImageView(image: UIImage(named: "text_migii_toeic"))
    private let subtitleLabel = UILabel()
    private let spinner = UIActivityIndicatorView(style: .medium)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bootstrapAndRoute()
    }

    private func setupUI() {
        view.backgroundColor = ColorHelper.screenBackground
        bgImageView.contentMode = .scaleAspectFill
        bgImageView.clipsToBounds = true
        bgImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bgImageView)
        bgImageView.pinEdges(to: view)

        characterView.contentMode = .scaleAspectFit
        characterView.translatesAutoresizingMaskIntoConstraints = false

        titleImageView.contentMode = .scaleAspectFit
        titleImageView.translatesAutoresizingMaskIntoConstraints = false

        subtitleLabel.text = "Improve your TOEIC score every day"
        subtitleLabel.font = AppFonts.regular(14)
        subtitleLabel.textColor = ColorHelper.deepTeal
        subtitleLabel.textAlignment = .center
        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false

        spinner.color = ColorHelper.primary
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(characterView)
        view.addSubview(titleImageView)
        view.addSubview(subtitleLabel)
        view.addSubview(spinner)

        NSLayoutConstraint.activate([
            characterView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            characterView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -56),
            characterView.widthAnchor.constraint(equalToConstant: 150),
            characterView.heightAnchor.constraint(equalToConstant: 150),

            titleImageView.topAnchor.constraint(equalTo: characterView.bottomAnchor, constant: 16),
            titleImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleImageView.widthAnchor.constraint(equalToConstant: 210),
            titleImageView.heightAnchor.constraint(equalToConstant: 44),

            subtitleLabel.topAnchor.constraint(equalTo: titleImageView.bottomAnchor, constant: 8),
            subtitleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),

            spinner.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -42),
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    // Port of SplashVC server sync & route decision (0x1000f9058..0x1000fae0c)
    private func bootstrapAndRoute() {
        APIClient.shared.fetchTimeServer { [weak self] serverTime in
            UserDefaults.standard.set(serverTime, forKey: UserDefaultHelper.Keys.timeServer)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                self?.routeNext()
            }
        }
    }

    private func routeNext() {
        let nextVC: UIViewController = UserDefaultHelper.shared.openOnboarding ? HomeVC() : OnboardingVC()
        navigationController?.setViewControllers([nextVC], animated: true)
    }
}

// MARK: - OnboardingVC (Port of OnboardingLanguageView, OnboardingIntroduceView, OnboardingReminderView, OnboardingStartView)

public final class OnboardingVC: UIViewController {
    private enum Step: Int, CaseIterable {
        case language = 0
        case introduce = 1
        case reminder = 2
        case start = 3
    }

    private var currentStep: Step = .language
    private var introPageIndex = 0
    private var selectedLangCode = LanguageManager.shared.currentCode
    private var reminderTime = UserDefaultHelper.shared.reminder

    private let progressBar = LinearProgressBar()
    private let containerView = UIView()
    private let primaryButton = UIButton(type: .system)
    private let skipButton = UIButton(type: .system)

    public override func viewDidLoad() {
        super.viewDidLoad()
        setupChrome()
        renderStep(.language)
    }

    private func setupChrome() {
        view.backgroundColor = ColorHelper.screenBackground

        progressBar.translatesAutoresizingMaskIntoConstraints = false
        containerView.translatesAutoresizingMaskIntoConstraints = false

        skipButton.setTitle(tr("skip", "Skip"), for: .normal)
        skipButton.titleLabel?.font = AppFonts.regular(14)
        skipButton.setTitleColor(ColorHelper.textSecondary, for: .normal)
        skipButton.addTarget(self, action: #selector(handleSkip), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false

        primaryButton.backgroundColor = ColorHelper.primary
        primaryButton.setTitleColor(.white, for: .normal)
        primaryButton.titleLabel?.font = AppFonts.bold(16)
        primaryButton.layer.cornerRadius = LayoutMetrics.pillCornerRadius
        primaryButton.addTarget(self, action: #selector(handlePrimary), for: .touchUpInside)
        primaryButton.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(progressBar)
        view.addSubview(skipButton)
        view.addSubview(containerView)
        view.addSubview(primaryButton)

        NSLayoutConstraint.activate([
            progressBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            progressBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressBar.trailingAnchor.constraint(equalTo: skipButton.leadingAnchor, constant: -12),
            progressBar.heightAnchor.constraint(equalToConstant: 6),

            skipButton.centerYAnchor.constraint(equalTo: progressBar.centerYAnchor),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            containerView.topAnchor.constraint(equalTo: progressBar.bottomAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: primaryButton.topAnchor, constant: -16),

            primaryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            primaryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            primaryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            primaryButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    private func renderStep(_ step: Step) {
        currentStep = step
        progressBar.progress = CGFloat(step.rawValue + 1) / CGFloat(Step.allCases.count)
        containerView.subviews.forEach { $0.removeFromSuperview() }

        switch step {
        case .language:
            skipButton.isHidden = true
            primaryButton.setTitle(tr("next", "Continue"), for: .normal)
            buildLanguageStep()
        case .introduce:
            skipButton.isHidden = false
            primaryButton.setTitle(tr("next", "Continue"), for: .normal)
            buildIntroduceStep()
        case .reminder:
            skipButton.isHidden = false
            primaryButton.setTitle(tr("save", "Save Reminder"), for: .normal)
            buildReminderStep()
        case .start:
            skipButton.isHidden = true
            primaryButton.setTitle(tr("start", "Start Learning"), for: .normal)
            buildStartStep()
        }
    }

    private func buildLanguageStep() {
        let title = UILabel()
        title.text = tr("choose_language", "Choose your language")
        title.font = AppFonts.bold(22)
        title.textColor = ColorHelper.textPrimary
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false

        let table = UITableView(frame: .zero, style: .plain)
        table.backgroundColor = .clear
        table.separatorStyle = .none
        table.dataSource = self
        table.delegate = self
        table.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(title)
        containerView.addSubview(table)
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
            title.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
            table.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 14),
            table.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            table.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            table.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        ])
    }

    private func buildIntroduceStep() {
        let slides: [(String, String, String)] = [
            ("splash_screen_1", "Personalized TOEIC Roadmap", "Follow a smart daily plan tailored to boost your Listening & Reading score."),
            ("splash_screen_2", "12,000+ Practice Questions", "Master Parts 1-7, Speaking, and Writing with detailed multi-language explanations."),
            ("splash_screen_3", "Full ETS Mock Exams", "Track real progress with timed 200-question simulations and online global rankings.")
        ]
        let slide = slides[introPageIndex % slides.count]

        let iv = UIImageView(image: UIImage(named: slide.0))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = slide.1
        title.font = AppFonts.bold(22)
        title.textColor = ColorHelper.textPrimary
        title.textAlignment = .center
        title.numberOfLines = 0
        title.translatesAutoresizingMaskIntoConstraints = false

        let desc = UILabel()
        desc.text = slide.2
        desc.font = AppFonts.regular(15)
        desc.textColor = ColorHelper.textSecondary
        desc.textAlignment = .center
        desc.numberOfLines = 0
        desc.translatesAutoresizingMaskIntoConstraints = false

        let seg = SegmentTabView(titles: ["1 • Plan", "2 • Practice", "3 • Exams"])
        seg.setSelected(introPageIndex, notify: false)
        seg.onSelectIndex = { [weak self] idx in
            self?.introPageIndex = idx
            self?.renderStep(.introduce)
        }
        seg.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(seg)
        containerView.addSubview(iv)
        containerView.addSubview(title)
        containerView.addSubview(desc)

        NSLayoutConstraint.activate([
            seg.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            seg.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            seg.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),
            seg.heightAnchor.constraint(equalToConstant: 40),

            iv.topAnchor.constraint(equalTo: seg.bottomAnchor, constant: 24),
            iv.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iv.widthAnchor.constraint(equalToConstant: 260),
            iv.heightAnchor.constraint(equalToConstant: 260),

            title.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 20),
            title.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 28),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -28),

            desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            desc.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 28),
            desc.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -28)
        ])
    }

    private func buildReminderStep() {
        let iv = UIImageView(image: UIImage(named: "img_character_say_hi"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = tr("reminder", "Daily Study Reminder")
        title.font = AppFonts.bold(22)
        title.textColor = ColorHelper.textPrimary
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false

        let desc = UILabel()
        desc.text = "Pick a daily notification time to keep your TOEIC streak alive."
        desc.font = AppFonts.regular(15)
        desc.textColor = ColorHelper.textSecondary
        desc.textAlignment = .center
        desc.numberOfLines = 0
        desc.translatesAutoresizingMaskIntoConstraints = false

        let picker = UIDatePicker()
        picker.datePickerMode = .time
        picker.preferredDatePickerStyle = .wheels
        picker.addTarget(self, action: #selector(reminderPickerChanged(_:)), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(iv)
        containerView.addSubview(title)
        containerView.addSubview(desc)
        containerView.addSubview(picker)

        NSLayoutConstraint.activate([
            iv.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            iv.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iv.widthAnchor.constraint(equalToConstant: 120),
            iv.heightAnchor.constraint(equalToConstant: 120),

            title.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 12),
            title.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 8),
            desc.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            desc.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            picker.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 12),
            picker.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }

    private func buildStartStep() {
        let iv = UIImageView(image: UIImage(named: "bg_onboarding_1_1"))
        iv.contentMode = .scaleAspectFit
        iv.translatesAutoresizingMaskIntoConstraints = false

        let title = UILabel()
        title.text = "Ready to conquer TOEIC!"
        title.font = AppFonts.bold(24)
        title.textColor = ColorHelper.textPrimary
        title.textAlignment = .center
        title.translatesAutoresizingMaskIntoConstraints = false

        let desc = UILabel()
        desc.text = "Practice offline anytime, review grammar & vocabulary, or sign in to sync progress across devices."
        desc.font = AppFonts.regular(15)
        desc.textColor = ColorHelper.textSecondary
        desc.textAlignment = .center
        desc.numberOfLines = 0
        desc.translatesAutoresizingMaskIntoConstraints = false

        let signInBtn = UIButton(type: .system)
        signInBtn.setTitle(tr("sign_in", "Already have an account? Sign In"), for: .normal)
        signInBtn.titleLabel?.font = AppFonts.bold(14)
        signInBtn.setTitleColor(ColorHelper.primary, for: .normal)
        signInBtn.addTarget(self, action: #selector(openSignIn), for: .touchUpInside)
        signInBtn.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(iv)
        containerView.addSubview(title)
        containerView.addSubview(desc)
        containerView.addSubview(signInBtn)

        NSLayoutConstraint.activate([
            iv.centerYAnchor.constraint(equalTo: containerView.centerYAnchor, constant: -70),
            iv.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            iv.widthAnchor.constraint(equalToConstant: 240),
            iv.heightAnchor.constraint(equalToConstant: 220),

            title.topAnchor.constraint(equalTo: iv.bottomAnchor, constant: 16),
            title.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 24),
            title.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -24),

            desc.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 10),
            desc.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 28),
            desc.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -28),

            signInBtn.topAnchor.constraint(equalTo: desc.bottomAnchor, constant: 18),
            signInBtn.centerXAnchor.constraint(equalTo: containerView.centerXAnchor)
        ])
    }

    @objc private func reminderPickerChanged(_ sender: UIDatePicker) {
        let fmt = DateFormatter()
        fmt.dateFormat = "HH:mm"
        reminderTime = fmt.string(from: sender.date)
    }

    @objc private func handlePrimary() {
        switch currentStep {
        case .language:
            LanguageManager.shared.setLanguage(selectedLangCode)
            UserDefaults.standard.set(true, forKey: UserDefaultHelper.Keys.setupLanguage)
            renderStep(.introduce)
        case .introduce:
            if introPageIndex < 2 {
                introPageIndex += 1
                renderStep(.introduce)
            } else {
                renderStep(.reminder)
            }
        case .reminder:
            UserDefaultHelper.shared.reminder = reminderTime
            UserDefaultHelper.shared.reminderActive = true
            PushNotiLocalHelper.shared.scheduleDailyReminder(timeString: reminderTime, active: true)
            renderStep(.start)
        case .start:
            finishOnboarding()
        }
    }

    @objc private func handleSkip() {
        finishOnboarding()
    }

    @objc private func openSignIn() {
        let vc = SignInVC()
        navigationController?.pushViewController(vc, animated: true)
    }

    private func finishOnboarding() {
        UserDefaultHelper.shared.openOnboarding = true
        UserDefaultHelper.shared.firstOpenApp = false
        navigationController?.setViewControllers([HomeVC()], animated: true)
    }
}

extension OnboardingVC: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        LanguageManager.supportedLanguages.count
    }

    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 60 }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let opt = LanguageManager.supportedLanguages[indexPath.row]
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.selectionStyle = .none
        cell.backgroundColor = .clear

        let card = CardView()
        card.layer.borderWidth = opt.code == selectedLangCode ? 1.5 : 0
        card.layer.borderColor = ColorHelper.primary.cgColor
        card.translatesAutoresizingMaskIntoConstraints = false

        let flag = UIImageView(image: UIImage(named: opt.iconName))
        flag.contentMode = .scaleAspectFit
        flag.translatesAutoresizingMaskIntoConstraints = false

        let lbl = UILabel()
        lbl.text = opt.displayName
        lbl.font = opt.code == selectedLangCode ? AppFonts.bold(15) : AppFonts.regular(15)
        lbl.textColor = ColorHelper.textPrimary
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let tick = UIImageView(image: UIImage(named: opt.code == selectedLangCode ? "ic_checked" : "ic_radio_button"))
        tick.contentMode = .scaleAspectFit
        tick.translatesAutoresizingMaskIntoConstraints = false

        cell.contentView.addSubview(card)
        card.addSubview(flag)
        card.addSubview(lbl)
        card.addSubview(tick)

        NSLayoutConstraint.activate([
            card.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 4),
            card.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -4),
            card.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
            card.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),

            flag.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
            flag.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            flag.widthAnchor.constraint(equalToConstant: 32),
            flag.heightAnchor.constraint(equalToConstant: 32),

            lbl.leadingAnchor.constraint(equalTo: flag.trailingAnchor, constant: 12),
            lbl.centerYAnchor.constraint(equalTo: card.centerYAnchor),

            tick.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
            tick.centerYAnchor.constraint(equalTo: card.centerYAnchor),
            tick.widthAnchor.constraint(equalToConstant: 22),
            tick.heightAnchor.constraint(equalToConstant: 22)
        ])
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedLangCode = LanguageManager.supportedLanguages[indexPath.row].code
        tableView.reloadData()
    }
}
