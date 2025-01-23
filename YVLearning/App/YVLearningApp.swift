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
        if #available(iOS 14.0, *) {
            if NSClassFromString("XCTestCase") == nil {
                YVLearningApp.main()
            } else {
                TestApp.main()
            }
        } else {
            UIApplicationMain(
                CommandLine.argc,
                CommandLine.unsafeArgv,
                nil,
                NSStringFromClass(AppDelegate.self))
        }
    }
}

@available(iOS 14.0, *)
struct TestApp: App {
    var body: some Scene {
        WindowGroup { Text("Running Unit Tests") }
    }
}

@available(iOS 14.0, *)
struct YVLearningApp: App {
    // @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    // @StateObject private var navView = UINavigationView(rootView: ContentView())

    var body: some Scene {
        WindowGroup {
            let _ = sleep(5)
            RootView()
            /*
             navView
             .environmentObject(navView)
             */
        }
    }
}
 */

/*
import SwiftData

@main
@available(iOS 17, *)
struct YVLearningApp: App {
    let schema: Schema = .init(versionedSchema: YV_VersionedSchema_02_00_00.self)
    let modelContainer: ModelContainer

    init() {
        do {
            /*
             let storeURL = URL.documentsDirectory.appending(path: "yv_db.sqlite")
             let modelConfiguration: ModelConfiguration = .init(
             url: storeURL,
             allowsSave: false,
             cloudKitDatabase: .private("yv_db")
             )
             */
            modelContainer = try .init(
                for: schema,
                migrationPlan: YV_ShemaMigrationPlan_02_00_00.self,
                configurations: [.init(isStoredInMemoryOnly: true)]
            )
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    var body: some Scene {
        WindowGroup {
            SwiftDataView()
            // .modelContainer(for: [User.self], inMemory: true, isAutosaveEnabled: false, isUndoEnabled: true)
                .modelContainer(modelContainer)
        }
    }
}
 */
