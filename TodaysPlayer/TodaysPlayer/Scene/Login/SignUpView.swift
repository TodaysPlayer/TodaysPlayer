//
//  SignUpView.swift
//  TodaysPlayer
//
//  Created by 이정명 on 9/26/25.
//

import SwiftUI
import FirebaseAuth

// MARK: - Enum 기반 상태
enum FieldState {
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
        case .available: return "✅ 사용 가능한 항목입니다."
        case .unavailable: return "❌ 사용 중인 항목입니다."
        case .invalid(let msg): return msg
        case .error(let msg): return msg
        }
    }
    
    var isChecking: Bool {
        if case .checking = self { return true }
        return false
    }
    
    var isAvailable: Bool {
        if case .available = self { return true }
        return false
    }
}

// MARK: - 비밀번호 강도 단계
enum PasswordStrength: String {
    case weak = "약함"
    case medium = "보통"
    case strong = "강함"
    case none = ""
    
    var color: Color {
        switch self {
        case .weak: return .red
        case .medium: return .orange
        case .strong: return .green
        case .none: return .gray
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
    
    @State private var emailState: FieldState = .idle
    @State private var nicknameState: FieldState = .idle
    @State private var passwordStrength: PasswordStrength = .none
    
    let genders = ["남성", "여성"]
    
    @Binding var path: NavigationPath
    
    var body: some View {
            ScrollView {
                VStack(spacing: 20) {
                    Text("회원가입")
                        .font(.title2)
                        .bold()
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // 이메일
                        InputWithDuplicationCheck(
                            title: "이메일 *",
                            text: $email,
                            fieldState: $emailState,
                            placeholder: "이메일",
                            checkAction: checkEmailDuplication
                        )
                        .onChange(of: email) { _ in
                            validateEmail()
                        }
                        
                        // 비밀번호
                        VStack(alignment: .leading, spacing: 8) {
                            Text("비밀번호 *")
                            SecureField("비밀번호 (8자 이상 입력해야 합니다)", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .onChange(of: password) { newValue in
                                    passwordStrength = evaluatePasswordStrength(newValue)
                                }
                            
                            // ✅ 비밀번호 강도 Progress Bar
                            if passwordStrength != .none {
                                VStack(alignment: .leading, spacing: 4) {
                                    GeometryReader { geometry in
                                        ZStack(alignment: .leading) {
                                            RoundedRectangle(cornerRadius: 6)
                                                .frame(height: 8)
                                                .foregroundColor(Color.gray.opacity(0.3))
                                            
                                            RoundedRectangle(cornerRadius: 6)
                                                .frame(width: geometry.size.width * passwordStrength.level,
                                                       height: 8)
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
                                Text("❌ 비밀번호는 8자 이상 포함해야 합니다.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // 비밀번호 확인
                        VStack(alignment: .leading, spacing: 5) {
                            Text("비밀번호 확인 *")
                            SecureField("비밀번호 확인", text: $confirmPassword)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if !confirmPassword.isEmpty && confirmPassword != password {
                                Text("❌ 비밀번호가 일치하지 않습니다.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // 닉네임
                        InputWithDuplicationCheck(
                            title: "닉네임 *",
                            text: $nickname,
                            fieldState: $nicknameState,
                            placeholder: "닉네임을 입력하세요",
                            checkAction: checkNicknameDuplication
                        )
                        .onChange(of: nickname) { _ in
                            validateNickname()
                        }
                        
                        // 성별 선택
                        VStack(alignment: .leading, spacing: 5) {
                            Text("성별 *")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            Picker("성별", selection: $gender) {
                                ForEach(genders, id: \.self) { g in
                                    Text(g)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // 다음 버튼
                    Button(action: {
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
                    }) {
                        Text("다음")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(canProceed() ? Color.blue : Color.gray)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                    .disabled(!canProceed())
                    
                    NavigationLink(destination: SignUpCompleteView(path: $path), isActive: $navigateToComplete) {
                        EmptyView()
                    }
                }
                .padding(20)
            
        }
    }
    
    // MARK: - 유효성 검사
    private func validateEmail() {
        let regex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        if email.isEmpty {
            emailState = .idle
        } else if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: email) {
            emailState = .invalid("❌ 올바른 이메일 형식을 입력해주세요.")
        } else {
            emailState = .idle
        }
    }
    
    private func validateNickname() {
        let regex = #"^[가-힣A-Za-z0-9]{2,10}$"#
        if nickname.isEmpty {
            nicknameState = .idle
        } else if !NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: nickname) {
            nicknameState = .invalid("❌ 닉네임은 2~10자 한글/영문/숫자만 가능합니다.")
        } else {
            nicknameState = .idle
        }
    }
    
    private func isPasswordValid(_ password: String) -> Bool {
        let regex = #"^.{8,}$"#
        return NSPredicate(format: "SELF MATCHES %@", regex).evaluate(with: password)
    }
    
    // MARK: - 비밀번호 강도 계산
    private func evaluatePasswordStrength(_ password: String) -> PasswordStrength {
        if password.isEmpty { return .none }
        
        let weakRegex = #"^[A-Za-z\d]{1,7}$"#
        let mediumRegex = #"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{8,}$"#
        let strongRegex = #"^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>])[A-Za-z\d!@#$%^&*(),.?":{}|<>]{10,}$"#
        
        if NSPredicate(format: "SELF MATCHES %@", strongRegex).evaluate(with: password) {
            return .strong
        } else if NSPredicate(format: "SELF MATCHES %@", mediumRegex).evaluate(with: password) {
            return .medium
        } else if NSPredicate(format: "SELF MATCHES %@", weakRegex).evaluate(with: password) {
            return .weak
        } else {
            return .weak
        }
    }
    
    // Firebase 이메일 중복 확인
    private func checkEmailDuplication() {
        guard !email.isEmpty else { return }
        guard case .invalid = emailState else {
            emailState = .checking
            Auth.auth().fetchSignInMethods(forEmail: email) { methods, error in
                if let error = error {
                    emailState = .error("이메일 확인 중 오류가 발생했습니다.")
                    print(error.localizedDescription)
                    return
                }
                if let methods = methods, !methods.isEmpty {
                    emailState = .unavailable
                } else {
                    emailState = .available
                }
            }
            return
        }
    }
    
    private func checkNicknameDuplication() {
        guard !nickname.isEmpty else { return }
        guard case .invalid = nicknameState else {
            nicknameState = .checking
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                nicknameState = .available
            }
            return
        }
    }
    
    private func canProceed() -> Bool {
        return emailState.isAvailable &&
               isPasswordValid(password) &&
               confirmPassword == password &&
               nicknameState.isAvailable
    }
}

// MARK: - 재사용 컴포넌트
struct InputWithDuplicationCheck: View {
    var title: String
    @Binding var text: String
    @Binding var fieldState: FieldState
    var placeholder: String
    var checkAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
            HStack {
                TextField(placeholder, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: checkAction) {
                    if fieldState.isChecking {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                            .frame(width: 80, height: 20)
                    } else {
                        Text("중복확인")
                            .frame(width: 80)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(6)
                .disabled(fieldState.isChecking || text.isEmpty)
            }
            
            if !fieldState.message.isEmpty {
                Text(fieldState.message)
                    .font(.caption)
                    .foregroundColor(fieldState.isAvailable ? .green : .red)
            }
        }
    }
}
//
//#Preview {
//    SignUpView()
//}
