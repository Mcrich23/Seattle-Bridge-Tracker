//
//  Seattle_Bridge_TrackerApp.swift
//  Seattle Bridge Tracker
//
//  Created by Morris Richman on 8/16/22.
//

import SwiftUI
import Mcrich23_Toolkit
import GoogleMobileAds
import Firebase
import PortfolioKit

@main
struct Seattle_Bridge_TrackerApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            ViewRouter()
        }
    }
}

struct ViewRouter: View {
    @Environment(\.scenePhase) var scenePhase
    var body: some View {
        ContentView()
            .onChange(of: scenePhase) { newPhase in
                if newPhase == .active {
                    ConsoleManager.printStatement("Active")
                    UNUserNotificationCenter.current().getNotificationSettings { setting in
                        DispatchQueue.main.async {
                            if setting.authorizationStatus == .authorized {
                                NotificationPreferencesModel.shared.notificationsAllowed = true
                            } else {
                                NotificationPreferencesModel.shared.notificationsAllowed = false
                            }
                        }
                    }
                } else if newPhase == .inactive {
                    ConsoleManager.printStatement("Inactive")
                } else if newPhase == .background {
                    ConsoleManager.printStatement("Background")
                }
            }
            .onOpenURL { url in
                let db = Firestore.firestore()
                let components = url.pathComponents.filter({ $0 != "/"})
                if components.first == "notifications" && components.count == 3 {
                    let uid = components[1]
                    let id = components[2]
                    db.collection(uid).document(id).getDocument { doc, error in
                        if let error {
                            ConsoleManager.printStatement(error)
                            return
                        }
                        
                        guard let doc, doc.exists else { return }
                        
                        guard let uuid = UUID(uuidString: id),
                              let title = doc.get("title") as? String,
                              let days = doc.get("days") as? [String],
                              let isAllDay = doc.get("is_all_day") as? Bool,
                              let startTime = doc.get("start_time") as? String,
                              let endTime = doc.get("end_time") as? String,
                              let notificationPriority = doc.get("notification_priority") as? String,
                              let bridgeIds = doc.get("bridge_ids") as? [String],
                              let isActive = doc.get("is_active") as? Bool
                        else {
                            return
                        }
                        
                        let pref = NotificationPreferences(id: uuid, title: title, days: days.map({ Day(rawValue: $0.lowercased()) ?? .monday }), isAllDay: isAllDay, startTime: startTime, endTime: endTime, notificationPriority: NotificationPriority(rawValue: notificationPriority) ?? .normal, bridgeIds: bridgeIds, isActive: isActive)
                        
                        if !NotificationPreferencesModel.shared.preferencesArray.contains(where: { $0.id == uuid }) {
                            NotificationPreferencesModel.shared.preferencesArray.append(pref)
                        } else {
                            if let index = NotificationPreferencesModel.shared.preferencesArray.firstIndex(where: { $0.id == uuid }) {
                                NotificationPreferencesModel.shared.preferencesArray[index] = pref
                            }
                        }
                        
                        ContentViewModel.shared.isShowingNotificationSettings = true
                    }
                }
            }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    let gcmMessageIDKey = "gcm.Message_ID"
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        Utilities.getAppType()
        NetworkMonitor.shared.startMonitoring()
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        FirebaseApp.configure()
        setupFPN(application: application)
        Utilities.fetchRemoteConfig()
        Analytics.setUserProperty(Utilities.appType.rawValue, forName: "application_type")
        Analytics.logEvent("set_application_type", parameters: ["application_type" : Utilities.appType.rawValue])
        if Utilities.isFastlaneRunning {
            AdController.shared.areAdsDisabled = true
        }
        if UserDefaults.standard.string(forKey: "deviceID") == nil {
            let deviceID = UUID()
            UserDefaults.standard.setValue(deviceID.uuidString, forKey: "deviceID")
            Utilities.deviceID = deviceID.uuidString
        }
        if Utilities.appType == .TestFlight || Utilities.appType == .Debug {
            Messaging.messaging().subscribe(toTopic: "test")
        }
        if let url = URL(string: "https://gist.githubusercontent.com/Mcrich23/b55923510068c8672cadc5fac3b07137/raw/PortfolioKit.json") {
            PortfolioKit.shared.config(with: url)
        }
        return true
    }
}
