//
//  NearbyMatchesCard.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct NearbyMatchesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 헤더
            HStack {
                Image(systemName: "location.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.green)
                
                Text("내 주변 가까운 매치")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
            }
            .padding(.top, 16)
            .padding(.horizontal, 16)
            
            // 매치 리스트
            VStack(spacing: 16) {
                // 강남풋살파크
                MatchItemView(
                    location: "강남풋살파크",
                    address: "강남구 테헤란로 152",
                    distance: "1.2km",
                    time: "오늘 20:00",
                    participants: "2/10",
                    gender: .mixed,
                    rating: "4.6",
                    price: "15,000원",
                    skillLevel: "중급",
                    tags: []
                )
                
                // 홍대스포츠센터
                MatchItemView(
                    location: "홍대스포츠센터",
                    address: "마포구 와우산로 123",
                    distance: "2.8km",
                    time: "내일 19:30",
                    participants: "1/8",
                    gender: .male,
                    rating: "4.8",
                    price: "12,000원",
                    skillLevel: "초급",
                    tags: [
                        MatchTag(text: "마감임박", color: .orange, icon: "bolt.fill")
                    ]
                )
                
                // 잠실종합운동장
                MatchItemView(
                    location: "잠실종합운동장",
                    address: "송파구 올림픽로 25",
                    distance: "4.5km",
                    time: "1/26 18:00",
                    participants: "3/12",
                    gender: .female,
                    rating: "4.3",
                    price: "18,000원",
                    skillLevel: "고급",
                    tags: []
                )
            }
            .padding(.horizontal, 20)
            
            // 더 많은 매치 보기 버튼
            Button(action: {
                // 더 많은 매치 보기 기능
            }) {
                Text("더 많은 매치 보기")
                    .font(.headline)
                    .foregroundColor(.black)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 20)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}


#Preview {
    NearbyMatchesCard()
}
