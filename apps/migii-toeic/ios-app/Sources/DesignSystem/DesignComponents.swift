import UIKit
import WebKit

// Evidence: Migii_TOEIC_ DesignSystem classes from __swift5_fieldmd & BaseView/MyWebView (0x10061a16c..0x10061b808)

public extension UIView {
    func pinEdges(to superview: UIView, insets: UIEdgeInsets = .zero, useSafeArea: Bool = false) {
        translatesAutoresizingMaskIntoConstraints = false
        let topAnchorTarget = useSafeArea ? superview.safeAreaLayoutGuide.topAnchor : superview.topAnchor
        let bottomAnchorTarget = useSafeArea ? superview.safeAreaLayoutGuide.bottomAnchor : superview.bottomAnchor
        let leadingAnchorTarget = useSafeArea ? superview.safeAreaLayoutGuide.leadingAnchor : superview.leadingAnchor
        let trailingAnchorTarget = useSafeArea ? superview.safeAreaLayoutGuide.trailingAnchor : superview.trailingAnchor
        NSLayoutConstraint.activate([
            topAnchor.constraint(equalTo: topAnchorTarget, constant: insets.top),
            leadingAnchor.constraint(equalTo: leadingAnchorTarget, constant: insets.left),
            trailingAnchor.constraint(equalTo: trailingAnchorTarget, constant: -insets.right),
            bottomAnchor.constraint(equalTo: bottomAnchorTarget, constant: -insets.bottom)
        ])
    }

    func applyCardShadow(cornerRadius: CGFloat = 12, opacity: Float = 0.08, radius: CGFloat = 6, offset: CGSize = CGSize(width: 0, height: 2)) {
        layer.cornerRadius = cornerRadius
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = opacity
        layer.shadowRadius = radius
        layer.shadowOffset = offset
        layer.masksToBounds = false
    }
}

// MARK: - CardView / CornerView / PaddingLabel

public class CardView: UIView {
    public var cornerRadius: CGFloat = 12 {
        didSet { layer.cornerRadius = cornerRadius }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = ColorHelper.cardBackground
        applyCardShadow(cornerRadius: cornerRadius)
    }

    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        layer.shadowOpacity = traitCollection.userInterfaceStyle == .dark ? 0.25 : 0.08
    }
}

public class CornerView: UIView {
    public var corners: UIRectCorner = [.topLeft, .topRight]
    public var radius: CGFloat = 16

    public override func layoutSubviews() {
        super.layoutSubviews()
        let path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

// Port of Migii_TOEIC_.PaddingLabel (fields: topInset, bottomInset, leftInset, rightInset)
public class PaddingLabel: UILabel {
    public var topInset: CGFloat = 4
    public var bottomInset: CGFloat = 4
    public var leftInset: CGFloat = 8
    public var rightInset: CGFloat = 8

    public override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
    }

    public override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(width: size.width + leftInset + rightInset, height: size.height + topInset + bottomInset)
    }
}

// MARK: - Progress Bars (LinearProgressBar / CircularProgressBar / Circular2ProgressBar)

public class LinearProgressBar: UIView {
    private let trackView = UIView()
    private let fillView = UIView()
    private var fillWidthConstraint: NSLayoutConstraint?

    public var progress: CGFloat = 0 {
        didSet { updateFill(animated: true) }
    }

    public var trackColor: UIColor = ColorHelper.separator {
        didSet { trackView.backgroundColor = trackColor }
    }

