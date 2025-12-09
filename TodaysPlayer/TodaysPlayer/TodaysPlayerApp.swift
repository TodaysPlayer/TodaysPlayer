//
//  TodaysPlayerApp.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI
import KakaoSDKCommon
import KakaoSDKAuth

@main
struct TodaysPlayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var favoriteViewModel = FavoriteViewModel()
    @StateObject private var userSessionManager = UserSessionManager.shared
    
    init() {
        KakaoSDK.initSDK(appKey: KakaoConfig.nativeAppKey)
    }
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(favoriteViewModel)
                .environmentObject(userSessionManager)
                .onOpenURL { url in
                    if AuthApi.isKakaoTalkLoginUrl(url) {
                        _ = AuthController.handleOpenUrl(url: url)
                    }
                }
        }
    }

}
