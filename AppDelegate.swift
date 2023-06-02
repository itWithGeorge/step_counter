import UIKit
import Flutter
import CoreMotion

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  let pedometer = CMPedometer()
  var stepsResult: FlutterResult?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {

    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
      let stepsChannel = FlutterMethodChannel(name: "com.itwithgeorge/step_counter",
                                                binaryMessenger: controller.binaryMessenger)

      stepsChannel.setMethodCallHandler({
        [weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        guard call.method == "getSteps" else {
          result(FlutterMethodNotImplemented)
          return
        }
        self?.getSteps(result: result)
      })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getSteps(result: @escaping FlutterResult) {
      guard stepsResult == nil else {
        result(FlutterError(code: "ALREADY_PENDING", message: "A step count request is already pending", details: nil))
        return
      }
      
      guard CMPedometer.authorizationStatus() == .authorized else {
          result(FlutterError(code: "ERROR", message: "Required to allow access", details: nil))
          return
      }

      if CMPedometer.isStepCountingAvailable() {
        pedometer.queryPedometerData(from: Date(), to: Date()) { [weak self] (data, error) in
          if let error = error {
            result(FlutterError(code: "ERROR", message: error.localizedDescription, details: nil))
          } else if let data = data {
            result(data.numberOfSteps.intValue)
          }

          self?.stepsResult = nil
        }
        stepsResult = result
      } else {
        result(FlutterError(code: "NOT_AVAILABLE", message: "Step counting is not available on this device", details: nil))
      }
    }
}

