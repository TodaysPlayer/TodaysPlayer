//
//  UserSessionManager.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/18/25.
//

import SwiftUI
import Combine
import FirebaseAuth

@MainActor
final class UserSessionManager: ObservableObject {
    static let shared = UserSessionManager()
    
    @Published var currentUser: User?
    @Published var isLoading = true
    @Published var isLoggedIn: Bool = false
    
    private init(){
        Task { await checkAuthState()}
    }
    
    // 자동로그인
    func checkAuthState() async {
        try? await Task.sleep(for: .seconds(0.8))

        if let user = Auth.auth().currentUser {
            
            self.isLoggedIn = true
            self.currentUser = await UserDataRepository().fetchUserData(with: user.uid)
            self.isLoading = true
            print("자동 로그인 성공")
        } else {
            self.isLoggedIn = false
            self.isLoading = false
            print("자동로그인 실패")
        }
        
        
        self.isLoading = false
    }
    
    func updateSession(with user: User) {
        currentUser = user
        isLoggedIn = (currentUser != nil)
    }
    
    func removeSeesion() {
        currentUser = nil
        isLoggedIn = false
    }
}
