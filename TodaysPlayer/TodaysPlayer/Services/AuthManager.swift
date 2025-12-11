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
import KakaoSDKUser
import KakaoSDKAuth

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
    case kakaoLoginFailed(String)
    case kakaoUserInfoFailed(String)
    case missingKakaoEmail
    case emailAlreadyRegistered(provider: String)
    case logoutFailed(String)
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
        case .kakaoLoginFailed(let message):
            return "카카오 로그인 실패: \(message)"
        case .kakaoUserInfoFailed(let message):
            return "사용자 정보 가져오기 실패: \(message)"
        case .missingKakaoEmail:
            return "카카오 계정에서 이메일 정보를 가져올 수 없습니다. 이메일 제공에 동의해주세요."
        case .emailAlreadyRegistered(let provider):
            let providerName: String
            switch provider {
            case "email": providerName = "이메일/비밀번호"
            case "google": providerName = "구글"
            case "kakao": providerName = "카카오"
            case "naver": providerName = "네이버"
            default: providerName = provider
            }
            return "이 이메일은 이미 \(providerName)로 가입되어 있습니다. 해당 방법으로 로그인해주세요."
        case .logoutFailed(let message):  // 👈 추가
            return "로그아웃 실패: \(message)"
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
            try await registerUserData(userData: userData, uid: uid, provider: "email")
            
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
    
    // MARK: - 카카오 로그인
    func signInWithKakao() async throws -> Bool {
        // 1. 카카오 로그인 (카카오톡 앱 또는 웹)
        _ = try await loginWithKakaoSDK()
        print("카카오 로그인 성공")
        
        // 2. 카카오 사용자 정보 가져오기
        let kakaoUser = try await fetchKakaoUserInfo()
        
        guard let email = kakaoUser.email,
              let nickname = kakaoUser.nickname else {
            throw AuthError.missingKakaoEmail
        }
        
        let gender = kakaoUser.gender ?? " "
        
        print("카카오 이메일: \(email)")
        print("카카오 닉네임: \(nickname)")
        print("카카오 성별: \(gender)")
        
        // 3. Firebase 연동
        return try await linkToFirebase(email: email, userName: nickname, gender: gender)
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
    
    // MARK: - 카카오 로그아웃
    func signOutFromKakao() async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            UserApi.shared.logout { error in
                if let error = error {
                    continuation.resume(throwing: AuthError.logoutFailed(error.localizedDescription))
                } else {
                    continuation.resume()
                }
            }
        }
        
        try Auth.auth().signOut()
        
        await MainActor.run {
            UserSessionManager.shared.removeSeesion()
        }
        
        print("카카오 로그아웃 완료")
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
    private func registerUserData(userData: SignupData, uid: String, provider: String) async throws { // 제공자 추가(email방식)
        let registerUserData = User(
            id: uid,
            email: userData.email,
            displayName: userData.displayName,
            provider: provider,
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
            provider: "google",
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
    
    // MARK: - 카카오 로그인 Private Methods
    
    /// 1. 카카오 SDK 로그인
    private func loginWithKakaoSDK() async throws -> OAuthToken {
        return try await withCheckedThrowingContinuation { continuation in
            if UserApi.isKakaoTalkLoginAvailable() {
                // 카카오톡 앱 로그인
                UserApi.shared.loginWithKakaoTalk { oauthToken, error in
                    if let error = error {
                        continuation.resume(throwing: AuthError.kakaoLoginFailed(error.localizedDescription))
                    } else if let token = oauthToken {
                        continuation.resume(returning: token)
                    }
                }
            } else {
                // 카카오 계정 로그인 (웹)
                UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                    if let error = error {
                        continuation.resume(throwing: AuthError.kakaoLoginFailed(error.localizedDescription))
                    } else if let token = oauthToken {
                        continuation.resume(returning: token)
                    }
                }
            }
        }
    }
    
    /// 2. 카카오 사용자 정보 가져오기
    private func fetchKakaoUserInfo() async throws -> (email: String?, nickname: String?, gender: String?) {
        return try await withCheckedThrowingContinuation { continuation in
            UserApi.shared.me { user, error in
                if let error = error {
                    continuation.resume(throwing: AuthError.kakaoUserInfoFailed(error.localizedDescription))
                } else {
                    let email = user?.kakaoAccount?.email
                    let nickname = user?.kakaoAccount?.profile?.nickname
                    let genderString: String?
                    if let gender = user?.kakaoAccount?.gender {
                        switch gender {
                        case .Female:
                            genderString = "여성"
                        case .Male:
                            genderString = "남성"
                        }
                    } else {
                        genderString = nil
                    }
                    continuation.resume(returning: (email, nickname, genderString))
                }
            }
        }
    }
    
    /// 3. Firebase 연동
    private func linkToFirebase(email: String, userName: String, gender: String) async throws -> Bool {
        let password = "kakao_\(email)_secure_password_123!@#"
        
        // 3-1. 기존 계정 있는지 확인
        if let existingProvider = try await checkProvider(email: email) {
            // 이미 계정 존재
            if existingProvider == "kakao" {
                // 카카오 계정 → 로그인
                print("기존 카카오 계정으로 로그인")
                return try await signInToFirebase(email: email, password: password)
            } else {
                // 다른 제공업체 (email, google, naver 등)
                throw AuthError.emailAlreadyRegistered(provider: existingProvider)
            }
        } else {
            // 3-2. 신규 유저 → 카카오 계정 생성
            print("신규 카카오 계정 생성")
            try await createKakaoAccount(email: email, userName: userName, password: password, gender: gender)
            return try await signInToFirebase(email: email, password: password)
        }
    }
    
    /// Firebase 계정 존재 확인 (provider 반환)
    private func checkProvider(email: String) async throws -> String? {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("users")
            .whereField("email", isEqualTo: email)
            .getDocuments()
        
        if let document = snapshot.documents.first {
            return document.data()["provider"] as? String
        }
        return nil
    }
    
    /// 카카오 계정 생성 (Firebase + Firestore)
    private func createKakaoAccount(email: String, userName: String, password: String, gender: String) async throws {
        let authResult = try await Auth.auth().createUser(withEmail: email, password: password)
        let userId = authResult.user.uid
        
        let kakaoUserData = User(
            id: userId,
            email: email,
            displayName: userName,
            provider: "kakao",
            gender: gender,
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
                documentId: kakaoUserData.id,
                data: kakaoUserData
            )
        
        print("✅ 카카오 Firebase 계정 생성 완료")
    }
    
    /// Firebase 로그인
    private func signInToFirebase(email: String, password: String) async throws -> Bool {
        let authResult = try await Auth.auth().signIn(withEmail: email, password: password)
        
        // UserSessionManager 업데이트
        let userData = await UserDataRepository().fetchUserData(with: authResult.user.uid)
        
        await MainActor.run {
            UserSessionManager.shared.currentUser = userData
            UserSessionManager.shared.isLoggedIn = true
        }
        
        print("✅ Firebase 로그인 완료")
        return true
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