    public var progressColor: UIColor = ColorHelper.primary {
        didSet { fillView.backgroundColor = progressColor }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        addSubview(trackView)
        trackView.addSubview(fillView)
        trackView.backgroundColor = trackColor
        fillView.backgroundColor = progressColor
        trackView.clipsToBounds = true
        trackView.translatesAutoresizingMaskIntoConstraints = false
        fillView.translatesAutoresizingMaskIntoConstraints = false

        let widthC = fillView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: 0.001)
        fillWidthConstraint = widthC
        NSLayoutConstraint.activate([
            trackView.topAnchor.constraint(equalTo: topAnchor),
            trackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            trackView.bottomAnchor.constraint(equalTo: bottomAnchor),
            fillView.topAnchor.constraint(equalTo: trackView.topAnchor),
            fillView.leadingAnchor.constraint(equalTo: trackView.leadingAnchor),
            fillView.bottomAnchor.constraint(equalTo: trackView.bottomAnchor),
            widthC
        ])
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        trackView.layer.cornerRadius = bounds.height / 2
        fillView.layer.cornerRadius = bounds.height / 2
    }

    private func updateFill(animated: Bool) {
        let clamped = max(0.001, min(1.0, progress))
        fillWidthConstraint?.isActive = false
        let next = fillView.widthAnchor.constraint(equalTo: trackView.widthAnchor, multiplier: clamped)
        next.isActive = true
        fillWidthConstraint = next
        if animated {
            UIView.animate(withDuration: 0.25) { self.layoutIfNeeded() }
        } else {
            layoutIfNeeded()
        }
    }
}

public class CircularProgressBar: UIView {
    private let backgroundLayer = CAShapeLayer()
    private let foregroundLayer = CAShapeLayer()
    public var lineWidth: CGFloat = 6 {
        didSet {
            backgroundLayer.lineWidth = lineWidth
            foregroundLayer.lineWidth = lineWidth
        }
    }
    public var progress: CGFloat = 0 {
        didSet { foregroundLayer.strokeEnd = max(0, min(1, progress)) }
    }
    public var strokeColor: UIColor = ColorHelper.primary {
        didSet { foregroundLayer.strokeColor = strokeColor.cgColor }
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundLayer.fillColor = UIColor.clear.cgColor
        backgroundLayer.strokeColor = ColorHelper.separator.cgColor
        backgroundLayer.lineCap = .round
        backgroundLayer.lineWidth = lineWidth
        layer.addSublayer(backgroundLayer)

        foregroundLayer.fillColor = UIColor.clear.cgColor
        foregroundLayer.strokeColor = strokeColor.cgColor
        foregroundLayer.lineCap = .round
        foregroundLayer.lineWidth = lineWidth
        foregroundLayer.strokeEnd = 0
        layer.addSublayer(foregroundLayer)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        let center = CGPoint(x: bounds.midX, y: bounds.midY)
        let radius = max(1, (min(bounds.width, bounds.height) - lineWidth) / 2)
        let path = UIBezierPath(arcCenter: center, radius: radius, startAngle: -.pi / 2, endAngle: 1.5 * .pi, clockwise: true)
        backgroundLayer.path = path.cgPath
        foregroundLayer.path = path.cgPath
    }
}

// Port of Migii_TOEIC_.Circular2ProgressBar (colorRed, colorYellow, colorGreen, progress)
public final class Circular2ProgressBar: CircularProgressBar {
    public let colorRed = ColorHelper.errorRed
    public let colorYellow = ColorHelper.amber
    public let colorGreen = ColorHelper.correctTeal

    public override var progress: CGFloat {
        didSet {
            if progress < 0.4 {
                strokeColor = colorRed
            } else if progress < 0.7 {
                strokeColor = colorYellow
            } else {
                strokeColor = colorGreen
            }
        }
    }
}

// MARK: - ToastView (TTGSnackbar replacement, Port of ToastGravity top/center/bottom)

public enum ToastGravity {
    case top
    case center
    case bottom
}

