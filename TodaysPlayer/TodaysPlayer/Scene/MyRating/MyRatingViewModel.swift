//
//  MyRatingViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/16/25.
//

import Foundation

final class MyRatingViewModel {
    var userData: User? = UserSessionManager.shared.currentUser
    
    private let repository: UserDataRepository = UserDataRepository()

    /// 평균 평점 계산
    func avgRating() -> Double {
        guard let data = userData else { return 0.0 }
        let rate = data.userRate
        guard rate.totalRatingCount > 0 else { return 0.0 }
        let total = rate.appointmentSum + rate.mannerSum + rate.teamWorkSum
        return total / Double(rate.totalRatingCount * 3)
    }
    
    func fetchUserRate(userId: String){
        Task {
            let user = await repository.fetchUserData(with: userId)
            self.userData = user
        }
    }
}
