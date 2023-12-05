//
//  AppDelegate.swift
//  GogoPoke
//
//  Created by Connie Chang on 2023/12/2.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static let instance = AppDelegate()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        TypeManager.fetchTypeList()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    let keyWindow: UIWindow? = {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.connectedScenes.filter { $0.activationState == .foregroundActive }.compactMap { $0 as? UIWindowScene }.first?.windows.filter { $0.isKeyWindow }.first
        }
        else {
            return UIApplication.shared.keyWindow
        }
    }()

}

