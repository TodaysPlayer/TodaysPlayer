//
//  MatchCardView.swift
//  TodaysPlayer
//
//  Created by 권소정 on 10/27/25.
//

import SwiftUI

struct MatchCardView: View {
    let match: Match
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 제목
            Text(match.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // 풋살/축구 태그
            HStack {
                Text(match.matchType == "futsal" ? "풋살" : "축구")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(match.matchType == "futsal" ? Color.futsalGreen : Color.secondaryMintGreen)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                
                Spacer()
            }
            
            // 시간
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.caption)
                    .foregroundColor(.primary)
                Text(match.dateTime.formatForDisplay())
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            
            // 장소명
            HStack(spacing: 4) {
                Image(systemName: "location")
                    .font(.caption)
                    .foregroundColor(.primary)
                Text(match.location.address.extractRegionWithDistrict())
                    .font(.caption)
                    .foregroundColor(.primary)
            }
            
            // 인원 / 참가비 / 성별 / 실력
            HStack(spacing: 16) {
                // 인원
                HStack(spacing: 2) {
                    Image(systemName: "person.2")
                        .font(.caption2)
                        .foregroundColor(.primary)
                    Text("\(match.appliedParticipantsCount) / \(match.maxParticipants)")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                // 참가비
                HStack(spacing: 2) {
                    Image(systemName: "wonsign.circle")
                        .font(.caption2)
                        .foregroundColor(.primary)
                    Text(match.price == 0 ? "무료" : "\(match.price)원")
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                // 성별
                HStack(spacing: 2) {
                    Image(convertGenderIcon(gender: match.gender))
                        .resizable()
                        .scaledToFit()
                        .frame(width: 12, height: 12)
                    Text(match.genderKorean)
                        .font(.caption)
                        .foregroundColor(.primary)
                }
                
                // 실력
                Text(match.skillLevel.skillLevelToKorean())
                    .font(.caption)
                    .foregroundColor(.primary)
                
                Spacer()
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 4)
    }
    
    // 성별 아이콘 변환 함수도 여기로 이동
    private func convertGenderIcon(gender: String) -> String {
        switch gender {
        case "male":
            return "icon_male"
        case "female":
            return "icon_female"
        case "mixed":
            return "icon_mixed"
        default:
            return "icon_mixed"
        }
    }
}
