import UIKit

// Evidence: Info.plist UIAppFonts & CoreText TTF name tables (SVN-Avo / SVN-Avobold / SVN-Avoitalic)
// Layout locked to iPhone XS Max (414 x 896 pt @3x, Notch top 44 pt / bottom 34 pt)

public enum AppFonts {
    public static let regularName = "SVN-Avo"
    public static let boldName = "SVN-Avobold"
    public static let italicName = "SVN-Avoitalic"

    public static func regular(_ size: CGFloat) -> UIFont {
        UIFont(name: regularName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }

    public static func bold(_ size: CGFloat) -> UIFont {
        UIFont(name: boldName, size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }

    public static func italic(_ size: CGFloat) -> UIFont {
        UIFont(name: italicName, size: size) ?? UIFont.italicSystemFont(ofSize: size)
    }
}

public extension UIFont {
    static func avoRegular(_ size: CGFloat) -> UIFont { AppFonts.regular(size) }
    static func avoBold(_ size: CGFloat) -> UIFont { AppFonts.bold(size) }
    static func avoItalic(_ size: CGFloat) -> UIFont { AppFonts.italic(size) }
}

public enum LayoutMetrics {
    public static let referenceWidth: CGFloat = 414.0
    public static let referenceHeight: CGFloat = 896.0
    public static let xsMaxTopNotchInset: CGFloat = 44.0
    public static let xsMaxBottomHomeInset: CGFloat = 34.0
    public static let tabBarContentHeight: CGFloat = 56.0
    public static let headerHeight: CGFloat = 52.0
    public static let cardCornerRadius: CGFloat = 12.0
    public static let pillCornerRadius: CGFloat = 22.0
    public static let horizontalPadding: CGFloat = 16.0

    public static var screenWidth: CGFloat { UIScreen.main.bounds.width }
    public static var isCompactWidth: Bool { screenWidth < 390.0 }
}
