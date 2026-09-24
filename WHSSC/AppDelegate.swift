//
//  AppDelegate.swift
//  WHSSC
//
//  Created by Dan on 9/24/26.
//

import Foundation
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    static var orientationLock: UIInterfaceOrientationMask = .all

    func application(
        _ application: UIApplication,
        supportedInterfaceOrientationsFor window: UIWindow?
    ) -> UIInterfaceOrientationMask {
        return Self.orientationLock
    }
}
