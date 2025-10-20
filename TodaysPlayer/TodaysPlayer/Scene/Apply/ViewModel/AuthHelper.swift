//
//  AuthHelper.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/13/25.
//

import Foundation
import FirebaseAuth

/// 앱 전체에서 사용하는 인증 관련 헬퍼 클래스
/// UserSessionManager와 Firebase Auth를 통해 현재 로그인한 사용자 정보를 제공합니다.
class AuthHelper {
    
    /// 현재 로그인한 사용자의 ID를 반환
    /// - Returns: 사용자 ID (로그인 상태: Firebase UID, 미로그인: nil 또는 빈 문자열)
    static var currentUserId: String {
        // 방법 1: UserSessionManager 사용 (권장)
        // AuthManager의 로그인 로직에서 currentUser를 설정하므로 이를 우선 사용
        if let userId = UserSessionManager.shared.currentUser?.id {
            return userId
        }
        
        // 방법 2: Firebase Auth 직접 사용 (fallback)
        // UserSessionManager에 데이터가 없을 경우를 대비한 백업
        if let firebaseUserId = Auth.auth().currentUser?.uid {
            return firebaseUserId
        }
        
        // 로그인되지 않은 경우
        // 빈 문자열 반환 (또는 필요에 따라 nil을 반환하도록 Optional String으로 변경 가능)
        return ""
    }
    
    /// 사용자가 로그인했는지 확인
    /// - Returns: 로그인 여부 (true: 로그인됨, false: 로그인 안됨)
    static var isLoggedIn: Bool {
        // UserSessionManager의 isLoggedIn 상태 확인 (AuthManager에서 관리)
        return UserSessionManager.shared.isLoggedIn
    }
    
    /// Optional: 현재 로그인한 사용자의 전체 정보를 반환
    /// - Returns: User 객체 (로그인 상태일 때만)
    static var currentUser: User? {
        return UserSessionManager.shared.currentUser
    }
}
