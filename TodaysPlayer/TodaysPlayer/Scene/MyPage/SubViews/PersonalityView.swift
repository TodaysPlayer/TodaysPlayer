//
//  PersonalityView.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 9/29/25.
//

import SwiftUI
import WebKit

private struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero)
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        // Load only if needed
        if webView.url != url {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
}

struct PersonalityView: View {
    private let policyURL = URL(string: "https://www.notion.so/29bdb27feebd8065bf50de6cc94a34fc?source=copy_link")!

    var body: some View {
        WebView(url: policyURL)
            .ignoresSafeArea(edges: .bottom)
            .navigationTitle("개인정보 처리방침")
            .toolbar(.hidden, for: .tabBar)
    }
}

#Preview {
    NavigationStack { PersonalityView() }
}
