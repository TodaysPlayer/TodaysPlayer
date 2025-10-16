//
//  LoginView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    
    // 알림창 상태
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 입력칸 하단 에러 메시지
    @State private var emailErrorMessage = ""
    @State private var passwordErrorMessage = ""
    
    // 테스트용 가입된 이메일
    private let registeredEmails = ["test@example.com", "user1@naver.com", "hello@gmail.com"]
    
    enum Field { case email, password }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                    .onTapGesture { focusedField = nil }
                
                VStack(spacing: 30) {
                    // 로고 및 타이틀
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
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray)
                                TextField("이메일을 입력하세요", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .disableAutocorrection(true)
                                    .keyboardType(.emailAddress)
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .password }
                                    .onChange(of: email) { _ in
                                        emailErrorMessage = ""
                                    }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            
                            // 이메일 에러 메시지
                            if !emailErrorMessage.isEmpty {
                                Text(emailErrorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // 비밀번호 입력 필드
                        VStack(alignment: .leading, spacing: 4) {
                            Text("비밀번호")
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                SecureField("비밀번호를 입력하세요", text: $password)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.done)
                                    .onSubmit { login() }
                                    .onChange(of: password) { _ in
                                        passwordErrorMessage = ""
                                    }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            
                            // 비밀번호 에러 메시지
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
                        
                        NavigationLink(destination: SignUpView()) {
                            Text("이메일로 회원가입")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3))
                                )
                        }
                    }
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
        }
        // ✅ Alert도 유지
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("로그인 오류"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            ContentView()
        }
    }
    
    // 로그인 검증 함수
    private func login() {
        // 에러 초기화
        emailErrorMessage = ""
        passwordErrorMessage = ""
        alertMessage = ""
        
        // 이메일 검증
        if email.isEmpty {
            focusedField = .email
            alertMessage = "이메일을 입력하세요"
            emailErrorMessage = alertMessage
            showAlert = true
            return
        }
        if !email.contains("@") || !email.contains(".") {
            focusedField = .email
            alertMessage = "올바른 이메일 형식을 입력하세요"
            emailErrorMessage = alertMessage
            showAlert = true
            return
        }
        if !registeredEmails.contains(email) {
            focusedField = .email
            alertMessage = "가입되지 않은 이메일입니다"
            emailErrorMessage = alertMessage
            showAlert = true
            return
        }
        
        // 비밀번호 검증
        if password.isEmpty {
            focusedField = .password
            alertMessage = "비밀번호를 입력하세요"
            passwordErrorMessage = alertMessage
            showAlert = true
            return
        }
        if password.count < 8 {
            focusedField = .password
            alertMessage = "비밀번호는 8자 이상이어야 합니다"
            passwordErrorMessage = alertMessage
            showAlert = true
            return
        }
        
        // 로그인 성공
        focusedField = nil
        isLoggedIn = true
    }
}

#Preview {
    LoginView()
}
