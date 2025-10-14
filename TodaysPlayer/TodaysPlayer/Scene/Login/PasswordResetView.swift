//
//  PasswordResetView.swift
//  TodaysPlayer
//
//  Created by 이정명 on 9/30/25.
//

import SwiftUI

struct PasswordResetView: View {
    @State private var email: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            
            // 상단 제목
            Text("비밀번호 재설정")
                .font(.title2)
                .bold()
                .padding(.top, 16)
            
            //  설명 카드
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("비밀번호를 잊어버리셨나요?")
                        .font(.headline)
                    
                    Text("가입하신 이메일 주소를 입력하시면\n비밀번호 재설정 링크를 보내드립니다.")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                //  이메일 입력 필드
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
                
                // 버튼 (활성/비활성 상태 반영)
                Button(action: {
                    // 이메일 전송 로직
                }) {
                    Text("비밀번호 재설정 링크 보내기")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(email.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .disabled(email.isEmpty) // 이메일 없으면 버튼 비활성화
                
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
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray5).ignoresSafeArea())
    }
}

#Preview{
    PasswordResetView()
}
