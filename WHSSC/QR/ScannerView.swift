//
//  ScannerView.swift
//  STREAM APP
//
//  Created by Danxd on 7/22/26.
//

import SwiftUI

struct QRScannerView: UIViewControllerRepresentable {

    var completion: (String) -> Void

    func makeUIViewController(context: Context) -> ScannerViewController {
        let controller = ScannerViewController()
        controller.completion = completion
        return controller
    }

    func updateUIViewController(_ uiViewController: ScannerViewController, context: Context) { }
}
