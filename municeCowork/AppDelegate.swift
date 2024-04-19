//
//  AppDelegate.swift
//  municeCowork
//
//  Created by yongnamJeon on 4/18/24.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

  func application(
    _ application: UIApplication, 
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    requestNotificationAuthorization()
    return true
  }

  // MARK: UISceneSession Lifecycle

  func application(
    _ application: UIApplication,
    configurationForConnecting connectingSceneSession: UISceneSession,
    options: UIScene.ConnectionOptions
  ) -> UISceneConfiguration {
    return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
  }

  func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
}

// MARK: - Private Methods

private extension AppDelegate {
  func requestNotificationAuthorization() {
    let notificationCenter = UNUserNotificationCenter.current()
    
    notificationCenter.delegate = self
    
    let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
    notificationCenter.requestAuthorization(options: authOptions) { (granted, error) in
      if granted {
        Logg.i("Notification permission granted.")
      } else {
        Logg.e("Notification permission denied.")
        if let error = error {
          Logg.e("Notification permission error: \(error.localizedDescription)")
        }
      }
    }
  }
}

// MARK: - UNUserNotificationCenterDelegate

extension AppDelegate: UNUserNotificationCenterDelegate {
  // 포어그라운드 수신
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([.list, .banner, .badge, .sound])
  }
  
  // 백그라운드 수신 && 사용자가 푸시를 탭했을 때
  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    completionHandler()
  }
}
