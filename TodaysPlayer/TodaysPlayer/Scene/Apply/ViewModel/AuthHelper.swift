//
//  AuthHelper.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/13/25.
//

import Foundation
// import FirebaseAuth // ⭐️ TODO: 로그인 완성 후 주석 해제

/// 앱 전체에서 사용하는 인증 관련 헬퍼 클래스
/// 로그인 완성 전까지는 임시 사용자 ID를 반환하고,
/// 로그인 완성 후에는 Firebase Auth의 실제 사용자 ID를 반환합니다.
class AuthHelper {
    
    /// 현재 로그인한 사용자의 ID를 반환
    /// - Returns: 사용자 ID (로그인 전: "temp_user_id", 로그인 후: Firebase UID)
    static var currentUserId: String {
        // ⭐️ TODO: 로그인 완성 후 수정 필요!
        // ========================================
        // [방법 1] AuthManager 사용하는 경우:
        // if let authManager = // AuthManager 인스턴스 가져오기 {
        //     return authManager.currentUserId ?? "temp_user_id"
        // }
        //
        // [방법 2] Firebase Auth 직접 사용하는 경우:
        // return Auth.auth().currentUser?.uid ?? "temp_user_id"
        // ========================================
        
        return "temp_user_id" // 임시 사용자 ID
    }
    
    /// 사용자가 로그인했는지 확인
    /// - Returns: 로그인 여부 (true: 로그인됨, false: 로그인 안됨)
    static var isLoggedIn: Bool {
        // ⭐️ TODO: 로그인 완성 후 수정 필요!
        // return Auth.auth().currentUser != nil
        
        return true // 임시로 true 반환 (개발 편의상)
    }
}
