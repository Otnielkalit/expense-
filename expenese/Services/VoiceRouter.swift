//
//  VoiceRouter.swift
//  expenese
//
//  Created by otnielkalit on 03/09/26.
//

import Foundation
import UIKit

final class AppDelegate: NSObject, UIApplicationDelegate {
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
