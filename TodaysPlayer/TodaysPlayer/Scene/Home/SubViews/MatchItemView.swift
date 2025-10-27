//
//  MatchItemView.swift
//  TodaysPlayer
//
//  Created by J on 9/24/25.
//

import SwiftUI

struct MatchItemView: View {
    let title: String
    let matchType: String
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
    
    private var genderLabel: String {
        switch gender {
        case .male:
            return "남성"
            
        case .female:
            return "여성"
            
        case .mixed:
            return "혼성"
        }
    }
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 제목과 평점
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
            
            // 실력 레벨 & 종목
            HStack(spacing: 10) {
                Text(skillLevel)
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondaryDeepGray.opacity(0.5))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Text(matchType == "futsal" ? "풋살" : "축구")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(matchType == "futsal" ? Color.futsalGreen : Color.secondaryMintGreen)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Spacer()
            }
            .padding(.bottom)
            
            // 시간 정보
            HStack(spacing: 4) {
                Image(systemName: "clock")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                
                Text(time)
                    .font(.caption)
                    .foregroundColor(.black)
            }
            
            // 위치 정보
            HStack(spacing: 4) {
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
            
            // 매치 정보
            HStack(spacing: 15) {
                HStack(spacing: 4) {
                    Image(systemName: "person.2")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(participants)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                
                HStack(spacing: 4) {
                    Image(systemName: "wonsign.circle")
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                    
                    Text(price)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                
                HStack(spacing: 4) {
                    Image(genderIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                        .foregroundColor(genderColor)
                    
                    Text(genderLabel)
                        .font(.caption)
                        .foregroundColor(.black)
                }
                
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
