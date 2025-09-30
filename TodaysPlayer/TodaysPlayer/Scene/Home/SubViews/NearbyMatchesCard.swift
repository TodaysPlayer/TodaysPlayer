//
//  NearbyMatchesCard.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct NearbyMatchesCard: View {
    let matches: [Match]
    let viewModel: HomeViewModel
    
    
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
                if matches.isEmpty {
                    Text("주변에 매치가 없습니다")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .padding(.vertical, 20)
                } else {
                    ForEach(Array(matches.enumerated()), id: \.element.id) { index, match in
                        MatchItemView(
                            location: match.location.name,
                            address: match.location.address,
                            distance: viewModel.formatDistance(to: match.location.coordinates),
                            time: match.dateTime.formatForDisplay(),
                            participants: "\(Int.random(in: 1...match.maxParticipants))/\(match.maxParticipants)",
                            gender: .mixed, // 임시 성별
                            rating: "4.\(Int.random(in: 0...9))", // 임시 평점
                            price: match.price == 0 ? "무료" : "\(match.price)원",
                            skillLevel: match.skillLevel.skillLevelToKorean(),
                            tags: match.createMatchTags()
                        )
                    }
                }
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
    NearbyMatchesCard(matches: [], viewModel: HomeViewModel())
}
