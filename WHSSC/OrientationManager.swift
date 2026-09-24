//
//  OrientationManager.swift
//  WHSSC
//
//  Created by Dan on 9/24/26.
//

import SwiftUI
import UIKit

struct OrientationManager {
    static func lock(_ orientation: UIInterfaceOrientationMask) {
        AppDelegate.orientationLock = orientation

        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if #available(iOS 16.0, *) {
                scene.requestGeometryUpdate(.iOS(interfaceOrientations: orientation))
            } else {
                UIDevice.current.setValue(
                    orientation == .landscape ? UIInterfaceOrientation.landscapeRight.rawValue :
                    orientation == .portrait ? UIInterfaceOrientation.portrait.rawValue :
                    UIInterfaceOrientation.unknown.rawValue,
                    forKey: "orientation"
                )
            }
        }
    }
}
