//
//  MyRatingViewModel.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/16/25.
//

import Foundation

final class MyRatingViewModel {
    var userData: User? = nil
    
    init(userId: String){
        Task { await fetchUserData(with: userId)}
    }
    
    /// 사용자의 정보 가져오기
    func fetchUserData(with userId: String) async {
        do {
            let user = try await FirestoreManager.shared
                .queryDocuments(
                    collection: "users",
                    where: "userId",
                    isEqualTo: userId,
                    as: User.self
                ).first
            
            userData = user
            print("유저정보 가져옴")
        } catch {
            print("유저 데이터를 못가져옴 \(error.localizedDescription)")
        }
    }
    
    /// 평균 평점 계산
    func avgRating() -> Double {
        guard let data = userData else { return 0.0 }
        let rate = data.userRate
        guard rate.totalRatingCount > 0 else { return 0.0 }
        let total = rate.appointmentSum + rate.mannerSum + rate.teamWorkSum
        return total / Double(rate.totalRatingCount * 3)
    }
}
