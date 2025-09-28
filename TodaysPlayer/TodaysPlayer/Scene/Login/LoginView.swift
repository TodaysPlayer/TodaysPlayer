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
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray.opacity(0.1)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // 앱 로고 및 브랜딩
                    VStack(spacing: 16) {
                        // 로고
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: "shield.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 40))
                        }
                        
                        // 앱 이름
                        Text("오늘의 용병")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        // 태그라인
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
                            .foregroundColor(.black)
                            .padding(.bottom, 10)
                        
                        // 이메일 입력 필드
                        VStack(alignment: .leading, spacing: 8) {
                            Text("이메일")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            HStack {
                                Image(systemName: "envelope")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 12)
                                
                                TextField("이메일을 입력하세요", text: $email)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.vertical, 12)
                                    .padding(.trailing, 12)
                            }
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // 비밀번호 입력 필드
                        VStack(alignment: .leading, spacing: 8) {
                            Text("비밀번호")
                                .font(.subheadline)
                                .foregroundColor(.black)
                            
                            HStack {
                                Image(systemName: "lock")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 12)
                                
                                SecureField("비밀번호를 입력하세요", text: $password)
                                    .textFieldStyle(PlainTextFieldStyle())
                                    .padding(.vertical, 12)
                                    .padding(.trailing, 12)
                            }
                            .background(Color.gray.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // 로그인 버튼
                        Button(action: {
                            // 임시로 로그인 성공 처리
                            isLoggedIn = true
                        }) {
                            Text("로그인")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                        
                        // 비밀번호 찾기 링크
                        Button(action: {
                            // 비밀번호 찾기 기능
                        }) {
                            Text("비밀번호를 잊으셨나요?")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // 회원가입 버튼
                        Button(action: {
                            // 회원가입 기능
                        }) {
                            Text("이메일로 회원가입")
                                .font(.headline)
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    // 약관 동의 안내
                    Text("로그인 시 서비스 이용약관 및 개인정보처리방침에 동의하게 됩니다.")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 30)
                }
            }
        }
        .fullScreenCover(isPresented: $isLoggedIn) {
            ContentView()
        }
    }
}

#Preview {
    LoginView()
}
