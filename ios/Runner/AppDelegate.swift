import Flutter
import UIKit
import GoogleMaps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Suprime avisos de constraint do teclado do sistema (TUIKeyboardContentView vs UIKeyboardImpl).
    // Conflito interno do UIKit; não afeta o app.
    UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiableConstraints")
    GMSServices.provideAPIKey("AIzaSyDe-GOjpTTQvjOHu6SyS79dZFInhtQKm6c")
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
