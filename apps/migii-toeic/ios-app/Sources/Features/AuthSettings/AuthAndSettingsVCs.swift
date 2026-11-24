import UIKit

// Port of Migii_TOEIC_.PremiumTabView (0x10040bde4), InvoicesSkuVC (0x10034e790),
// SettingsTabView (0x1005ac324, 16 SettingsType rows), SignInVC, RegisterVC, UserProfileVC,
// ChangePasswordVC, IntroduceAppVC (0x10001d960), FaqVC (0x1004a6dcc)

public final class PremiumTabView: UIView {
    private weak var hostVC: HomeVC?
    private let scrollView = UIScrollView()
    private let stack = UIStackView()
    private var selectedSKU = StoreKitManager.defaultPlans[1].productID

    public init(hostVC: HomeVC) {
        self.hostVC = hostVC
        super.init(frame: .zero)
        setup()
        refreshData()
        StoreKitManager.shared.fetchProducts()
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

        let hero = CardView()
        hero.backgroundColor = ColorHelper.warmBannerBg
        let character = UIImageView(image: UIImage(named: "img_character_premium"))
        character.contentMode = .scaleAspectFit
        character.translatesAutoresizingMaskIntoConstraints = false

        let badge = UILabel()
        badge.text = UserDefaultHelper.shared.isPremium ? "Migii Premium Active" : "Upgrade to Migii Premium"
        badge.font = AppFonts.bold(19)
        badge.textColor = ColorHelper.orangeAccent
        badge.translatesAutoresizingMaskIntoConstraints = false

        let sub = UILabel()
        sub.text = "Unlock 12,000+ TOEIC questions, offline downloads, full ETS mock exams, & Speaking/Writing AI review."
        sub.font = AppFonts.regular(13)
        sub.textColor = ColorHelper.textPrimary
        sub.numberOfLines = 0
        sub.translatesAutoresizingMaskIntoConstraints = false

        hero.addSubview(character)
        hero.addSubview(badge)
        hero.addSubview(sub)
        NSLayoutConstraint.activate([
            character.leadingAnchor.constraint(equalTo: hero.leadingAnchor, constant: 12),
            character.centerYAnchor.constraint(equalTo: hero.centerYAnchor),
            character.widthAnchor.constraint(equalToConstant: 72),
            character.heightAnchor.constraint(equalToConstant: 72),
            badge.topAnchor.constraint(equalTo: hero.topAnchor, constant: 16),
            badge.leadingAnchor.constraint(equalTo: character.trailingAnchor, constant: 12),
            badge.trailingAnchor.constraint(equalTo: hero.trailingAnchor, constant: -12),
            sub.topAnchor.constraint(equalTo: badge.bottomAnchor, constant: 6),
            sub.leadingAnchor.constraint(equalTo: badge.leadingAnchor),
            sub.trailingAnchor.constraint(equalTo: badge.trailingAnchor),
            sub.bottomAnchor.constraint(equalTo: hero.bottomAnchor, constant: -16)
        ])
        stack.addArrangedSubview(hero)

        // SKU Selection Cards
        for plan in StoreKitManager.defaultPlans {
            let isSelected = plan.productID == selectedSKU
            let card = CardView()
            card.layer.borderWidth = isSelected ? 2 : 1
            card.layer.borderColor = (isSelected ? ColorHelper.orangeAccent : ColorHelper.separator).cgColor

            let title = UILabel()
            title.text = plan.title
            title.font = AppFonts.bold(16)
            title.textColor = ColorHelper.textPrimary
            title.translatesAutoresizingMaskIntoConstraints = false

            let sub = UILabel()
            sub.text = plan.subtitle
            sub.font = AppFonts.regular(12)
            sub.textColor = ColorHelper.textSecondary
            sub.translatesAutoresizingMaskIntoConstraints = false

            let price = UILabel()
            price.text = plan.defaultPrice
            price.font = AppFonts.bold(17)
            price.textColor = ColorHelper.orangeAccent
            price.translatesAutoresizingMaskIntoConstraints = false

            card.addSubview(title)
            card.addSubview(sub)
            card.addSubview(price)
            NSLayoutConstraint.activate([
                title.topAnchor.constraint(equalTo: card.topAnchor, constant: 14),
                title.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 14),
                sub.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 4),
                sub.leadingAnchor.constraint(equalTo: title.leadingAnchor),
                sub.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -14),
                price.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -14),
                price.centerYAnchor.constraint(equalTo: card.centerYAnchor)
            ])
            card.addGestureRecognizer(PlanTap(sku: plan.productID, target: self, action: #selector(pickPlan(_:))))
            stack.addArrangedSubview(card)
        }

        let upgradeBtn = UIButton(type: .system)
        upgradeBtn.backgroundColor = ColorHelper.orangeAccent
        upgradeBtn.setTitle(tr("upgrade_v2", "Upgrade Now"), for: .normal)
        upgradeBtn.setTitleColor(.white, for: .normal)
        upgradeBtn.titleLabel?.font = AppFonts.bold(16)
        upgradeBtn.layer.cornerRadius = LayoutMetrics.pillCornerRadius
        upgradeBtn.heightAnchor.constraint(equalToConstant: 48).isActive = true
        upgradeBtn.addTarget(self, action: #selector(buySelected), for: .touchUpInside)
        stack.addArrangedSubview(upgradeBtn)

        let restoreBtn = UIButton(type: .system)
        restoreBtn.setTitle(tr("restore", "Restore Purchases"), for: .normal)
        restoreBtn.setTitleColor(ColorHelper.primary, for: .normal)
        restoreBtn.addTarget(self, action: #selector(restoreTapped), for: .touchUpInside)
        stack.addArrangedSubview(restoreBtn)

        // Verified Student Reviews from bundled json_feedback_user.json
        let reviews = PremiumReviewObject.loadBundledReviews()
        if !reviews.isEmpty {
            let rvTitle = UILabel()
            rvTitle.text = "Learner Reviews"
            rvTitle.font = AppFonts.bold(17)
            rvTitle.textColor = ColorHelper.textPrimary
            stack.addArrangedSubview(rvTitle)

            for r in reviews.prefix(4) {
                let card = CardView()
                let name = UILabel()
                name.text = "\(r.name ?? "Learner") • \(String(repeating: "★", count: max(1, r.star ?? 5)))"
                name.font = AppFonts.bold(14)
                name.textColor = ColorHelper.goldAccent
                name.translatesAutoresizingMaskIntoConstraints = false

                let body = UILabel()
                body.text = r.content ?? ""
                body.font = AppFonts.regular(13)
                body.textColor = ColorHelper.textPrimary
                body.numberOfLines = 3
                body.translatesAutoresizingMaskIntoConstraints = false

                card.addSubview(name)
                card.addSubview(body)
                NSLayoutConstraint.activate([
                    name.topAnchor.constraint(equalTo: card.topAnchor, constant: 12),
                    name.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                    body.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 4),
                    body.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 12),
                    body.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -12),
                    body.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -12)
                ])
                stack.addArrangedSubview(card)
            }
        }
    }

    @objc private func pickPlan(_ sender: PlanTap) {
        selectedSKU = sender.sku
        refreshData()
    }

    @objc private func buySelected() {
        StoreKitManager.shared.purchase(productID: selectedSKU)
        ToastView.show("StoreKit purchase queued for \(selectedSKU)")
    }

    @objc private func restoreTapped() {
        StoreKitManager.shared.restorePurchases()
        ToastView.show("Checking previous purchases...")
    }
}