public enum ToastView {
    public static func show(_ message: String, in view: UIView? = nil, gravity: ToastGravity = .bottom, isError: Bool = false) {
        DispatchQueue.main.async {
            let host: UIView?
            if let v = view {
                host = v
            } else {
                host = UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first { $0.isKeyWindow }
            }
            guard let targetView = host else { return }

            let banner = UIView()
            banner.backgroundColor = isError ? ColorHelper.errorRed : ColorHelper.deepCharcoal.withAlphaComponent(0.92)
            banner.layer.cornerRadius = 10
            banner.alpha = 0
            banner.translatesAutoresizingMaskIntoConstraints = false

            let label = UILabel()
            label.text = message
            label.textColor = .white
            label.font = AppFonts.regular(14)
            label.numberOfLines = 0
            label.textAlignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false

            banner.addSubview(label)
            targetView.addSubview(banner)

            let anchorConstraint: NSLayoutConstraint
            switch gravity {
            case .top:
                anchorConstraint = banner.topAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.topAnchor, constant: 16)
            case .center:
                anchorConstraint = banner.centerYAnchor.constraint(equalTo: targetView.centerYAnchor)
            case .bottom:
                anchorConstraint = banner.bottomAnchor.constraint(equalTo: targetView.safeAreaLayoutGuide.bottomAnchor, constant: -72)
            }

            NSLayoutConstraint.activate([
                anchorConstraint,
                banner.centerXAnchor.constraint(equalTo: targetView.centerXAnchor),
                banner.leadingAnchor.constraint(greaterThanOrEqualTo: targetView.leadingAnchor, constant: 24),
                banner.trailingAnchor.constraint(lessThanOrEqualTo: targetView.trailingAnchor, constant: -24),
                label.topAnchor.constraint(equalTo: banner.topAnchor, constant: 10),
                label.bottomAnchor.constraint(equalTo: banner.bottomAnchor, constant: -10),
                label.leadingAnchor.constraint(equalTo: banner.leadingAnchor, constant: 16),
                label.trailingAnchor.constraint(equalTo: banner.trailingAnchor, constant: -16)
            ])

            UIView.animate(withDuration: 0.2, animations: { banner.alpha = 1 }) { _ in
                UIView.animate(withDuration: 0.25, delay: 2.0, options: [], animations: { banner.alpha = 0 }) { _ in
                    banner.removeFromSuperview()
                }
            }
        }
    }
}

// MARK: - MLLineChart (Port of Migii_TOEIC_.MLLineChart / MLPointEntry)

public struct MLPointEntry {
    public let value: CGFloat
    public let label: String
    public let color: UIColor

    public init(value: CGFloat, label: String = "", color: UIColor = ColorHelper.primary) {
        self.value = value
        self.label = label
        self.color = color
    }
}

public final class MLLineChart: UIView {
    public var dataEntries: [MLPointEntry] = [] {
        didSet { setNeedsLayout() }
    }
    public var lineColor: UIColor = ColorHelper.primary
    public var lineWidth: CGFloat = 2.5

    private let lineLayer = CAShapeLayer()
    private let areaLayer = CAShapeLayer()
    private var dotLayers: [CALayer] = []

