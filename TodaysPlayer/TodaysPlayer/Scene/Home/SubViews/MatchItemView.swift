//
//  MatchItemView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct MatchItemView: View {
    let title: String
    let location: String
    let distance: String
    let time: String
    let participants: String
    let gender: GenderType
    let rating: String?
    let price: String
    let skillLevel: String
    let tags: [MatchTag]
    
    private var genderIcon: String {
        switch gender {
        case .male:
            return "icon_male"
        case .female:
            return "icon_female"
        case .mixed:
            return "icon_mixed"
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
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.black)
                
                Spacer()
                
                if let rating {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.system(size: 12))
                        
                        Text(rating)
                            .font(.caption)
                            .foregroundColor(.black)
                    }
                }
            }
            
            // 위치 정보
            HStack {
                Image(systemName: "location")
                    .foregroundColor(.gray)
                    .font(.system(size: 12))
                
                Text(location)
                    .lineLimit(1)
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
                .padding(.trailing, 10)
                
                HStack(spacing: 4) {
                    Image(genderIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
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
        title: "풋살 초보분들 찾아여~",
        location: "강남풋살파크",
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