private final class PlanTap: UITapGestureRecognizer {
    let sku: String
    init(sku: String, target: Any?, action: Selector?) {
        self.sku = sku
        super.init(target: target, action: action)
    }
}

// MARK: - SettingsTabView (Port of Migii_TOEIC_.SettingsTabView & all 16 SettingsType cases)

public final class SettingsTabView: UIView, UITableViewDataSource, UITableViewDelegate {
    private weak var hostVC: HomeVC?
    private let table = UITableView(frame: .zero, style: .insetGrouped)

    private struct Row {
        let type: SettingsType
        let title: String
        let detail: String
        let icon: String
    }
    private var rows: [Row] = []

    public init(hostVC: HomeVC) {
        self.hostVC = hostVC
        super.init(frame: .zero)
        setup()
        refreshData()
    }
    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    private func setup() {
        backgroundColor = ColorHelper.screenBackground
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.translatesAutoresizingMaskIntoConstraints = false
        addSubview(table)
        table.pinEdges(to: self)
    }

    public func refreshData() {
        let user = UserDefaultHelper.shared.loadUserProfile()
        let langName = LanguageManager.shared.currentOption.displayName
        let themeLabel = ThemeManager.shared.isDarkMode ? "Dark" : "Light"
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.4.1"

        rows = [
            Row(type: .ACCOUNT, title: user?.name ?? tr("sign_in", "Account & Sign In"), detail: user?.email ?? "Sync study progress", icon: "ic_account"),
            Row(type: .LANGUAGE_DEVICE, title: tr("language", "Language"), detail: langName, icon: "ic_language"),
            Row(type: .THEME_APP, title: tr("night_mode", "Appearance Theme"), detail: themeLabel, icon: "ic_night_mode"),
            Row(type: .DOWNLOAD_MANAGER, title: tr("download_manager", "Offline Manager"), detail: "\(UserDefaultHelper.shared.partKindDownloaded.count) packs", icon: "ic_download_manager"),
            Row(type: .ANSWER_INTERFACE, title: tr("answer_interface", "Answer Layout"), detail: UserDefaultHelper.shared.typeChoiceAnswer == 0 ? tr("bottom_screen", "Bottom") : tr("above_the_topic", "On Answer"), icon: "ic_display"),
            Row(type: .SHOWS, title: tr("choose_font_size", "Font Size & Audio Speed"), detail: "\(UserDefaultHelper.shared.fontSize)pt • \(String(format: "%.1fx", UserDefaultHelper.shared.audioSpeed))", icon: "ic_font_size"),
            Row(type: .REMINDER, title: tr("reminder", "Study Reminder"), detail: UserDefaultHelper.shared.reminderActive ? UserDefaultHelper.shared.reminder : "Off", icon: "ic_alarm_clock"),
            Row(type: .INTRODUCE_APP, title: tr("introduce_app", "About Migii TOEIC"), detail: "", icon: "ic_information"),
            Row(type: .FAQ, title: "FAQ", detail: "Common questions", icon: "ic_faq"),
            Row(type: .SHARE, title: tr("share", "Share App"), detail: "", icon: "ic_share"),
            Row(type: .FEEDBACK, title: tr("feedback", "Send Feedback"), detail: "", icon: "ic_feedback"),
            Row(type: .RATE, title: tr("rate", "Rate Migii TOEIC"), detail: "", icon: "ic_rate"),
            Row(type: .POLICY, title: tr("policy", "Terms & Privacy"), detail: "", icon: "ic_policy"),
            Row(type: .VERSION, title: tr("version", "Version"), detail: version, icon: "ic_version")
        ]
        table.reloadData()
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { rows.count }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        let row = rows[indexPath.row]
        cell.textLabel?.text = row.title
        cell.textLabel?.font = AppFonts.regular(15)
        cell.detailTextLabel?.text = row.detail
        cell.detailTextLabel?.font = AppFonts.regular(13)
        cell.imageView?.image = UIImage(named: row.icon)?.withRenderingMode(.alwaysTemplate)
        cell.imageView?.tintColor = ColorHelper.primary
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = rows[indexPath.row]
        switch row.type {
        case .ACCOUNT:
            let vc: UIViewController = UserDefaultHelper.shared.statusSignin ? UserProfileVC() : SignInVC()
            hostVC?.navigationController?.pushViewController(vc, animated: true)
        case .LANGUAGE_DEVICE:
            presentLanguagePicker()
        case .THEME_APP:
            let next = ThemeManager.shared.isDarkMode ? 1 : 2
            ThemeManager.shared.setTheme(index: next)
            refreshData()
        case .DOWNLOAD_MANAGER:
            hostVC?.navigationController?.pushViewController(DownloadManagerVC(), animated: true)
        case .ANSWER_INTERFACE:
            UserDefaultHelper.shared.typeChoiceAnswer = UserDefaultHelper.shared.typeChoiceAnswer == 0 ? 1 : 0
            refreshData()
        case .SHOWS:
            presentShowSettingsAlert()
        case .REMINDER:
            UserDefaultHelper.shared.reminderActive.toggle()
            PushNotiLocalHelper.shared.scheduleDailyReminder(timeString: UserDefaultHelper.shared.reminder, active: UserDefaultHelper.shared.reminderActive)
            refreshData()
        case .INTRODUCE_APP:
            hostVC?.navigationController?.pushViewController(IntroduceAppVC(), animated: true)
        case .FAQ:
            hostVC?.navigationController?.pushViewController(FaqVC(), animated: true)
        case .POLICY:
            if let url = URL(string: "https://eupgroup.net/apps/migii-toeic/terms.html") {
                UIApplication.shared.open(url)
            }
        case .SHARE:
            let act = UIActivityViewController(activityItems: ["Practice TOEIC with Migii TOEIC!"], applicationActivities: nil)
            hostVC?.present(act, animated: true)
        default:
            ToastView.show(row.title)
        }
    }

