//
//  YVLearningApp.swift
//  YVLearning
//
//  Created by Yash Vyas on 12/02/22.
//

/*
import SwiftUI

@main
struct AppLauncher {
    static func main() throws {
        if NSClassFromString("XCTestCase") == nil {
            YVLearningApp.main()
        } else {
            TestApp.main()
        }
    }
}

struct TestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup { Text("Running Unit Tests") }
    }
}

struct YVLearningApp: App {
    @StateObject private var navView = UINavigationView(rootView: ContentView())
    var body: some Scene {
        WindowGroup {
            RootView()
//            navView
//                .environmentObject(navView)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.message_id"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        debugPrint(deviceToken)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        debugPrint("didFailToRegisterForRemoteNotificationsWithError: \(error)")
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async -> UIBackgroundFetchResult {
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }
        return .newData
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        debugPrint("willPresent: \(notification)")
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }
        debugPrint(userInfo)
        return [.banner, .badge, .sound]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        debugPrint("didReceive: \(response)")
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }
        debugPrint(userInfo)
    }

    /* MessagingDelegate
     func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
     let deviceToken:[String: String] = ["token": fcmToken ?? ""]
     debugPrint("Device token:", deviceToken) // This token can be used for testing notifications on FCM
     }
     */
}
 */
