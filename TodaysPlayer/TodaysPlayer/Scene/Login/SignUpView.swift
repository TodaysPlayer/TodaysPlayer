//
//  SignUpView.swift
//  TodaysPlayer
//
//  Created by 이정명 on 9/26/25.
//

import SwiftUI

struct SignUpView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isLoggedIn: Bool = false
    @State private var confirmPassword: String = ""
    @State private var nickname: String = ""
    @State private var gender: String = "남성"
    @State private var navigateToComplete = false
    
    // Alert 상태
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 각 필드 밑 에러 메시지
    @State private var emailErrorMessage = ""
    @State private var passwordErrorMessage = ""
    @State private var confirmPasswordErrorMessage = ""
    @State private var nicknameErrorMessage = ""
    
    var genders = ["남성", "여성"]
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 타이틀
                    Text("회원가입")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 20)
                    
                    VStack(alignment: .leading, spacing: 16) {
                        
                        // 이메일 입력
                        VStack(alignment: .leading, spacing: 5) {
                            Text("이메일 *")
                            HStack {
                                TextField("이메일", text: $email)
                                    .keyboardType(.emailAddress)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("중복확인") {
                                    // 이메일 중복 확인 로직
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                            }
                            if email.contains("@") {
                                Text("✅ 사용 가능한 이메일입니다.")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                        
                        // 비밀번호
                        VStack(alignment: .leading, spacing: 5) {
                            Text("비밀번호 *")
                            SecureField("비밀번호 (8자 이상)", text: $password)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            if password.count < 8 {
                                Text("비밀번호는 8자 이상이어야 합니다.")
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
                                Text("비밀번호가 일치하지 않습니다.")
                                    .font(.caption)
                                    .foregroundColor(.red)
                            }
                        }
                        
                        // 닉네임
                        VStack(alignment: .leading, spacing: 5) {
                            Text("닉네임 *")
                            HStack {
                                TextField("닉네임", text: $nickname)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("중복확인") {
                                    // 닉네임 중복 확인 로직
                                }
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(6)
                            }
                            if !nickname.isEmpty {
                                Text("✅ 사용 가능한 닉네임입니다.")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
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
                            .padding(.vertical,16)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    
                    // 다음 버튼
                    Button(action: {
                        // 회원가입 완료 → 다음 단계
                        navigateToComplete = true
                    }) {
                        Text("다음")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                    .padding(.top, 20)
                    
                    NavigationLink(
                        destination: SignUpCompleteView(),
                        isActive: $navigateToComplete,
                        label: { EmptyView() }
                    )
                }
                .padding(20)
            }
            
        }
    }
}



#Preview {
    SignUpView()
}
