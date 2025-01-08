//
// Copyright © 2022 by Hilti Corporation – all rights reserved
//

// import os.log
import UIKit

//@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.

        /*
        if #available(iOS 14.0, *) {
            Logger.appCycle.debug("didFinishLaunchingWithOptions")
            Logger.appCycle.info("By \("Yash", privacy: .private)")
            Logger.appCycle.log("By \("Yash", privacy: .public)")
            Logger.appCycle.info("With float \(2910.1992, format: .fixed(precision: 2), align: .left(columns: .max),
                                 privacy: .private)")
        } else {
            os_log("didFinishLaunchingWithOptions by %{public}@", log: OSLog.appCycle, type: .debug, "Yash")
            os_log("didFinishLaunchingWithOptions by %{private}@", log: OSLog.appCycle, type: .info, "Yash")
            os_log(.info, "didFinishLaunchingWithOptions")
        }
         */

        /*
        UNUserNotificationCenter.current().delegate = self
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: {_, _ in })
        application.registerForRemoteNotifications()
         */

        // debugPrint("My name is: \("name".localized())")

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        /*
        let configuration = UISceneConfiguration(name: nil, sessionRole: connectingSceneSession.role)
        if connectingSceneSession.role == .windowApplication {
            configuration.delegateClass = SceneDelegate.self
        }
        return configuration
         */
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running,
        // this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

/*
extension AppDelegate: UNUserNotificationCenterDelegate {
    private var gcmMessageIDKey: String { "gcm.message_id" }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        debugPrint("willPresent: \(notification)")
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }
        debugPrint(userInfo)
        return [.alert, .badge, .sound]
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        debugPrint("didReceive: \(response)")
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            debugPrint("Message ID: \(messageID)")
        }
        debugPrint(userInfo)
    }
    
    /*
    // MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let deviceToken:[String: String] = ["token": fcmToken ?? ""]
        debugPrint("Device token:", deviceToken) // This token can be used for testing notifications on FCM
    }
     */
}
*/
