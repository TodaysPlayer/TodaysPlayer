//
//  FetchUserDataRepository.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/16/25.
//

import Foundation
import FirebaseFirestore

final class UserDataRepository {
    
    /// 사용자의 정보 가져오기
    func fetchUserData(with userId: String) async -> User? {
        do {
            let user = try await FirestoreManager.shared
                .getDocument(
                    collection: "users",
                    documentId: userId,
                    as: User.self
                )
            
            return user
            
        } catch {
            print("유저 데이터를 못가져옴 \(error.localizedDescription)")
            return nil
        }
    }
    
    // 사용자 정보를 수정하기 - 평점 받아서 수정
    func editUserRateData(user: User,rating: [UserRatingCategory: Int]) async {
        do {
            try await FirestoreManager.shared
                .updateDocument(
                    collection: "users",
                    documentId: user.id,
                    data: [
                        "userRate.totalRatingCount": FieldValue.increment(Double(1)),
                        "userRate.appointmentSum": FieldValue.increment(Double(rating[.appointment] ?? 4)),
                        "userRate.mannerSum": FieldValue.increment(Double(rating[.manner] ?? 4)),
                        "userRate.teamWorkSum": FieldValue.increment(Double(rating[.teamwork] ?? 4))
                    ]
                )
            print("사용자 평점 업데이트 완료")
            
        } catch {
            print("사용자 평점 업데이트 실패\(error.localizedDescription)")
        }
    }
}