    public override init(frame: CGRect) {
        super.init(frame: frame)
        areaLayer.fillColor = ColorHelper.primary.withAlphaComponent(0.14).cgColor
        lineLayer.fillColor = UIColor.clear.cgColor
        lineLayer.lineCap = .round
        lineLayer.lineJoin = .round
        layer.addSublayer(areaLayer)
        layer.addSublayer(lineLayer)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public override func layoutSubviews() {
        super.layoutSubviews()
        dotLayers.forEach { $0.removeFromSuperlayer() }
        dotLayers.removeAll()
        guard dataEntries.count >= 1, bounds.width > 16, bounds.height > 16 else {
            lineLayer.path = nil
            areaLayer.path = nil
            return
        }

        let insetX: CGFloat = 14
        let insetY: CGFloat = 14
        let usableW = bounds.width - insetX * 2
        let usableH = bounds.height - insetY * 2
        let maxVal = max(1, (dataEntries.map { $0.value }.max() ?? 100))
        let minVal = min(0, (dataEntries.map { $0.value }.min() ?? 0))
        let span = max(1, maxVal - minVal)

        var points: [CGPoint] = []
        for (idx, entry) in dataEntries.enumerated() {
            let xRatio = dataEntries.count > 1 ? CGFloat(idx) / CGFloat(dataEntries.count - 1) : 0.5
            let yRatio = (entry.value - minVal) / span
            points.append(CGPoint(x: insetX + xRatio * usableW, y: insetY + (1 - yRatio) * usableH))
        }

        let path = UIBezierPath()
        path.move(to: points[0])
        for i in 1..<points.count {
            let prev = points[i - 1]
            let curr = points[i]
            let midX = (prev.x + curr.x) / 2
            path.addCurve(to: curr, controlPoint1: CGPoint(x: midX, y: prev.y), controlPoint2: CGPoint(x: midX, y: curr.y))
        }
        lineLayer.path = path.cgPath
        lineLayer.strokeColor = lineColor.cgColor
        lineLayer.lineWidth = lineWidth

        if let area = path.copy() as? UIBezierPath, let first = points.first, let last = points.last {
            area.addLine(to: CGPoint(x: last.x, y: bounds.height - insetY))
            area.addLine(to: CGPoint(x: first.x, y: bounds.height - insetY))
            area.close()
            areaLayer.path = area.cgPath
        }

        for (pt, entry) in zip(points, dataEntries) {
            let dot = CAShapeLayer()
            dot.path = UIBezierPath(ovalIn: CGRect(x: pt.x - 4, y: pt.y - 4, width: 8, height: 8)).cgPath
            dot.fillColor = entry.color.cgColor
            dot.strokeColor = ColorHelper.cardBackground.cgColor
            dot.lineWidth = 2
            layer.addSublayer(dot)
            dotLayers.append(dot)
        }
    }
}

// MARK: - CustomTextField (Port of Migii_TOEIC_.CustomTextField / OnboardLoginTextField)

public final class CustomTextField: UIView {
    public let containerView = UIView()
    public let iconImageView = UIImageView()
    public let textField = UITextField()
    public let warningLabel = UILabel()
    private let toggleSecureButton = UIButton(type: .system)

    public var isShowWarning: Bool = false {
        didSet {
            warningLabel.isHidden = !isShowWarning
            containerView.layer.borderColor = (isShowWarning ? ColorHelper.errorRed : ColorHelper.separator).cgColor
        }
    }

    public init(placeholder: String, iconName: String? = nil, isSecure: Bool = false) {
        super.init(frame: .zero)
        setup(placeholder: placeholder, iconName: iconName, isSecure: isSecure)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    private func setup(placeholder: String, iconName: String?, isSecure: Bool) {
        containerView.backgroundColor = ColorHelper.cardBackground
        containerView.layer.cornerRadius = 10
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = ColorHelper.separator.cgColor
        containerView.translatesAutoresizingMaskIntoConstraints = false

        iconImageView.contentMode = .scaleAspectFit
        iconImageView.tintColor = ColorHelper.textSecondary
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        if let iconName = iconName {
            iconImageView.image = UIImage(named: iconName)
        } else {
            iconImageView.isHidden = true
        }

        textField.placeholder = placeholder
        textField.font = AppFonts.regular(15)
        textField.textColor = ColorHelper.textPrimary
        textField.isSecureTextEntry = isSecure
        textField.autocorrectionType = .no
        textField.translatesAutoresizingMaskIntoConstraints = false

        toggleSecureButton.setTitle(isSecure ? "Show" : "", for: .normal)
        toggleSecureButton.titleLabel?.font = AppFonts.regular(12)
        toggleSecureButton.tintColor = ColorHelper.primary
        toggleSecureButton.isHidden = !isSecure
        toggleSecureButton.addTarget(self, action: #selector(toggleSecure), for: .touchUpInside)
        toggleSecureButton.translatesAutoresizingMaskIntoConstraints = false

        warningLabel.font = AppFonts.regular(12)
        warningLabel.textColor = ColorHelper.errorRed
        warningLabel.numberOfLines = 0
        warningLabel.isHidden = true
        warningLabel.translatesAutoresizingMaskIntoConstraints = false

        addSubview(containerView)
        addSubview(warningLabel)
        containerView.addSubview(iconImageView)
        containerView.addSubview(textField)
        containerView.addSubview(toggleSecureButton)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: topAnchor),
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            containerView.heightAnchor.constraint(equalToConstant: 48),

            iconImageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            iconImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            iconImageView.widthAnchor.constraint(equalToConstant: iconName == nil ? 0 : 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            textField.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: iconName == nil ? 0 : 10),
            textField.trailingAnchor.constraint(equalTo: toggleSecureButton.leadingAnchor, constant: -8),
            textField.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 4),
            textField.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -4),

            toggleSecureButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            toggleSecureButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            toggleSecureButton.widthAnchor.constraint(equalToConstant: isSecure ? 44 : 0),

            warningLabel.topAnchor.constraint(equalTo: containerView.bottomAnchor, constant: 4),
            warningLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 4),
            warningLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -4),
            warningLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    @objc private func toggleSecure() {
        textField.isSecureTextEntry.toggle()
        toggleSecureButton.setTitle(textField.isSecureTextEntry ? "Show" : "Hide", for: .normal)
    }

    public func showError(_ msg: String) {
        warningLabel.text = msg
        isShowWarning = true
    }

    public func clearError() {
        warningLabel.text = nil
        isShowWarning = false
    }
}

// MARK: - SegmentTabView & TopNavigationBar

public final class SegmentTabView: UIView {
    public var onSelectIndex: ((Int) -> Void)?
    private let stack = UIStackView()
    private let indicator = UIView()
    private var buttons: [UIButton] = []
    private var indicatorLeading: NSLayoutConstraint?
    private var indicatorWidth: NSLayoutConstraint?
    public private(set) var selectedIndex: Int = 0

    public init(titles: [String]) {
        super.init(frame: .zero)
        setup(titles: titles)
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    private func setup(titles: [String]) {
        backgroundColor = ColorHelper.cardBackground
        stack.axis = .horizontal
        stack.distribution = .fillEqually
        stack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stack)

        indicator.backgroundColor = ColorHelper.primary
        indicator.layer.cornerRadius = 1.5
        indicator.translatesAutoresizingMaskIntoConstraints = false
        addSubview(indicator)

        let sep = UIView()
        sep.backgroundColor = ColorHelper.separator
        sep.translatesAutoresizingMaskIntoConstraints = false
        addSubview(sep)

        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2),
            sep.heightAnchor.constraint(equalToConstant: 1),
            sep.leadingAnchor.constraint(equalTo: leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: trailingAnchor),
            sep.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])

        for (i, t) in titles.enumerated() {
            let btn = UIButton(type: .system)
            btn.tag = i
            btn.setTitle(t, for: .normal)
            btn.titleLabel?.font = AppFonts.bold(14)
            btn.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            stack.addArrangedSubview(btn)
            buttons.append(btn)
        }

        if let first = buttons.first {
            let l = indicator.leadingAnchor.constraint(equalTo: first.leadingAnchor)
            let w = indicator.widthAnchor.constraint(equalTo: first.widthAnchor)
            indicatorLeading = l
            indicatorWidth = w
            NSLayoutConstraint.activate([
                indicator.bottomAnchor.constraint(equalTo: bottomAnchor),
                indicator.heightAnchor.constraint(equalToConstant: 3),
                l, w
            ])
        }
        setSelected(0, notify: false)
    }

    @objc private func tapped(_ sender: UIButton) {
        setSelected(sender.tag, notify: true)
    }

    public func setSelected(_ index: Int, notify: Bool) {
        guard index >= 0, index < buttons.count else { return }
        selectedIndex = index
        for (i, b) in buttons.enumerated() {
            b.setTitleColor(i == index ? ColorHelper.primary : ColorHelper.textSecondary, for: .normal)
            b.titleLabel?.font = i == index ? AppFonts.bold(14) : AppFonts.regular(14)
        }
        indicatorLeading?.isActive = false
        indicatorWidth?.isActive = false
        let target = buttons[index]
        indicatorLeading = indicator.leadingAnchor.constraint(equalTo: target.leadingAnchor)
        indicatorWidth = indicator.widthAnchor.constraint(equalTo: target.widthAnchor)
        indicatorLeading?.isActive = true
        indicatorWidth?.isActive = true
        UIView.animate(withDuration: 0.2) { self.layoutIfNeeded() }
        if notify { onSelectIndex?(index) }
    }
}

