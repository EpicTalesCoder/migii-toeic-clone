import UIKit

// Port of Migii_TOEIC_.ColorHelper (0x1000c7fc0..0x1000c8688) & UIColor(hex:) (0x100211954)
// Evidence: ColorHelper.asm.txt decoded small-string hex slots 0x100baa628..0x100baa6f0

public extension UIColor {
    convenience init(hex: String, alpha: CGFloat = 1.0) {
        var sanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        if sanitized.hasPrefix("#") {
            sanitized.removeFirst()
        }
        var rgbValue: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&rgbValue)
        let r: CGFloat
        let g: CGFloat
        let b: CGFloat
        if sanitized.count == 6 {
            r = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
            g = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
            b = CGFloat(rgbValue & 0x0000FF) / 255.0
        } else {
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b, alpha: alpha)
    }

    var hexString: String {
        var r: CGFloat = 0
        var g: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(round(r * 255)), Int(round(g * 255)), Int(round(b * 255)))
    }
}

public enum ThemeMode: Int {
    case system = 0
    case light = 1
    case dark = 2
}

// Evidence: SwiftTheme.ThemeManager usage across HomeVC (0x10009450c..0x100095600) & SettingsTabView
public final class ThemeManager {
    public static let shared = ThemeManager()
    public static let themeDidChangeNotification = Notification.Name("MigiiThemeDidChangeNotification")

    private let themeKey = "migii_theme_mode_index"

    public var currentThemeIndex: Int {
        get { UserDefaults.standard.integer(forKey: themeKey) }
        set {
            UserDefaults.standard.set(newValue, forKey: themeKey)
            applyToActiveWindows()
            NotificationCenter.default.post(name: Self.themeDidChangeNotification, object: nil)
        }
    }

    public var isDarkMode: Bool {
        if currentThemeIndex == 2 { return true }
        if currentThemeIndex == 1 { return false }
        return UIScreen.main.traitCollection.userInterfaceStyle == .dark
    }

    public func setTheme(index: Int) {
        currentThemeIndex = index
    }

    public func applyToActiveWindows() {
        let style: UIUserInterfaceStyle
        switch ThemeMode(rawValue: currentThemeIndex) ?? .system {
        case .system: style = .unspecified
        case .light: style = .light
        case .dark: style = .dark
        }
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap { $0.windows }
            .forEach { $0.overrideUserInterfaceStyle = style }
    }
}

public enum ColorHelper {
    // Static palette constants from ColorHelper globals (0x100baa628..0x100baa6f0)
    public static let primary = UIColor(hex: "48BCAA")          // 0x100baa628 (#1576)
    public static let orangeAccent = UIColor(hex: "FF8000")     // 0x100baa630 (#1584)
    public static let bgLight = UIColor(hex: "FAFAFA")          // 0x100baa638 (#1592)
    public static let bgDark = UIColor(hex: "212121")           // 0x100baa640 (#1600)
    public static let cardLight = UIColor(hex: "FFFFFF")        // 0x100baa648 (#1608)
    public static let cardDark = UIColor(hex: "333333")         // 0x100baa650 (#1616)
    public static let textLight = UIColor(hex: "212121")        // 0x100baa658 (#1624)
    public static let textDark = UIColor(hex: "FFFFFF")         // 0x100baa660 (#1632)
    public static let subtextLight = UIColor(hex: "616161")     // 0x100baa668 (#1640)
    public static let subtextDark = UIColor(hex: "EEEEEE")      // 0x100baa670 (#1648)
    public static let redLight = UIColor(hex: "EF5350")         // 0x100baa678 (#1656)
    public static let redDark = UIColor(hex: "FF5F55")          // 0x100baa680 (#1664)
    public static let highlightYellow = UIColor(hex: "F8F1AE")  // 0x100baa688 (#1672)
    public static let goldAccent = UIColor(hex: "F9AA33")       // 0x100baa690 (#1680)
    public static let amber = UIColor(hex: "FFC107")            // 0x100baa698 (#1688)
    public static let darkOrange = UIColor(hex: "FF8801")       // 0x100baa6a0 (#1696)
    public static let deepTeal = UIColor(hex: "2E7A71")         // 0x100baa6a8 (#1704)
    public static let emerald = UIColor(hex: "1EA684")          // 0x100baa6b0 (#1712)
    public static let mutedGray = UIColor(hex: "9E9E9E")        // 0x100baa6b8 (#1720)
    public static let lightGrayBorder = UIColor(hex: "BDBDBD")  // 0x100baa6c0 (#1728)
    public static let correctTeal = UIColor(hex: "32BEA6")      // 0x100baa6c8 (#1736)
    public static let masteryGreen = UIColor(hex: "509859")     // 0x100baa6d0 (#1744)
    public static let forestTeal = UIColor(hex: "43887D")       // 0x100baa6d8 (#1752)
    public static let infoBlue = UIColor(hex: "2196F3")         // 0x100baa6e0 (#1760)
    public static let deepCharcoal = UIColor(hex: "121212")     // 0x100baa6e8 (#1768)
    public static let dividerLight = UIColor(hex: "E0E0E0")     // 0x100baa6f0 (#1776)

    // Dynamic Light/Dark semantic pairs replacing ThemeColorPicker
    public static func dynamic(light: UIColor, dark: UIColor) -> UIColor {
        UIColor { trait in
            trait.userInterfaceStyle == .dark ? dark : light
        }
    }

    public static let screenBackground = dynamic(light: bgLight, dark: bgDark)
    public static let cardBackground = dynamic(light: cardLight, dark: cardDark)
    public static let textPrimary = dynamic(light: textLight, dark: textDark)
    public static let textSecondary = dynamic(light: subtextLight, dark: subtextDark)
    public static let textMuted = dynamic(light: mutedGray, dark: lightGrayBorder)
    public static let errorRed = dynamic(light: redLight, dark: redDark)
    public static let tealContrast = dynamic(light: deepTeal, dark: emerald)
    public static let separator = dynamic(light: dividerLight, dark: UIColor(hex: "424242"))
    public static let softTealTint = dynamic(light: UIColor(hex: "E6F6F4"), dark: UIColor(hex: "1E3D38"))
    public static let warmBannerBg = dynamic(light: UIColor(hex: "FFF6E5"), dark: UIColor(hex: "3B2F1B"))

    public static func cssHex(_ color: UIColor, for style: UIUserInterfaceStyle) -> String {
        let resolved = color.resolvedColor(with: UITraitCollection(userInterfaceStyle: style))
        return resolved.hexString
    }
}
