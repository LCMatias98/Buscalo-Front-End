import Flutter
import UIKit
import GoogleMaps // Importa Google Maps

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Proporciona la API Key de Google Maps
    GMSServices.provideAPIKey("AIzaSyBoTi3-nwFqti4k9t6jtBzgZwuh5ULZL98")
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
