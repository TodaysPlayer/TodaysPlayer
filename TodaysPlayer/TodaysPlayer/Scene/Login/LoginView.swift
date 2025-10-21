//
//  LoginView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI
import Combine
import FirebaseAuth

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    
    // Alert 상태
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 이메일·비밀번호 입력 오류 표시용
    @State private var emailErrorMessage = ""
    @State private var passwordErrorMessage = ""
    
    @FocusState private var focusedField: Field?
    enum Field { case email, password }
    
    @State private var keyboardHeight: CGFloat = 0
    
    private let authManager: AuthManager = AuthManager()
    @State var path = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $path) {
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                    .onTapGesture { focusedField = nil }
                
                ScrollView {
                    VStack(spacing: 30) {
                        
                        // 상단 로고
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 80, height: 80)
                                Image(systemName: "shield.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            }
                            Text("오늘의 용병")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("빠르고 쉬운 로컬 스포츠 매칭")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 50)
                        
                        // 로그인 카드
                        VStack(spacing: 20) {
                            Text("로그인")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 10)
                            
                            // 이메일 입력 필드
                            VStack(alignment: .leading, spacing: 4) {
                                Text("이메일")
                                TextField("이메일을 입력하세요", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .keyboardType(.emailAddress)
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .password }
                                    .onChange(of: email) { newValue in
                                        validateEmail(newValue)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                
                                if !emailErrorMessage.isEmpty {
                                    Text(emailErrorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            // 비밀번호 입력 필드
                            VStack(alignment: .leading, spacing: 4) {
                                Text("비밀번호")
                                SecureField("비밀번호를 입력하세요", text: $password)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.done)
                                    .onSubmit { login() }
                                    .onChange(of: password) { newValue in
                                        validatePassword(newValue)
                                    }
                                    .padding()
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                
                                if !passwordErrorMessage.isEmpty {
                                    Text(passwordErrorMessage)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                            }
                            
                            // 로그인 버튼
                            Button(action: login) {
                                Text("로그인")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue)
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                            }
                            
                            NavigationLink(destination: PasswordResetView()) {
                                Text("비밀번호를 잊으셨나요?")
                                    .foregroundColor(.gray)
                            }
                            
                            // 회원가입으로 이동 (약관동의 -> 회원가입)
                            //                            NavigationLink(destination: UserAgreementView()) {
                            //                                Text("이메일로 회원가입")
                            //                                    .frame(maxWidth: .infinity)
                            //                                    .padding()
                            //                                    .background(Color.white)
                            //                                    .overlay(
                            //                                        RoundedRectangle(cornerRadius: 8)
                            //                                            .stroke(Color.gray.opacity(0.3))
                            //                                    )
                            //                            }
                            
                            Button {
                                path.append("UserAgreement")
                            } label: {
                                Text("이메일로 회원가입")
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.gray.opacity(0.3))
                                    )
                            }
                            
                            .navigationDestination(for: String.self) { value in
                                if value == "UserAgreement" {
                                    UserAgreementView(path: $path)
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.bottom, keyboardHeight)
                    .animation(.easeOut(duration: 0.25), value: keyboardHeight)
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("로그인 오류"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            ContentView() // ✅ 로그인 성공 시 홈화면 이동
        }
        .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }
    
    // MARK: - 실시간 이메일 검증
    private func validateEmail(_ email: String) {
        if email.isEmpty {
            emailErrorMessage = "이메일을 입력하세요"
        } else if !isValidEmail(email) {
            emailErrorMessage = "올바른 이메일 형식이 아닙니다"
        } else {
            emailErrorMessage = ""
        }
    }
    
    // MARK: - 실시간 비밀번호 검증
    private func validatePassword(_ password: String) {
        if password.isEmpty {
            passwordErrorMessage = "비밀번호를 입력하세요"
        } else if !isValidPassword(password) {
            passwordErrorMessage = "비밀번호는 8자 이상이어야 합니다"
        } else {
            passwordErrorMessage = ""
        }
    }
    
    // MARK: - 정규식 검사
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
    
    private func isValidPassword(_ password: String) -> Bool {
        let pattern = #"^.{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: password)
    }
    
    // MARK: - 로그인 로직 (Firebase)
    private func login() {
        guard emailErrorMessage.isEmpty, passwordErrorMessage.isEmpty else { return }
        
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error as NSError? {
                switch AuthErrorCode(rawValue: error.code) {
                case .networkError:
                    alertMessage = "네트워크 오류가 발생했습니다. 연결을 확인하세요."
                case .invalidEmail:
                    alertMessage = "유효하지 않은 이메일 형식입니다."
                case .userNotFound:
                    alertMessage = "가입되지 않은 이메일입니다."
                case .wrongPassword:
                    alertMessage = "비밀번호가 올바르지 않습니다."
                default:
                    alertMessage = "로그인에 실패했습니다. 다시 시도해주세요."
                }
                showAlert = true
                return
            }
            
            if let user = result?.user {
                print("✅ 로그인 성공: \(user.email ?? "")")
                isLoggedIn = true
                
                Task {
                    let userData = await UserDataRepository().fetchUserData(with: user.uid)
                    await MainActor.run {
                        UserSessionManager.shared.currentUser = userData
                        UserSessionManager.shared.isLoggedIn = true
                        isLoggedIn = true
                    }
                }
            }
        }
    }
}

// MARK: - 키보드 높이 감지
extension Publishers {
    static var KeyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return willShow.merge(with: willHide).eraseToAnyPublisher()
    }
}

#Preview {
    LoginView()
}