    private func presentLanguagePicker() {
        let sheet = UIAlertController(title: tr("choose_language", "Select App Language"), message: nil, preferredStyle: .actionSheet)
        for opt in LanguageManager.supportedLanguages {
            sheet.addAction(UIAlertAction(title: opt.displayName, style: .default) { _ in
                LanguageManager.shared.setLanguage(opt.code)
            })
        }
        sheet.addAction(UIAlertAction(title: tr("cancel", "Cancel"), style: .cancel))
        hostVC?.present(sheet, animated: true)
    }

    private func presentShowSettingsAlert() {
        let sheet = UIAlertController(title: "Reading & Audio Preferences", message: "Adjust question font size and playback speed", preferredStyle: .actionSheet)
        for sz in [14, 16, 18, 20] {
            sheet.addAction(UIAlertAction(title: "Font Size \(sz)pt", style: .default) { [weak self] _ in
                UserDefaultHelper.shared.fontSize = sz
                self?.refreshData()
            })
        }
        for sp: Float in [0.8, 1.0, 1.25] {
            sheet.addAction(UIAlertAction(title: "Audio Speed \(sp)x", style: .default) { [weak self] _ in
                UserDefaultHelper.shared.audioSpeed = sp
                self?.refreshData()
            })
        }
        sheet.addAction(UIAlertAction(title: tr("cancel", "Cancel"), style: .cancel))
        hostVC?.present(sheet, animated: true)
    }
}

