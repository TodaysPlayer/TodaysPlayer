//
//  MyPageViewModel.swift
//  TodaysPlayer
//
//  Created by jonghyuck on 10/17/25.
//


import Foundation
import Combine
import FirebaseAuth

final class MyPageViewModel: ObservableObject {
    @Published var profile: UserProfile = .default
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private let repository: MyPageRepository
    
    init(repository: MyPageRepository = MyPageRepository()) {
        self.repository = repository
    }
    
    @MainActor
    private func setLoading(_ loading: Bool) {
        self.isLoading = loading
    }
    
    func load() async {
        await setLoading(true)
        defer { Task { @MainActor in self.isLoading = false } }
        
        guard let uid = Auth.auth().currentUser?.uid else {
            await MainActor.run { self.errorMessage = "로그인 정보가 없습니다." }
            return
        }
        
        do {
            let fetched = try await repository.fetchUserProfile(uid: uid)
            await MainActor.run {
                self.profile = fetched
                self.errorMessage = nil
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
            }
        }
    }
}
