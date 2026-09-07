//
//  VoiceRouter.swift
//  expenese
//
//  Created by otnielkalit on 03/09/26.
//

import Foundation
import UIKit

/// Pusat routing URL dari Siri/URL scheme ke seluruh app.
/// Menggunakan AppDelegate + NotificationCenter supaya paling andal,
/// tidak bergantung pada timing `onOpenURL` SwiftUI.
final class AppDelegate: NSObject, UIApplicationDelegate {
    /// Post setiap kali ada URL masuk, subscript meneruskan ke ContentView.
    func application(
        _ app: UIApplication,
        open url: URL,
        options: [UIApplication.OpenURLOptionsKey: Any] = [:]
    ) -> Bool {
        let name = Notification.Name("ExpeneseDidOpenURL")
        NotificationCenter.default.post(
            name: name,
            object: nil,
            userInfo: ["url": url]
        )
        return true
    }
}