// MARK: - Auth & Support VCs (SignInVC, RegisterVC, UserProfileVC, IntroduceAppVC, FaqVC)

public final class SignInVC: UIViewController {
    private let emailField = CustomTextField(placeholder: "Email", iconName: "ic_email")
    private let passwordField = CustomTextField(placeholder: "Password", iconName: nil, isSecure: true)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: tr("sign_in", "Sign In"))
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false

        let btn = UIButton(type: .system)
        btn.backgroundColor = ColorHelper.primary
        btn.setTitle(tr("sign_in", "Sign In"), for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = AppFonts.bold(16)
        btn.layer.cornerRadius = LayoutMetrics.pillCornerRadius
        btn.addTarget(self, action: #selector(submitLogin), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false

        let regBtn = UIButton(type: .system)
        regBtn.setTitle("Create New Account", for: .normal)
        regBtn.setTitleColor(ColorHelper.primary, for: .normal)
        regBtn.addTarget(self, action: #selector(openRegister), for: .touchUpInside)
        regBtn.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(btn)
        view.addSubview(regBtn)
        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            emailField.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 24),
            emailField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            emailField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 14),
            passwordField.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            btn.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 24),
            btn.leadingAnchor.constraint(equalTo: emailField.leadingAnchor),
            btn.trailingAnchor.constraint(equalTo: emailField.trailingAnchor),
            btn.heightAnchor.constraint(equalToConstant: 48),
            regBtn.topAnchor.constraint(equalTo: btn.bottomAnchor, constant: 16),
            regBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    @objc private func submitLogin() {
        let email = emailField.textField.text ?? ""
        let pass = passwordField.textField.text ?? ""
        guard !email.isEmpty, !pass.isEmpty else {
            emailField.showError(tr("can_not_null", "Required field"))
            return
        }
        emailField.clearError()
        APIClient.shared.signIn(email: email, password: pass) { [weak self] result in
            switch result {
            case .success(let user):
                UserDefaultHelper.shared.saveUserProfile(user)
                self?.navigationController?.popViewController(animated: true)
            case .failure(let msg):
                ToastView.show(msg, isError: true)
            }
        }
    }

    @objc private func openRegister() {
        navigationController?.pushViewController(RegisterVC(), animated: true)
    }
}

