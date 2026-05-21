import Flutter
import UIKit
import CobrowseIO

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, CobrowseIODelegate {

  var cobrowseChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    CobrowseIO.instance().license = "QKqlFz1wPJX-Vg"
    CobrowseIO.instance().delegate = self
    CobrowseIO.instance().start()

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    cobrowseChannel = FlutterMethodChannel(
      name: "com.yakinim/cobrowse",
      binaryMessenger: engineBridge.pluginRegistry.registrar(forPlugin: "CobrowsePlugin")!.messenger()
    )

    cobrowseChannel?.setMethodCallHandler { call, result in
      switch call.method {
      case "oturumKoduAl":
        CobrowseIO.instance().createSession { error, session in
          if let code = session?.code() {
            result(code)
          } else {
            result(FlutterError(code: "HATA", message: "Oturum oluşturulamadı", details: nil))
          }
        }
      case "oturumaBaglan":
        guard let args = call.arguments as? [String: Any],
              let kod = args["kod"] as? String else {
          result(FlutterError(code: "HATA", message: "Kod eksik", details: nil))
          return
        }
        CobrowseIO.instance().getSession(kod) { error, session in
          if let session = session {
            session.activate(nil)
            result(nil)
          } else {
            result(FlutterError(code: "HATA", message: "Oturum bulunamadı", details: nil))
          }
        }
      case "cobrowseBaslat":
        CobrowseIO.instance().start()
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }

  // Oturum başladığında Flutter'a bildir
  func cobrowseSessionDidUpdate(_ session: CBIOSession) {
    if session.isActive() {
      cobrowseChannel?.invokeMethod("oturumBasladi", arguments: session.code())
    }
  }

  // Oturum bittiğinde Flutter'a bildir
  func cobrowseSessionDidEnd(_ session: CBIOSession) {
    cobrowseChannel?.invokeMethod("oturumBitti", arguments: nil)
  }

  // Akraba bağlanmak istediğinde otomatik onayla
  func cobrowseHandleSessionRequest(_ session: CBIOSession) {
    session.activate(nil)
  }
}
