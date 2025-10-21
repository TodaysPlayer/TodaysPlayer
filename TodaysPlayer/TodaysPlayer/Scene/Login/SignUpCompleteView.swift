//
//  SignUpCompleteView.swift
//  TodaysPlayer
//
//  Created by 이정명 on 9/30/25.
//

import SwiftUI

struct SignUpCompleteView: View {
    
    @Binding var path: NavigationPath
    
    var body: some View {
        VStack(spacing: 24) {
            // ✅ 상단 체크 아이콘
            Image(systemName: "checkmark.circle.fill")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.green)
                .padding(.top, 40)
            
            // ✅ 제목
            Text("가입 완료!")
                .font(.title)
                .bold()
            
            // ✅ 환영 문구
            Text("○○님,\n오늘의 용병에 오신 것을 환영합니다!")
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.horizontal)
            
            // ✅ 서비스 설명 카드
            VStack(spacing: 16) {
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "person.2.fill")
                        .foregroundColor(.blue)
                        .frame(width: 24, height: 24)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("간편한 매치 찾기")
                            .font(.subheadline).bold()
                        Text("주변 풋살장에서 진행되는 경기를 쉽게 찾아보세요")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.blue.opacity(0.05))
                .cornerRadius(12)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "trophy.fill")
                        .foregroundColor(.green)
                        .frame(width: 24, height: 24)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("용병 모집 & 참여")
                            .font(.subheadline).bold()
                        Text("부족한 인원을 채우거나 용병으로 참여해보세요")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.green.opacity(0.05))
                .cornerRadius(12)
                
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.purple)
                        .frame(width: 24, height: 24)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("자동 일정 관리")
                            .font(.subheadline).bold()
                        Text("카톡, 밴드 없이도 경기 일정을 체계적으로 관리")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.purple.opacity(0.05))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            Spacer()
            
            
            Button(action: {
                while path.count > 0 {
                    path.removeLast()
                }
            }) {
                Text("오늘의 용병 시작하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // ✅ 안내 문구
            Text("지금 바로 주변 경기를 찾아보고\n새로운 축구 친구들을 만나보세요!\n\n궁금한 점이 있으시면 언제든 고객센터로 문의해주세요")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 20)
        }
        .padding()
        .background(Color(.systemGray6))
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }
}

//#Preview{
//    SignUpCompleteView()
//}
