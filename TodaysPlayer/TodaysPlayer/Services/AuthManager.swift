//
//  AuthManager.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/18/25.
//

import SwiftUI
import FirebaseAuth

enum DuplicationCheckType: String {
    case email = "email"
    case nickName = "displayName"
}

struct SignupData {
    let email: String
    let password: String
}

enum AuthError: LocalizedError {
    case emailAlreadyInUse
    case invalidEmail
    case weakPassword
    case wrongPassword
    case userNotFound
    case missingUID
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .emailAlreadyInUse:
            return "이미 사용 중인 이메일입니다."
        case .invalidEmail:
            return "이메일 형식이 올바르지 않습니다."
        case .weakPassword:
            return "비밀번호는 6자리 이상이어야 합니다."
        case .wrongPassword:
            return "비밀번호가 올바르지 않습니다."
        case .userNotFound:
            return "가입된 사용자를 찾을 수 없습니다."
        case .missingUID:
            return "사용자 UID를 가져올 수 없습니다."
        case .unknown(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}


@Observable
final class AuthManager {
    var isSignup: Bool = false
    var currentUser: User? = nil
    var isSignedIn: Bool = false
    
    // 이메일 중복 확인 네트워킹 처리
    // 닉네임 중복 확인 네트워킹 처리
    func checkEmailDuplication(
        checkType: DuplicationCheckType,
        checkValue: String
    ) async throws -> Bool {
        let user = try await FirestoreManager.shared
            .queryDocuments(
                collection: "users",
                where: checkType.rawValue,
                isEqualTo: checkValue,
                as: User.self
            )
        
        user.isEmpty ? print("사용가능") : print("사용불가능")
        
        return user.isEmpty
        
    }
    
    // 회원가입
    func signUpWithEmail(userData: SignupData) async throws {
        do {
            let result = try await Auth.auth()
                .createUser(
                    withEmail: userData.email,
                    password: userData.password
                )
            
            let uid = result.user.uid
            try await registerUserData(userData: userData, uid: uid )
            
            print("사용자 회원가입 완료")
            isSignup = true
        }catch {
            print("사용자 회원가입 실패: \(error.localizedDescription)")
            isSignup = false
            throw error
        }
            
          
    }
    // 파베에 유저 데이터 생성
    // 로그인
    // - 네트워킹 성공: 홈화면으로 유저데이터 던져줘야함
    // - 네트워킹 실패 : 가입되지 않은 이메일 인지 네트워크 오류인지 뭔지
    
    private func registerUserData(userData: SignupData, uid: String) async throws {
        let registerUserData = User(
            id: uid,
            email: userData.email,
            displayName: "yh" ,
            profileImageUrl: "",
            phoneNumber: "",
            position: "",
            skillLevel: "",
            preferredRegions: [],
            createdAt: Date(),
            updatedAt: Date(),
            userRate: UserRating(
                totalRatingCount: 0,
                mannerSum: 0,
                teamWorkSum: 0,
                appointmentSum: 0
            )
        )
        
        
        _ = try await FirestoreManager.shared
            .createDocument(
                collection: "users",
                documentId: registerUserData.id,
                data: registerUserData
            )
    }
    
    func loginWithEmail(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth()
                .signIn(withEmail: email, password: password)
            
            self.isSignedIn = true
            
            self.currentUser = await UserDataRepository().fetchUserData(with: result.user.uid)

            print("로그인 성공")
        }catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    
    /// 로그아웃
    func logout(){
        do {
            try Auth.auth().signOut()
            self.isSignedIn = false
            self.currentUser = nil
            print("로그아웃 완료")
        }catch {
            print("로그아웃 실패: \(error.localizedDescription)")
        }
    }
    
    // 자동로그인
    func checkAuthState() async {
        if let user = Auth.auth().currentUser {
            self.isSignedIn = true
            self.currentUser = await UserDataRepository().fetchUserData(with: user.uid)
            
            print("자동 로그인 성공")
        } else {
            self.isSignedIn = false
        }
    }
    
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("비밀번호 재설정 이메일 전송 완료")
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    private func mapFirebaseError(_ error: NSError) -> AuthError {
        switch error.code {
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
        case AuthErrorCode.invalidEmail.rawValue:
            return .invalidEmail
        case AuthErrorCode.weakPassword.rawValue:
            return .weakPassword
        case AuthErrorCode.wrongPassword.rawValue:
            return .wrongPassword
        case AuthErrorCode.userNotFound.rawValue:
            return .userNotFound
        default:
            return .unknown(error)
        }
    }
}
