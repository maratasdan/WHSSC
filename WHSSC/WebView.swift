//
//  WebView.swift
//  WHSSC
//
//  Created by Dan on 9/24/26.
//

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: String

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.load(URLRequest(url: URL(string: url)!))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
