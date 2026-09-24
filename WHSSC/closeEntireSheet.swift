//
//  closeEntireSheet.swift
//  WHSSC
//
//  Created by Dan on 9/23/26.
//

import Foundation
import SwiftUI

func closeEntireSheet() {
    NotificationCenter.default.post(
        name: Notification.Name("CloseEntireSheet"),
        object: nil
    )
}