public final class RegisterVC: UIViewController {
    private let nameField = CustomTextField(placeholder: "Full name", iconName: "ic_user")
    private let emailField = CustomTextField(placeholder: "Email", iconName: "ic_email")
    private let passwordField = CustomTextField(placeholder: "Password", iconName: nil, isSecure: true)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: "Register Account")
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        nameField.translatesAutoresizingMaskIntoConstraints = false
        emailField.translatesAutoresizingMaskIntoConstraints = false
        passwordField.translatesAutoresizingMaskIntoConstraints = false

        let btn = UIButton(type: .system)
        btn.backgroundColor = ColorHelper.primary
        btn.setTitle("Create Account", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.titleLabel?.font = AppFonts.bold(16)
        btn.layer.cornerRadius = LayoutMetrics.pillCornerRadius
        btn.addTarget(self, action: #selector(submitRegister), for: .touchUpInside)
        btn.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(nameField)
        view.addSubview(emailField)
        view.addSubview(passwordField)
        view.addSubview(btn)
        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            nameField.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 20),
            nameField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            nameField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            emailField.topAnchor.constraint(equalTo: nameField.bottomAnchor, constant: 12),
            emailField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            emailField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            passwordField.topAnchor.constraint(equalTo: emailField.bottomAnchor, constant: 12),
            passwordField.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            passwordField.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            btn.topAnchor.constraint(equalTo: passwordField.bottomAnchor, constant: 22),
            btn.leadingAnchor.constraint(equalTo: nameField.leadingAnchor),
            btn.trailingAnchor.constraint(equalTo: nameField.trailingAnchor),
            btn.heightAnchor.constraint(equalToConstant: 48)
        ])
    }

    @objc private func submitRegister() {
        let name = nameField.textField.text ?? ""
        let email = emailField.textField.text ?? ""
        let pass = passwordField.textField.text ?? ""
        guard !name.isEmpty, !email.isEmpty, !pass.isEmpty else {
            ToastView.show(tr("can_not_null", "All fields are required"), isError: true)
            return
        }
        APIClient.shared.register(name: name, email: email, phone: "", password: pass) { [weak self] res in
            switch res {
            case .success(let u):
                UserDefaultHelper.shared.saveUserProfile(u)
                self?.navigationController?.popToRootViewController(animated: true)
            case .failure(let msg):
                ToastView.show(msg, isError: true)
            }
        }
    }
}

public final class UserProfileVC: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: "Profile")
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        let u = UserDefaultHelper.shared.loadUserProfile()
        let lbl = UILabel()
        lbl.text = "\(u?.name ?? "Learner")\n\(u?.email ?? "")"
        lbl.font = AppFonts.bold(18)
        lbl.textAlignment = .center
        lbl.numberOfLines = 0
        lbl.translatesAutoresizingMaskIntoConstraints = false

        let signOut = UIButton(type: .system)
        signOut.backgroundColor = ColorHelper.errorRed
        signOut.setTitle("Sign Out", for: .normal)
        signOut.setTitleColor(.white, for: .normal)
        signOut.titleLabel?.font = AppFonts.bold(15)
        signOut.layer.cornerRadius = 22
        signOut.addTarget(self, action: #selector(doSignOut), for: .touchUpInside)
        signOut.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(lbl)
        view.addSubview(signOut)
        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lbl.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 40),
            lbl.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            lbl.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            signOut.topAnchor.constraint(equalTo: lbl.bottomAnchor, constant: 32),
            signOut.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            signOut.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            signOut.heightAnchor.constraint(equalToConstant: 46)
        ])
    }

    @objc private func doSignOut() {
        UserDefaultHelper.shared.saveUserProfile(nil)
        navigationController?.popViewController(animated: true)
    }
}

public final class IntroduceAppVC: UIViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: "Migii TOEIC")
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }

        let tv = UITextView()
        tv.isEditable = false
        tv.font = AppFonts.regular(15)
        tv.backgroundColor = ColorHelper.cardBackground
        tv.layer.cornerRadius = 12
        tv.textContainerInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        tv.text = "Migii TOEIC (v1.4.1) helps learners master Listening, Reading, Speaking, and Writing with personalized TOEIC study roadmaps, offline question packs, interactive grammar/vocabulary decks, and realistic ETS mock exams."
        tv.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(nav)
        view.addSubview(tv)
        NSLayoutConstraint.activate([
            nav.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            nav.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            nav.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tv.topAnchor.constraint(equalTo: nav.bottomAnchor, constant: 16),
            tv.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tv.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tv.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
}

public final class FaqVC: UIViewController, UITableViewDataSource {
    private let items: [(String, String)] = (1...8).map { i in
        (tr("FrequentlyQuestion\(i)", "Question \(i)"), tr("FrequentlyQuestion\(i)Answer", ""))
    }
    private let table = UITableView(frame: .zero, style: .plain)

    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = ColorHelper.screenBackground
        let nav = MigiiNavBar(title: "FAQ")
        nav.onBack = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        table.dataSource = self
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

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { items.count }
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = items[indexPath.row].0
        cell.textLabel?.font = AppFonts.bold(15)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.text = items[indexPath.row].1
        cell.detailTextLabel?.font = AppFonts.regular(13)
        cell.detailTextLabel?.numberOfLines = 0
        return cell
    }
}
