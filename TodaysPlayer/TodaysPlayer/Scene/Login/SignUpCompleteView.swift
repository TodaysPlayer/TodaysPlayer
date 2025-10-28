//
//  SignUpCompleteView.swift
//  TodaysPlayer
//
//  Created by 이정명 on 9/30/25.
//

import SwiftUI

struct SignUpCompleteView: View {
    
    @Binding var path: NavigationPath
    var userNickname: String
    
    var body: some View {
        VStack(spacing: 24) {
            
            // 상단 체크 아이콘
            Image("TodaysPlayerIcon")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.primaryBaseGreen)
                .padding(.top, 40)
            
            // 제목
            Text("가입 완료!")
                .font(.title)
                .bold()
            
            // 환영 문구
            Text("\(userNickname)님,\n오늘의 용병에 오신 것을 환영합니다!")
                .multilineTextAlignment(.center)
                .font(.body)
                .padding(.horizontal)
            
            // 서비스 설명 카드
            VStack(spacing: 16) {
                FeatureCard(
                    iconName: "person.2.fill",
                    iconColor: Color.primaryBaseGreen,
                    title: "간편한 매치 찾기",
                    description: "주변 풋살장에서 진행되는 경기를 쉽게 찾아보세요",
                    backgroundColor: Color.primaryBaseGreen.opacity(0.08)
                )
                
                FeatureCard(
                    iconName: "trophy.fill",
                    iconColor: Color.primaryBaseGreen,
                    title: "용병 모집 & 참여",
                    description: "부족한 인원을 채우거나 용병으로 참여해보세요",
                    backgroundColor: Color.primaryBaseGreen.opacity(0.08)
                )
                
                FeatureCard(
                    iconName: "checkmark.seal.fill",
                    iconColor: Color.primaryBaseGreen,
                    title: "자동 일정 관리",
                    description: "카톡, 밴드 없이도 경기 일정을 체계적으로 관리",
                    backgroundColor: Color.primaryBaseGreen.opacity(0.08)
                )
            }
            .padding(.horizontal, 10)
            
            Spacer()
            
            // 안내 문구
            Text("지금 바로 주변 경기를 찾아보고\n새로운 축구 친구들을 만나보세요!")
                .font(.caption)
                .foregroundColor(Color.secondaryDeepGray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // 시작하기 버튼
            Button(action: {
                while path.count > 0 {
                    path.removeLast()
                }
            }) {
                Text("오늘의 용병 시작하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.primaryBaseGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(20)
    
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .ignoresSafeArea(edges: .bottom)
        .navigationBarBackButtonHidden(true)
    }
}

// 카드 재사용 컴포넌트
struct FeatureCard: View {
    var iconName: String
    var iconColor: Color
    var title: String
    var description: String
    var backgroundColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(iconColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline).bold()
                Text(description)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
    }
}

