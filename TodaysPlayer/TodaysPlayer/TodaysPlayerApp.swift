//
//  TodaysPlayerApp.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

@main
struct TodaysPlayerApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var favoriteViewModel = FavoriteViewModel()
    @StateObject private var userSessionManager = UserSessionManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(favoriteViewModel)
                .environmentObject(userSessionManager)
        }
    }

}
