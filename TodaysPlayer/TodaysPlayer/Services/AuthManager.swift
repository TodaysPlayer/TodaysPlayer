//
//  AuthManager.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/18/25.
//

import SwiftUI
import FirebaseAuth
import GoogleSignIn
import FirebaseFirestore

enum DuplicationCheckType: String {
    case email = "email"
    case nickName = "displayName"
}

struct SignupData {
    let email: String
    let password: String
    let displayName: String
    let gender: String
}

enum AuthError: LocalizedError {
    case emailAlreadyInUse
    case invalidEmail
    case weakPassword
    case wrongPassword
    case userNotFound
    case missingUID
    case googleSignInFailed
    case windowNotFound
    case unknown(Error)
    
    var errorDescription: String {
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
        case .googleSignInFailed:
            return "구글 로그인에 실패했습니다."
        case .windowNotFound:
            return "앱 화면을 찾을 수 없습니다."
        case .unknown(let error):
            return "알 수 없는 오류: \(error.localizedDescription)"
        }
    }
}

@Observable
final class AuthManager {
    var isSignup: Bool = false
    
    // MARK: - 이메일/닉네임 중복 확인
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
    
    // MARK: - 이메일 회원가입
    func signUpWithEmail(userData: SignupData) async throws {
        do {
            let result = try await Auth.auth()
                .createUser(
                    withEmail: userData.email,
                    password: userData.password
                )
            
            let uid = result.user.uid
            try await registerUserData(userData: userData, uid: uid)
            
            print("✅ 사용자 회원가입 완료")
            isSignup = true
        } catch {
            print("❌ 사용자 회원가입 실패: \(error.localizedDescription)")
            isSignup = false
            throw error
        }
    }
    
    // MARK: - 이메일 로그인
    func loginWithEmail(email: String, password: String) async throws {
        do {
            let result = try await Auth.auth()
                .signIn(withEmail: email, password: password)
            
            UserSessionManager.shared.currentUser = await UserDataRepository()
                .fetchUserData(with: result.user.uid)
            
            UserSessionManager.shared.isLoggedIn = true
            
            print("✅ 이메일 로그인 성공")
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    
    // MARK: - 구글 로그인
    @MainActor
    func signInWithGoogle() async throws -> Bool {
        // 1. Window Scene 가져오기
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            throw AuthError.windowNotFound
        }
        
        do {
            // 2. Google Sign-In 실행
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(
                withPresenting: rootViewController
            )
            let user = userAuthentication.user
            
            // 3. ID 토큰 확인
            guard let idToken = user.idToken else {
                throw AuthError.googleSignInFailed
            }
            
            // 4. Firebase 인증 Credential 생성
            let accessToken = user.accessToken
            let credential = GoogleAuthProvider.credential(
                withIDToken: idToken.tokenString,
                accessToken: accessToken.tokenString
            )
            
            // 5. Firebase Auth로 로그인
            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
            
            print("✅ Google 로그인 성공: \(firebaseUser.uid)")
            
            // 6. Firestore에 사용자 정보 저장 (신규 사용자인 경우에만)
            try await saveGoogleUserToFirestore(user: firebaseUser)
            
            // 7. UserSessionManager에 사용자 정보 로드
            UserSessionManager.shared.currentUser = await UserDataRepository()
                .fetchUserData(with: firebaseUser.uid)
            UserSessionManager.shared.isLoggedIn = true
            
            return true
            
        } catch {
            print("❌ Google 로그인 실패: \(error.localizedDescription)")
            throw AuthError.unknown(error)
        }
    }
    
    // MARK: - 구글 로그아웃
    func signOutFromGoogle() {
        do {
            try Auth.auth().signOut()
            GIDSignIn.sharedInstance.signOut()
            
            UserSessionManager.shared.isLoggedIn = false
            UserSessionManager.shared.currentUser = nil
            
            print("✅ 구글 로그아웃 완료")
        } catch {
            print("❌ 로그아웃 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 일반 로그아웃
    func logout() {
        do {
            try Auth.auth().signOut()
            UserSessionManager.shared.isLoggedIn = false
            UserSessionManager.shared.currentUser = nil

            print("✅ 로그아웃 완료")
        } catch {
            print("❌ 로그아웃 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - 비밀번호 재설정
    func resetPassword(email: String) async throws {
        do {
            try await Auth.auth().sendPasswordReset(withEmail: email)
            print("✅ 비밀번호 재설정 이메일 전송 완료")
        } catch let error as NSError {
            throw mapFirebaseError(error)
        }
    }
    // MARK: - Private Methods
    
    /// 이메일 회원가입 시 Firestore에 사용자 데이터 저장
    private func registerUserData(userData: SignupData, uid: String) async throws {
        let registerUserData = User(
            id: uid,
            email: userData.email,
            displayName: userData.displayName,
            gender: userData.gender,
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
    
    /// 구글 로그인 시 Firestore에 사용자 정보 저장 (신규 사용자만)
    private func saveGoogleUserToFirestore(user: FirebaseAuth.User) async throws {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(user.uid)
        
        // 기존 사용자인지 확인
        let document = try await docRef.getDocument()
        
        if document.exists {
            print("✅ 기존 구글 사용자 - Firestore 업데이트 생략")
            return
        }
        
        // 신규 사용자 - Firestore에 저장
        let googleUserData = User(
            id: user.uid,
            email: user.email ?? "",
            displayName: user.displayName ?? "구글 사용자",
            gender: "", // 구글 로그인은 성별 정보 없음
            profileImageUrl: user.photoURL?.absoluteString ?? "",
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
                documentId: googleUserData.id,
                data: googleUserData
            )
        
        print("✅ 구글 사용자 Firestore 저장 완료")
    }
    
    /// Firebase 에러를 AuthError로 매핑
    private func mapFirebaseError(_ error: NSError) -> AuthError {
        switch AuthErrorCode(rawValue: error.code) {
        case .emailAlreadyInUse:
            return .emailAlreadyInUse
        case .invalidEmail:
            return .invalidEmail
        case .weakPassword:
            return .weakPassword
        case .wrongPassword:
            return .wrongPassword
        case .userNotFound:
            return .userNotFound
        default:
            return .unknown(error)
        }
    }
}