public final class MigiiNavBar: UIView {
    public let backButton = UIButton(type: .system)
    public let titleLabel = UILabel()
    public let rightButton = UIButton(type: .system)
    public var onBack: (() -> Void)?

    public init(title: String, rightIconName: String? = nil) {
        super.init(frame: .zero)
        backgroundColor = ColorHelper.cardBackground
        translatesAutoresizingMaskIntoConstraints = false

        backButton.setImage(UIImage(named: "ic_back")?.withRenderingMode(.alwaysTemplate) ?? UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = ColorHelper.textPrimary
        backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        backButton.translatesAutoresizingMaskIntoConstraints = false

        titleLabel.text = title
        titleLabel.font = AppFonts.bold(17)
        titleLabel.textColor = ColorHelper.textPrimary
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        rightButton.tintColor = ColorHelper.primary
        rightButton.translatesAutoresizingMaskIntoConstraints = false
        if let rightIconName = rightIconName {
            rightButton.setImage(UIImage(named: rightIconName)?.withRenderingMode(.alwaysTemplate), for: .normal)
        } else {
            rightButton.isHidden = true
        }

        let sep = UIView()
        sep.backgroundColor = ColorHelper.separator
        sep.translatesAutoresizingMaskIntoConstraints = false

        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(rightButton)
        addSubview(sep)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: LayoutMetrics.headerHeight),
            backButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            backButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            backButton.widthAnchor.constraint(equalToConstant: 40),
            backButton.heightAnchor.constraint(equalToConstant: 40),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 4),
            titleLabel.trailingAnchor.constraint(equalTo: rightButton.leadingAnchor, constant: -4),
            titleLabel.centerYAnchor.constraint(equalTo: centerYAnchor),

            rightButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -10),
            rightButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            rightButton.widthAnchor.constraint(equalToConstant: 40),
            rightButton.heightAnchor.constraint(equalToConstant: 40),

            sep.leadingAnchor.constraint(equalTo: leadingAnchor),
            sep.trailingAnchor.constraint(equalTo: trailingAnchor),
            sep.bottomAnchor.constraint(equalTo: bottomAnchor),
            sep.heightAnchor.constraint(equalToConstant: 0.7)
        ])
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    @objc private func handleBack() {
        onBack?()
    }
}

// MARK: - MyWebView (Evidence: question.html, explain.html, WKWebViewJavascriptBridge handlers)

public final class MyWebView: WKWebView, WKScriptMessageHandler {
    public var onHighlightClicked: ((String) -> Void)?
    public var onAnswerChoose: ((String) -> Void)?
    public var onSelectionChange: ((String) -> Void)?
    public var onImageClick: ((String) -> Void)?

