//
//  RootView.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/18/25.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var userSessionManager: UserSessionManager
    @EnvironmentObject var favoriteViewModel: FavoriteViewModel
    
    var body: some View {
        Group {
            if userSessionManager.isLoading {
                LaunchScreenView()
            } else if userSessionManager.isLoggedIn {
                ContentView()
                    .environmentObject(favoriteViewModel)
                    .environmentObject(userSessionManager)
            }else {
                LoginView()
                    .environmentObject(favoriteViewModel)
                    .environmentObject(userSessionManager)
            }
        }
    }
}
