//
//  PasswordResetView.swift
//  TodaysPlayer
//
//  Created by 이정명 on 9/30/25.
//

import SwiftUI
import FirebaseAuth
import Combine

struct PasswordResetView: View {
    @State private var email: String = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                // 상단 제목
                Text("비밀번호 재설정")
                    .font(.title2)
                    .bold()
                    .padding(.top, 16)
                
                // 설명 카드
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("비밀번호를 잊어버리셨나요?")
                            .font(.headline)
                        
                        Text("가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    // 이메일 입력 필드
                    HStack {
                        Image(systemName: "envelope.fill")
                            .foregroundColor(.gray)
                        TextField("가입하신 이메일을 입력하세요", text: $email)
                            .textFieldStyle(PlainTextFieldStyle())
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    
                    // 버튼
                    Button(action: sendPasswordReset) {
                        Text("비밀번호 재설정 링크 보내기")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(email.isEmpty ? Color.gray : Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(email.isEmpty)
                    
                    // 안내 문구
                    VStack(alignment: .leading, spacing: 6) {
                        Text("알려드립니다:")
                            .font(.subheadline)
                            .bold()
                        Text("• 이메일 전송까지 최대 5분이 소요될 수 있습니다")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("• 재설정 링크는 24시간 동안 유효합니다")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("• 가입되지 않은 이메일은 전송되지 않습니다")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                
                Spacer(minLength: 50)
            }
            .padding()
            .padding(.bottom, keyboardHeight)
            .animation(.easeOut(duration: 0.25), value: keyboardHeight)
        }
        .background(Color(.systemGray5).ignoresSafeArea())
        .alert(isPresented: $showAlert) {
            Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인")))
        }
        .onReceive(Publishers.keyboardHeight) { self.keyboardHeight = $0 }
    }
    
    // 이메일 정규식 체크
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", pattern).evaluate(with: email)
    }
    
    // 비밀번호 재설정 Firebase
    private func sendPasswordReset() {
        guard !email.isEmpty else {
            alertMessage = "이메일을 입력해주세요."
            showAlert = true
            return
        }
        
        guard isValidEmail(email) else {
            alertMessage = "올바른 이메일 형식을 입력해주세요."
            showAlert = true
            return
        }
        
        print("🔹 비밀번호 재설정 요청 시작:", email)
        
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            DispatchQueue.main.async {
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .invalidEmail:
                        alertMessage = "유효하지 않은 이메일입니다."
                    case .userNotFound:
                        alertMessage = "가입하지 않은 이메일입니다."
                    default:
                        alertMessage = "비밀번호 재설정 이메일 전송에 실패했습니다."
                    }
                    print("❌ Firebase 오류 코드:", error.code, "설명:", error.localizedDescription)
                    showAlert = true
                    return
                }
                
                // 성공
                alertMessage = "비밀번호 재설정 링크가 이메일로 전송되었습니다."
                print("✅ 비밀번호 재설정 이메일 전송 완료:", email)
                showAlert = true
            }
        }
    }
}

// 키보드 높이 감지 Publisher
extension Publishers {
    static var keyboardHeight: AnyPublisher<CGFloat, Never> {
        let willShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
        
        let willHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
        
        return willShow.merge(with: willHide).eraseToAnyPublisher()
    }
}

#Preview {
    PasswordResetView()
}
