//
//  MatchItemView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct MatchItemView: View {
    let location: String
    let address: String
    let distance: String
    let time: String
    let participants: String
    let gender: GenderType
    let rating: String
    let price: String
    let skillLevel: String
    let tags: [MatchTag]
    
    private var genderIcon: String {
        switch gender {
        case .male:
            return "person"
        case .female:
            return "person"
        case .mixed:
            return "person.2"
        }
    }
    
    private var genderColor: Color {
        switch gender {
        case .male:
            return .blue
        case .female:
            return .red
        case .mixed:
            return .gray
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 상단: 제목과 평점
            HStack {
                Text(location)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 12))
                    
                    Text(rating)
                        .font(.caption)
                        .foregroundColor(.black)
                }
            }
            
            // 위치 정보
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                
                Text(address)
                    .font(.caption)
                    .foregroundColor(.black)
                
                Text("(\(distance))")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            
            // 시간과 참가자 정보
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(time)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(participants)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                .padding(.leading, 10)
                .padding(.trailing, 1)
                
                HStack(spacing: 4) {
                    Image(systemName: genderIcon)
                        .font(.system(size: 12))
                        .foregroundColor(genderColor)
                }
                
                Spacer()
                
                Text(price)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.blue)
            }
            
            // 하단: 실력 레벨
            HStack {
                Text(skillLevel)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
        }
        .padding(16)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}


#Preview {
    MatchItemView(
        location: "강남풋살파크",
        address: "강남구 테헤란로 152",
        distance: "1.2km",
        time: "오늘 20:00",
        participants: "2/10",
        gender: .female,
        rating: "4.6",
        price: "15,000원",
        skillLevel: "중급",
        tags: []
    )
}
