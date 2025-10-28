//
//  SignUpView.swift
//  TodaysPlayer
//
//  Created by 이정명 on 9/26/25.
//

import SwiftUI
import FirebaseAuth
import Combine

// MARK: - 상태 Enum
enum SignupFieldState {
    case idle
    case checking
    case available
    case unavailable
    case invalid(String)
    case error(String)
    
    var message: String {
        switch self {
        case .idle: return ""
        case .checking: return "확인 중..."
        case .available: return "사용 가능합니다."
        case .unavailable: return "이미 사용 중 입니다."
        case .invalid(let msg): return msg
        case .error(let msg): return msg
        }
    }
    
    var isChecking: Bool { if case .checking = self { return true } else { return false } }
    var isAvailable: Bool { if case .available = self { return true } else { return false } }
}


// MARK: - 비밀번호 강도 Enum
enum PasswordStrength: String {
    case weak = "약함"
    case medium = "보통"
    case strong = "강함"
    case none = ""
    
    var color: Color {
        switch self {
        case .weak: return .accentRed
        case .medium: return .accentOrange
        case .strong, .none: return .primaryBaseGreen
        }
    }
    
    var level: CGFloat {
        switch self {
        case .weak: return 0.33
        case .medium: return 0.66
        case .strong: return 1.0
        case .none: return 0.0
        }
    }
}

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var nickname = ""
    @State private var gender = "남성"
    @State private var navigateToComplete = false
    
    @State private var emailState: SignupFieldState = .idle
    @State private var nicknameState: SignupFieldState = .idle
    @State private var passwordStrength: PasswordStrength = .none
    
    let genders = ["남성", "여성"]
    @Binding var path: NavigationPath
    private let authManager = AuthManager()
    
    var body: some View {
        ZStack {
            VStack {
                ScrollView{
                    VStack(spacing: 24) {
                        
                        // 이메일 입력
                        InputWithDuplicationCheck(
                            title: "이메일",
                            text: $email,
                            fieldState: $emailState,
                            placeholder: "이메일 주소 입력",
                            checkAction: checkEmailDuplication
                        )
                        .onChange(of: email) { _, _ in validateEmail() }
                        .padding(.top)
                        
                        // 비밀번호
                        VStack(alignment: .leading, spacing: 8) {
                            Text("비밀번호")
                            SecureField("비밀번호 (8자 이상)", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: password) { newValue, _ in
                                    passwordStrength = evaluatePasswordStrength(newValue)
                                }
                            
                            if passwordStrength != .none {
                                VStack(alignment: .leading, spacing: 4) {
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 6)
                                                .frame(height: 8)
                                                .foregroundColor(Color.gray.opacity(0.2))
                                            
                                            RoundedRectangle(cornerRadius: 6)
                                                .frame(width: geometry.size.width * passwordStrength.level, height: 8)
                                                .foregroundColor(passwordStrength.color)
                                                .animation(.easeInOut(duration: 0.3), value: passwordStrength)
                                        }
                                    }
                                    .frame(height: 8)
                                    
                                    Text("보안 수준: \(passwordStrength.rawValue)")
                                        .font(.caption)
                                        .foregroundColor(passwordStrength.color)
                                }
                            }
                            
                            if !isPasswordValid(password) && !password.isEmpty {
                                Text("8자 이상 입력해야 합니다.")
                                    .font(.caption)
                                    .foregroundColor(.accentRed)
                            }
                        }
                        
                        // 비밀번호 확인
                        VStack(alignment: .leading, spacing: 5) {
                            Text("비밀번호 확인")
                            SecureField("비밀번호 확인", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !confirmPassword.isEmpty && confirmPassword != password {
                                Text("비밀번호가 일치하지 않습니다.")
                                    .font(.caption)
                                    .foregroundColor(.accentRed)
                            }
                        }
                        
                        // 닉네임
                        InputWithDuplicationCheck(
                            title: "닉네임",
                            text: $nickname,
                            fieldState: $nicknameState,
                            placeholder: "닉네임 입력",
                            checkAction: checkNicknameDuplication
                        )
                        .onChange(of: nickname) { _, _ in validateNickname() }
                        
                        // 성별
                        VStack(alignment: .leading, spacing: 5) {
                            Text("성별")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            HStack(spacing: 12) {
                                ForEach(genders, id: \.self) { g in
                                    Button(action: { gender = g }) {
                                        Text(g)
                                            .fontWeight(.medium)
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 14)
                                            .background(gender == g ? Color.primaryBaseGreen : Color.gray.opacity(0.1))
                                            .foregroundColor(gender == g ? .white : .black)
                                            .cornerRadius(8)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(gender == g ? Color.primaryBaseGreen : Color.gray.opacity(0.3), lineWidth: 1)
                                            )
                                    }
                                }
                            }
                        }
                        Spacer()
                        
                    }
                    .padding(.bottom, 120)
                }
                
                // 가입 버튼
                Button(action: signUp) {
                    Text("가입하기")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(canProceed() ? Color.primaryBaseGreen : Color.secondaryCoolGray)
                        .cornerRadius(8)
                }
                .disabled(!canProceed())
            }
        }
        .padding(.horizontal, 20)
        .background(Color.gray.opacity(0.1))
        .navigationTitle("회원가입")
        .navigationDestination(isPresented: $navigateToComplete) {
            SignUpCompleteView(path: $path, userNickname: nickname)
        }
        .onTapGesture(perform: {
            UIApplication.shared.endEditing()
        })
        
    }
    
}

