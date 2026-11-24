import UIKit
import AVFoundation

// Port of Migii_TOEIC_.AppDelegate (0x10023e800..0x100240500)
// Locked target: iPhone XS Max (414 x 896 pt @3x, A12 arm64) running iOS 16.1.1

@main
final class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        _ = UserDefaultHelper.shared
        _ = LanguageManager.shared
        _ = CoreDataManager.shared

        configureAudioSession()
        UINavigationBar.appearance().isHidden = true

        let nav = UINavigationController(rootViewController: SplashVC())
        nav.setNavigationBarHidden(true, animated: false)

        let win = UIWindow(frame: UIScreen.main.bounds)
        win.rootViewController = nav
        win.makeKeyAndVisible()
        self.window = win

        ThemeManager.shared.applyToActiveWindows()
        application.beginReceivingRemoteControlEvents()
        return true
    }

    private func configureAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [])
        try? session.setActive(true)
    }
}