    public init() {
        let contentController = WKUserContentController()
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        super.init(frame: .zero, configuration: config)
        isOpaque = false
        backgroundColor = .clear
        scrollView.backgroundColor = .clear

        for handler in ["onHighlightClicked", "onAnswerChoose", "onSelectionChange", "onImageClick"] {
            contentController.add(self, name: handler)
        }
        // Bridge shim matching WKWebViewJavascriptBridge.callHandler(...) in original question.html / explain.html
        let bridgeJS = """
        window.WKWebViewJavascriptBridge = {
            callHandler: function(name, data, cb) {
                var payload = (typeof data === "string") ? data : JSON.stringify(data || {});
                if (window.webkit && window.webkit.messageHandlers && window.webkit.messageHandlers[name]) {
                    window.webkit.messageHandlers[name].postMessage(payload);
                }
                if (cb) { cb(null); }
            },
            registerHandler: function(name, fn) {}
        };
        window.WebViewJavascriptBridge = window.WKWebViewJavascriptBridge;
        function setupWKWebViewJavascriptBridge(cb) { if (cb) { cb(window.WKWebViewJavascriptBridge); } }
        document.addEventListener('WebViewJavascriptBridgeReady', function(){}, false);
        """
        contentController.addUserScript(WKUserScript(source: bridgeJS, injectionTime: .atDocumentStart, forMainFrameOnly: false))
    }

    public required init?(coder: NSCoder) { fatalError("init(coder:) not supported") }

    public func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let payload = String(describing: message.body)
        switch message.name {
        case "onHighlightClicked": onHighlightClicked?(payload)
        case "onAnswerChoose": onAnswerChoose?(payload)
        case "onSelectionChange": onSelectionChange?(payload)
        case "onImageClick": onImageClick?(payload)
        default: break
        }
    }

    // Evidence: question.html / explain.html CSS placeholder substitution (<news_body>, <font_size>, etc.)
    public static func renderTemplate(
        fileName: String,
        bodyHTML: String,
        fontSizePt: Int = 16,
        style: UIUserInterfaceStyle = .light
    ) -> String {
        let baseHTML: String
        if let url = Bundle.main.url(forResource: fileName.replacingOccurrences(of: ".html", with: ""), withExtension: "html"),
           let raw = try? String(contentsOf: url, encoding: .utf8) {
            baseHTML = raw
        } else {
            baseHTML = "<html><body style='font-family:SVN-Avo,sans-serif;font-size:<font_size>;color:<bodyColor>;background:<backgroundColor>;'><news_body></body></html>"
        }

        let bodyColor = ColorHelper.cssHex(ColorHelper.textPrimary, for: style)
        let bgColor = ColorHelper.cssHex(ColorHelper.cardBackground, for: style)
        let boxColor = ColorHelper.cssHex(ColorHelper.screenBackground, for: style)
        let borderColor = ColorHelper.cssHex(ColorHelper.separator, for: style)
        let titleBg = ColorHelper.cssHex(ColorHelper.softTealTint, for: style)
        let hlColor = ColorHelper.highlightYellow.hexString

        return baseHTML
            .replacingOccurrences(of: "<font_size>", with: "\(fontSizePt)px")
            .replacingOccurrences(of: "<question_answer_size>", with: "\(max(14, fontSizePt))px")
            .replacingOccurrences(of: "<question_number_size>", with: "\(max(14, fontSizePt + 1))px")
            .replacingOccurrences(of: "<font_normal>", with: AppFonts.regularName)
            .replacingOccurrences(of: "<bodyColor>", with: bodyColor)
            .replacingOccurrences(of: "<backgroundColor>", with: bgColor)
            .replacingOccurrences(of: "<boxColor>", with: boxColor)
            .replacingOccurrences(of: "<borderColor>", with: borderColor)
            .replacingOccurrences(of: "<backgroundTitleColor>", with: titleBg)
            .replacingOccurrences(of: "<hightLightColor>", with: hlColor)
            .replacingOccurrences(of: "<decoration_thickness>", with: "1.5px")
            .replacingOccurrences(of: "<news_body>", with: bodyHTML)
    }

    public func loadTemplated(fileName: String, bodyHTML: String, fontSize: Int) {
        let html = Self.renderTemplate(fileName: fileName, bodyHTML: bodyHTML, fontSizePt: fontSize, style: traitCollection.userInterfaceStyle)
        loadHTMLString(html, baseURL: Bundle.main.bundleURL)
    }
}