// MARK: - 로직 확장
extension SignUpView {
    private func signUp() {
        Task {
            try await AuthManager().signUpWithEmail(
                userData: SignupData(
                    email: email,
                    password: password,
                    displayName: nickname,
                    gender: gender
                )
            )
            navigateToComplete = true
        }
    }
    
    private func validateEmail() {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        if email.isEmpty {
            emailState = .idle
        } else if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email) {
            emailState = .invalid("올바른 이메일 형식을 입력해주세요.")
        } else {
            emailState = .idle
        }
    }
    
    private func validateNickname() {
        let regex = #"^[가-힣A-Za-z0-9]{2,10}$"#
        if nickname.isEmpty {
            nicknameState = .idle
        } else if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: nickname) {
            nicknameState = .invalid("닉네임은 2~10자 한글/영문/숫자만 가능합니다.")
        } else {
            nicknameState = .idle
        }
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
        password.count >= 8
    }
    
    private func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
        if password.isEmpty { return .none }
        let strong = #"^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*()_+=-]).{10,}$"#
        let medium = #"^(?=.*[A-Za-z])(?=.*\d).{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", strong).evaluate(with: password)
        ? .strong
        : NSPredicate(format: "SELF MATCHES %@", medium).evaluate(with: password)
        ? .medium : .weak
    }
    
    private func checkEmailDuplication() async {
        guard !email.isEmpty else { return }
        guard case .invalid = emailState else {
            emailState = .checking
            do {
                let isDuplicated = try await authManager
                    .checkEmailDuplication(checkType: .email, checkValue: email)
                
                emailState = isDuplicated ? .available : .invalid("이미 사용중인 이메일입니다.")
            } catch {
                print("error: \(error)")
                emailState = .error("오류가 발생했습니다. 다시 시도해주세요.")
            }
            return
        }
    }
    
    private func checkNicknameDuplication() async {
        guard !nickname.isEmpty else { return }
        guard case .invalid = nicknameState else {
            nicknameState = .checking
            
            do {
                let isDuplicated = try await authManager
                    .checkEmailDuplication(checkType: .nickName, checkValue: nickname)
                
                nicknameState = isDuplicated ? .available : .invalid("이미 사용중인 닉네임입니다.")
            } catch {
                print("error: \(error)")
                nicknameState = .error("오류가 발생했습니다. 다시 시도해주세요.")
            }
            
            return
        }
    }
    
    private func canProceed() -> Bool {
        emailState.isAvailable &&
        isPasswordValid(password) &&
        confirmPassword == password &&
        nicknameState.isAvailable
    }
}

// MARK: - InputWithDuplicationCheck
struct InputWithDuplicationCheck: View {
    var title: String
    @Binding var text: String
    @Binding var fieldState: SignupFieldState
    var placeholder: String
    var checkAction: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
            
            HStack(spacing: 8) {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.never)
                
                Button {
                    Task { await checkAction() }
                } label: {
                    if fieldState.isChecking {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .primaryBaseGreen))
                    } else {
                        Text("중복확인")
                            .font(.subheadline)
                            .foregroundColor(.primaryBaseGreen)
                    }
                }
                .frame(width: 80, height: 38)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
                .disabled(fieldState.isChecking || text.isEmpty)
            }
            
            if !fieldState.message.isEmpty {
                Text(fieldState.message)
                    .font(.caption)
                    .foregroundColor(fieldState.isAvailable ? .primaryBaseGreen : .accentRed)
            }
        }
    }
}
