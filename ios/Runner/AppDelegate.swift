import Flutter
import UIKit
import workmanager_apple

@main
@objc class AppDelegate: FlutterAppDelegate {
  private let restrictionLifecycleBackgroundTaskIdentifier = "com.menace.pauza.restriction_lifecycle_daily_sync"

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    WorkmanagerPlugin.registerPeriodicTask(
      withIdentifier: restrictionLifecycleBackgroundTaskIdentifier,
      frequency: NSNumber(value: 24 * 60 * 60)
    )
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
